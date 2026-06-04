// ===============================================================================
// RÔLE 2 : Authentification & Secrets (Auteur)
// ===============================================================================
// Crée :
//   1. Une identité managée user-assigned pour l'application.
//   2. Un Azure Key Vault (Standard) en mode autorisation RBAC.
//   3. Une attribution de rôle « Key Vault Secrets User » à cette identité
//      (moindre privilège : lecture des secrets uniquement).
// ===============================================================================

@description('Région Azure de déploiement')
param location string = resourceGroup().location

@description('Nom de l\'environnement (dev, prod, etc.)')
param environmentName string

@description('Préfixe des ressources (ex: sn)')
param resourcePrefix string

@description('Active la protection contre la purge du Key Vault (recommandé). ATTENTION : irréversible une fois activé. Mettre false pour un sandbox jetable.')
param enablePurgeProtection bool = true

// -------------------------------------------------------------------------------
// Variables
// -------------------------------------------------------------------------------
// Un nom de Key Vault doit être UNIQUE AU NIVEAU MONDIAL. On ajoute un suffixe
// déterministe (basé sur le resource group) => redéploiements idempotents dans
// le même RG, mais pas de collision avec un autre vault « sn-dev-kv » sur Azure.
var kvSuffix = take(uniqueString(resourceGroup().id), 6)
var keyVaultName = '${resourcePrefix}-${environmentName}-kv-${kvSuffix}'
var identityName = '${resourcePrefix}-${environmentName}-id'

// ID du rôle intégré « Key Vault Secrets User » (lecture seule des secrets).
var keyVaultSecretsUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6'

// -------------------------------------------------------------------------------
// 1. Identité managée user-assigned
// -------------------------------------------------------------------------------
resource appIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

// -------------------------------------------------------------------------------
// 2. Key Vault en mode RBAC (pas de vault access policies)
// -------------------------------------------------------------------------------
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true              // moindre privilège via RBAC Azure
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enablePurgeProtection: enablePurgeProtection ? true : null
    publicNetworkAccess: 'Enabled'             // prototype ; restreindre = point Zero Trust
  }
}

// -------------------------------------------------------------------------------
// 3. Attribution RBAC : l'identité peut LIRE les secrets, et rien d'autre
// -------------------------------------------------------------------------------
resource secretsUserAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, appIdentity.id, keyVaultSecretsUserRoleId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretsUserRoleId)
    principalId: appIdentity.properties.principalId
    principalType: 'ServicePrincipal'          // évite les erreurs de réplication AAD
  }
}

// ===============================================================================
// CONTRAT DE SORTIE (OUTPUTS) — valeurs RÉELLES consommées par les autres modules.
// Les consommateurs (Rôle 1, Rôle 3) doivent lire ces outputs, jamais coder le nom en dur.
// ===============================================================================
output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri
output appIdentityId string = appIdentity.id
output appIdentityClientId string = appIdentity.properties.clientId
output appIdentityPrincipalId string = appIdentity.properties.principalId
