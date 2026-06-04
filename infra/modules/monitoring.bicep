// ===============================================================================
// RÔLE 4 : Supervision (Azure Monitor & Defender for Cloud)
// ===============================================================================
// Ce fichier est un squelette (stub) pour le Rôle 4.
// Il doit définir l'espace Log Analytics et Application Insights pour le monitoring.
// ===============================================================================

@description('Région Azure de déploiement')
param location string = resourceGroup().location

@description('Nom de l\'environnement (dev, prod, etc.)')
param environmentName string

@description('Préfixe des ressources (ex: sn)')
param resourcePrefix string

var logAnalyticsWorkspaceName = '${resourcePrefix}-${environmentName}-law'
var appInsightsName = '${resourcePrefix}-${environmentName}-appi'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  sku: {
    name: 'PerGB2018'
  }
  properties: {
    retentionInDays: 30
    workspaceCapping: {
      dailyQuotaGb: 0.023
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

output appInsightsConnectionString string = appInsights.properties.connectionString
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
