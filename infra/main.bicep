/*
===============================================================================
ORCHESTRATEUR PRINCIPAL - PROJET SMART NOTES (SQUELETTE SIMPLIFIÉ)
===============================================================================
NOTE CRITIQUE :
« Le déploiement de ce fichier dans UN SEUL resource group Azure déploie et connecte
toutes les ressources physiques. Git ne connecte pas les ressources, il assemble le code. »

Ce fichier main.bicep sert de chef d'orchestre :
Il appelle les modules de chaque membre de l'équipe et transmet les outputs
des uns comme paramètres d'entrée des autres (câblage des contrats).
===============================================================================
*/

targetScope = 'resourceGroup'

@description('Région Azure de déploiement')
param location string = resourceGroup().location

@description('Nom de l\'environnement (dev, prod, etc.)')
param environmentName string = 'dev'

@description('Préfixe des ressources (ex: sn)')
param resourcePrefix string = 'sn'

@description('Tarification App Service')
@allowed([
  'F1'
  'B1'
])
param appServiceSku string = 'F1'

// ===============================================================================
// ÉTAPE 1 : Déploiement de l'Identité & Key Vault (Rôle 2)
// Ce module crée l'identité managée utilisée pour l'accès sécurisé sans mot de passe.
// ===============================================================================
module identityKeyVault './modules/identity-keyvault.bicep' = {
  name: 'deploy-identity-keyvault'
  params: {
    location: location
    environmentName: environmentName
    resourcePrefix: resourcePrefix
  }
}

// ===============================================================================
// ÉTAPE 2 : Déploiement de la Base de Données SQL (Rôle 3)
// Reçoit le "principalId" du Rôle 2 pour définir l'identité comme administrateur AD.
// ===============================================================================
module sqlDatabase './modules/sql-database.bicep' = {
  name: 'deploy-sql-database'
  params: {
    location: location
    environmentName: environmentName
    resourcePrefix: resourcePrefix
    // CONTRAT : On transmet le principalId de l'identité générée par le Rôle 2
    appIdentityPrincipalId: identityKeyVault.outputs.appIdentityPrincipalId
  }
}

// ===============================================================================
// ÉTAPE 3 : Déploiement de la Supervision (Rôle 4)
// Crée Log Analytics et Application Insights pour centraliser les logs.
// ===============================================================================
module monitoring './modules/monitoring.bicep' = {
  name: 'deploy-monitoring'
  params: {
    location: location
    environmentName: environmentName
    resourcePrefix: resourcePrefix
  }
}

// ===============================================================================
// ÉTAPE 4 : Déploiement de l'App Service (Rôle 1)
// Consomme les configurations des Rôles 2, 3 et 4 pour s'y connecter de manière sécurisée.
// ===============================================================================
module appService './modules/app-service.bicep' = {
  name: 'deploy-app-service'
  params: {
    location: location
    environmentName: environmentName
    resourcePrefix: resourcePrefix
    skuName: appServiceSku
    
    // CONTRAT : Identité managée fournie par le Rôle 2
    appIdentityId: identityKeyVault.outputs.appIdentityId
    appIdentityClientId: identityKeyVault.outputs.appIdentityClientId

    // CONTRAT : Serveur et BDD fournis par le Rôle 3
    sqlServerFqdn: sqlDatabase.outputs.sqlServerFqdn
    sqlDatabaseName: sqlDatabase.outputs.sqlDatabaseName

    // CONTRAT : Chaine de connexion de supervision fournie par le Rôle 4
    appInsightsConnectionString: monitoring.outputs.appInsightsConnectionString
  }
}

// ===============================================================================
// OUTPUTS GLOBAUX DU DÉPLOIEMENT Azure
// ===============================================================================
output appServiceUrl string = appService.outputs.appServiceUrl
output keyVaultUri string = identityKeyVault.outputs.keyVaultUri
output sqlServerFqdn string = sqlDatabase.outputs.sqlServerFqdn
output appInsightsConnectionString string = monitoring.outputs.appInsightsConnectionString
