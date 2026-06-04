// ===============================================================================
// RÔLE 2 : Authentification & Secrets (Auteur)
// ===============================================================================
// Ce fichier est un squelette (stub) pour le Rôle 2.
// Il doit définir l'identité managée de l'application et le coffre-fort Key Vault.
// ===============================================================================

@description('Région Azure de déploiement')
param location string = resourceGroup().location

@description('Nom de l\'environnement (dev, prod, etc.)')
param environmentName string

@description('Préfixe des ressources (ex: sn)')
param resourcePrefix string

// TODO : Le propriétaire du Rôle 2 doit créer ici :
// 1. Une identité managée (User-Assigned Managed Identity) pour l'application.
// 2. Un Azure Key Vault en mode Standard avec l'autorisation RBAC activée.
// 3. Une attribution de rôle (Role Assignment) « Key Vault Secrets User » à cette identité.

// ===============================================================================
// CONTRAT DE SORTIE (OUTPUTS)
// Ces valeurs permettent d'interconnecter ce module avec les autres (ex: Rôle 1).
// ===============================================================================

output keyVaultName string = '${resourcePrefix}-${environmentName}-kv'
output keyVaultUri string = 'https://${resourcePrefix}-${environmentName}-kv.vault.azure.net/'
output appIdentityId string = '/subscriptions/${subscription().subscriptionId}/resourcegroups/${resourceGroup().name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${resourcePrefix}-${environmentName}-id'
output appIdentityClientId string = '00000000-0000-0000-0000-000000000000'
output appIdentityPrincipalId string = '00000000-0000-0000-0000-000000000000'
