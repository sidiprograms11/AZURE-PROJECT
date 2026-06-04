using '../main.bicep'

@description('Azure Region where resources will be deployed')
param location = 'westeurope'

@description('Environment name prefix')
param environmentName = 'dev'

@description('Global resource prefix')
param resourcePrefix = 'sn'

@description('App Service pricing tier')
param appServiceSku = 'F1'
