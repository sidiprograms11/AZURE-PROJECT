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

// TODO : Le propriétaire du Rôle 1 doit créer ici :
// 1. Un App Service Plan (hébergement Linux, SKU F1 par défaut ou B1 pour la démo).
// 2. Un App Service (Web App) configuré avec :
//    - HTTPS uniquement (`httpsOnly: true`)
//    - TLS 1.2 minimum requis
//    - FTPS désactivé (`ftpsState: 'Disabled'`)
//    - L'identité managée assignée configurée (`appIdentityId`)
//    - Les variables d'environnement (App Settings) connectées :
//      - `APPINSIGHTS_CONNECTION_STRING`
//      - `AZURE_CLIENT_ID` (pour l'identité managée)
//      - Variables de connexion SQL passwordless (serveur, nom de BDD, etc.)

// ===============================================================================
// CONTRAT DE SORTIE (OUTPUTS)
// ===============================================================================

output appServiceUrl string = 'https://${resourcePrefix}-${environmentName}-app.azurewebsites.net'
output appServicePlanName string = '${resourcePrefix}-${environmentName}-asp'
