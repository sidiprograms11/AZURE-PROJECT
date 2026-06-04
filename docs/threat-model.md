# Modélisation des Menaces (STRIDE) - Smart Notes

Ce document présente l'analyse préliminaire des menaces sur l'application **Smart Notes** selon la méthodologie STRIDE.

## Analyse des Menaces par Catégorie

### 1. Spoofing (Usurpation d'identité)
*L'attaquant se fait passer pour un utilisateur légitime ou pour un service cloud.*

*   **Menace 1 :** Un attaquant intercepte des identifiants utilisateurs en clair lors d'une session non sécurisée.
    *   *Atténuation :* HTTPS obligatoire avec TLS 1.2+ sur l'App Service. Redirection automatique HTTP vers HTTPS.
*   **Menace 2 (À compléter par l'équipe) :** Un attaquant tente d'usurper l'identité de l'application auprès d'Azure SQL.
    *   *Atténuation :* Authentification passwordless via l'Identité Managée (User-Assigned Managed Identity) liée à l'App Service dans Entra ID.

### 2. Tampering (Altération de données)
*L'attaquant modifie les données sur le disque, en transit, ou en mémoire.*

*   **Menace 1 :** Altération des notes privées directement dans la base de données SQL.
    *   *Atténuation :* Accès SQL uniquement via l'identité managée avec les privilèges SQL stricts (lecture/écriture uniquement sur les tables concernées, pas d'accès sa).
*   **Menace 2 (À compléter par l'équipe) :** Modification malveillante du code de l'application déployée.
    *   *Atténuation :* Protection de la branche `main` dans GitHub et déploiement uniquement par pipeline automatisé (CI/CD) utilisant des credentials sécurisés (GitHub Secrets).

### 3. Repudiation (Répudiation)
*L'attaquant effectue une action malveillante mais le système ne peut pas prouver qu'il en est l'auteur.*

*   **Menace 1 :** Un utilisateur ou un administrateur supprime des notes et nie l'action.
    *   *Atténuation :* Journalisation applicative des actions CRUD clés et exportation obligatoire des logs vers Log Analytics.
*   **Menace 2 (À compléter par l'équipe) :** Modification des secrets dans le Key Vault sans traçabilité.
    *   *Atténuation :* Activation des journaux d'audit de diagnostic sur Azure Key Vault envoyés vers le Log Analytics Workspace.

### 4. Information Disclosure (Divulgation d'informations)
*L'attaquant accède à des données confidentielles auxquelles il ne devrait pas avoir accès.*

*   **Menace 1 :** Fuite de clés d'API ou de secrets d'intégration commits dans le code source de l'application.
    *   *Atténuation :* Fichier `.gitignore` configuré rigoureusement. Aucun secret dans le code source. Utilisation d'Azure Key Vault pour stocker les secrets hors du code.
*   **Menace 2 (À compléter par l'équipe) :** Un attaquant accède aux notes privées d'un autre utilisateur en modifiant l'ID de la note dans l'URL (vulnérabilité IDOR).
    *   *Atténuation :* Validation stricte des entrées et contrôle d'accès au niveau applicatif (vérifier que l'utilisateur connecté est le propriétaire de la note demandée).

### 5. Denial of Service (Déni de service)
*L'attaquant tente de rendre le service indisponible.*

*   **Menace 1 :** Une surcharge de requêtes SQL sature la base de données et rend le site indisponible.
    *   *Atténuation :* Mode SQL Serverless configuré avec mise à l'échelle automatique (auto-scaling) et alertes de budget Azure Monitor pour détecter les anomalies de trafic.
*   **Menace 2 (À compléter par l'équipe) :** Inondation de requêtes HTTP sur le frontend.
    *   *Atténuation :* Configuration de limites de taux (rate limiting) dans le code applicatif et mise en place d'alertes Azure Monitor sur le taux d'erreur 5xx.

### 6. Elevation of Privilege (Élévation de privilèges)
*L'attaquant obtient des droits d'accès supérieurs à ceux qui lui sont normalement attribués.*

*   **Menace 1 :** L'application Web est compromise et l'attaquant accède à la base de données SQL avec des privilèges d'administrateur (DBA).
    *   *Atténuation :* Moindre privilège RBAC : l'identité managée de l'App Service possède uniquement le rôle nécessaire pour exécuter des requêtes applicatives (ex: pas de privilèges sysadmin ou db_owner).
*   **Menace 2 (À compléter par l'équipe) :** Un utilisateur normal accède au panneau d'administration applicatif.
    *   *Atténuation :* Gestion des rôles applicatifs basée sur les claims Entra ID ou contrôle d'accès RBAC applicatif robuste.
