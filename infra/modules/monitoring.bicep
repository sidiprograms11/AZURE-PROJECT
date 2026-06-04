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

// TODO : Le propriétaire du Rôle 4 doit créer ici :
// 1. Un workspace Log Analytics pour stocker tous les logs de l'application et de l'infra.
// 2. Une instance Application Insights (liée au workspace) pour le monitoring applicatif.
// 3. (Optionnel) Documenter Defender for Cloud en tier gratuit (CSPM fondamental).
// 
// ATTENTION BUDGET ÉTUDIANT : 
// - NE PAS activer de plan Defender for Cloud payant (facturation par ressource/heure).
// - Configurer un Daily Cap (limite journalière) bas sur le workspace Log Analytics (ex: 0.023 Go).

// ===============================================================================
// CONTRAT DE SORTIE (OUTPUTS)
// Ces valeurs permettent d'interconnecter ce module avec les autres (ex: Rôle 1).
// ===============================================================================

output appInsightsConnectionString string = 'InstrumentationKey=00000000-0000-0000-0000-000000000000;IngestionEndpoint=https://westeurope-0.in.applicationinsights.azure.com/;LiveEndpoint=https://westeurope.livediagnostics.monitor.azure.com/'
output logAnalyticsWorkspaceId string = '/subscriptions/${subscription().subscriptionId}/resourcegroups/${resourceGroup().name}/providers/Microsoft.OperationalInsights/workspaces/${resourcePrefix}-${environmentName}-law'
