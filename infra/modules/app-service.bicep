// ===============================================================================
// RÔLE 1 : App Smart Notes (Azure App Service)
// ===============================================================================
// Ce fichier est un squelette (stub) pour le Rôle 1.
// Il doit définir l'App Service Plan (hébergement) et la Web App (code exécuté).
// ===============================================================================

@description('Région Azure de déploiement')
param location string = resourceGroup().location

@description('Nom de l\'environnement (dev, prod, etc.)')
param environmentName string

@description('Préfixe des ressources (ex: sn)')
param resourcePrefix string

// Paramètres issus du Rôle 2 (Authentification & Identité)
@description('ID de l\'identité managée (User-Assigned) pour l\'App Service')
param appIdentityId string

@description('Client ID de l\'identité managée (reçu du Rôle 2)')
param appIdentityClientId string

// Paramètres issus du Rôle 3 (Base de données)
@description('FQDN du serveur SQL (reçu du Rôle 3)')
param sqlServerFqdn string

@description('Nom de la base de données (reçu du Rôle 3)')
param sqlDatabaseName string

// Paramètres issus du Rôle 4 (Supervision)
@description('Chaîne de connexion Application Insights (reçu du Rôle 4)')
param appInsightsConnectionString string

@description('Tarification App Service (F1 est gratuit, B1 est recommandé pour les démos)')
@allowed([
  'F1'
  'B1'
])
param skuName string = 'F1'

var appServicePlanName = '${resourcePrefix}-${environmentName}-asp'
var webAppName = '${resourcePrefix}-${environmentName}-app'

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
    tier: skuName == 'F1' ? 'Free' : 'Basic'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: webAppName
  location: location
  kind: 'app,linux'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${appIdentityId}': {}
    }
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'NODE|22-lts'
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      appSettings: [
        {
          name: 'APPINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'AZURE_CLIENT_ID'
          value: appIdentityClientId
        }
        {
          name: 'SQL_SERVER_FQDN'
          value: sqlServerFqdn
        }
        {
          name: 'SQL_DATABASE_NAME'
          value: sqlDatabaseName
        }
      ]
    }
  }
}

output appServiceUrl string = 'https://${webApp.properties.defaultHostName}'
output appServicePlanName string = appServicePlan.name
