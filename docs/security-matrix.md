# Matrice de Sécurité (DICP & Principes) - Smart Notes

Cette matrice fait le lien entre les exigences de sécurité du projet, les services Azure mis en œuvre, et le rôle responsable de sa configuration au sein de l'équipe de 4 personnes.

## Légende DICP
- **D** : Disponibilité (Availability)
- **I** : Intégrité (Integrity)
- **C** : Confidentialité (Confidentiality)
- **P** : Preuve (Non-répudiation / Accountability)

---

## Matrice des Principes de Sécurité

| Principe de Sécurité | Couverture DICP | Service Azure / Composant | Rôle Responsable | Description / Implémentation |
| :--- | :---: | :--- | :---: | :--- |
| **Moindre Privilège / RBAC** | C / I | Entra ID + Azure Role Assignment | **Rôle 2** (Auth & secrets) | Rôle Azure « Key Vault Secrets User » sur le Key Vault attribué uniquement à l'identité de l'application. Pas d'accès administrateur global. |
| **MFA (Multifacteur)** | C | Entra ID (Security Defaults) | **Rôle 2** (Auth & secrets) | Exigence d'une double authentification pour les accès utilisateurs finaux et administrateurs. |
| **HTTPS uniquement** | C / I | App Service Settings (`httpsOnly=true`) | **Rôle 1** (App Smart Notes) | Redirection HTTP vers HTTPS forcée. Version minimale TLS 1.2 configurée pour rejeter les protocoles obsolètes. |
| **Secrets hors du code** | C | Azure Key Vault | **Rôle 2** (Auth & secrets) | Stockage des secrets (ex: clés d'API) hors du dépôt Git. Récupération à la volée en mémoire via l'identité managée. |
| **Connexions Passwordless** | C / I | Entra ID + Azure SQL Database | **Rôle 3** (Base de données) | Aucun mot de passe dans la chaîne de connexion SQL de l'application. Authentification via l'identité managée de l'App Service. |
| **Firewall & Isolation** | D / C / I | Pare-feu Azure SQL Database | **Rôle 3** (Base de données) | Restriction des accès réseau au serveur SQL : seules les adresses IP internes d'Azure (dont l'App Service) sont autorisées. |
| **Logs d'audit centralisés** | P | Log Analytics Workspace | **Rôle 4** (Supervision) | Collecte automatique des logs d'activité et d'audit de toutes les ressources. Rétention définie à 30 jours. |
| **Monitoring & Alerting** | D | Application Insights + Azure Monitor | **Rôle 4** (Supervision) | Surveillance de la disponibilité applicative (uptime) et alertes en cas d'erreurs HTTP 5xx ou de dépassement de budget. |
| **Protection des Menaces** | I / C | Microsoft Defender for Cloud (Gratuit) | **Rôle 4** (Supervision) | Détection continue des vulnérabilités de configuration et posture de sécurité cloud (CSPM). |
| **Validation des entrées** | I / C | Code Applicatif (Backend API) | **Rôle 1** (App Smart Notes) | Validation stricte de tous les schémas de données reçus, assainissement (sanitization) pour prévenir les injections SQL et failles XSS. |
| **Zero Trust** | D / I / C / P | Ensemble des services Azure | **Tous les Rôles** | Application du principe « Ne jamais faire confiance, toujours vérifier » au niveau réseau, identité, et données. |
| **Auto-Pause (Budget)** | D / Coût | Azure SQL Serverless Auto-Pause | **Rôle 3** (Base de données) | Mise en veille de la base de données après inactivité pour préserver le crédit étudiant (~86 €). |
