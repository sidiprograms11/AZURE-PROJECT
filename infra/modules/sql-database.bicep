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

// TODO : Le propriétaire du Rôle 3 doit créer ici :
// 1. Un serveur logique Azure SQL avec authentification Entra-only (sans mot de passe).
// 2. Une base de données Azure SQL configurée en Serverless (General Purpose).
// 3. Une règle de pare-feu autorisant l'accès depuis les services Azure (0.0.0.0).

// ===============================================================================
// CONTRAT DE SORTIE (OUTPUTS)
// Ces valeurs permettent d'interconnecter ce module avec les autres (ex: Rôle 1).
// ===============================================================================

output sqlServerName string = '${resourcePrefix}-${environmentName}-sql'
output sqlServerFqdn string = '${resourcePrefix}-${environmentName}-sql.database.windows.net'
output sqlDatabaseName string = '${resourcePrefix}-${environmentName}-db'
