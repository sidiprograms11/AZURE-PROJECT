// ===============================================================================
// RÔLE 3 : Base de données (Azure SQL Database)
// ===============================================================================
// Ce fichier est un squelette (stub) pour le Rôle 3.
// Il doit définir le serveur logique Azure SQL et la base de données SQL.
// ===============================================================================

@description('Région Azure de déploiement')
param location string = resourceGroup().location

@description('Nom de l\'environnement (dev, prod, etc.)')
param environmentName string

@description('Préfixe des ressources (ex: sn)')
param resourcePrefix string

@description('ID Principal de l\'identité managée (reçu du Rôle 2)')
param appIdentityPrincipalId string

// Paramètres de budget recommandés pour l'abonnement étudiant :
@description('Utiliser la limite d\'offre gratuite pour la base de données')
param useFreeLimit bool = true

@description('Comportement en cas d\'épuisement de la limite gratuite')
param freeLimitExhaustionBehavior string = 'AutoPause'

var sqlServerName = '${resourcePrefix}-${environmentName}-sql'
var sqlDatabaseName = '${resourcePrefix}-${environmentName}-db'

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'Application'
      login: 'smart-notes-managed-identity'
      sid: appIdentityPrincipalId
      azureADOnlyAuthentication: true
    }
  }
}

resource sqlFirewallAzureServices 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = {
  name: 'AllowAzureServices'
  parent: sqlServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  name: sqlDatabaseName
  parent: sqlServer
  location: location
  sku: {
    name: 'GP_S_Gen5_1'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 1
  }
  properties: {
    autoPauseDelay: 60
    minCapacity: 0.5
  }
}

output sqlServerName string = sqlServer.name
output sqlServerFqdn string = '${sqlServerName}.database.windows.net'
output sqlDatabaseName string = sqlDatabase.name
