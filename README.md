# Smart Notes - Projet de Sécurité Cloud Azure (Squelette de Démarrage)

Bienvenue sur le projet **Smart Notes** ! Ce dépôt contient la structure initiale et les fichiers "squelettes" (stubs) pour déployer notre infrastructure sécurisée sur Microsoft Azure. 

Ce README explique en détail le rôle de chaque fichier, qui en est le propriétaire et comment collaborer au sein de notre équipe de 4 personnes.

---

## 📁 Description Détaillée des Fichiers du Projet

Voici l'arborescence complète créée et ce que fait chaque fichier :

### 1. Racine du Projet
*   **[README.md](file:///C:/Users/sidig/.gemini/antigravity/scratch/smart-notes/README.md) (Ce fichier) :** Guide d'accueil général du projet. Il décrit l'architecture, attribue les rôles, définit les règles de budget et explique comment pousser sa partie sur Git.
*   **[.gitignore](file:///C:/Users/sidig/.gemini/antigravity/scratch/smart-notes/.gitignore) :** Fichier critique pour la sécurité. Il indique à Git d'ignorer les dossiers de build (`node_modules`, `bin/`, `obj/`), mais surtout tous les fichiers locaux pouvant contenir des secrets (`.env`, `secrets.json`, les clés privées `.pem`, les configurations de profils Azure). **Objectif : ZÉRO secret poussé par erreur.**

### 2. Documentation Globale (`docs/`)
*   **[docs/architecture.md](file:///C:/Users/sidig/.gemini/antigravity/scratch/smart-notes/docs/architecture.md) :** Explique comment les composants cloud communiquent entre eux (l'utilisateur accède au site web via HTTPS, le site web utilise une identité managée pour lire la base de données Azure SQL sans mot de passe et récupérer les secrets depuis Key Vault, et toutes les ressources envoient leurs logs vers Azure Monitor).
*   **[docs/security-matrix.md](file:///C:/Users/sidig/.gemini/antigravity/scratch/smart-notes/docs/security-matrix.md) :** Tableau synthétique reliant chaque principe de sécurité requis (MFA, HTTPS, Key Vault, Zéro mot de passe, Firewall, Logs) au service Azure concerné et au rôle responsable de sa mise en œuvre.
*   **[docs/threat-model.md](file:///C:/Users/sidig/.gemini/antigravity/scratch/smart-notes/docs/threat-model.md) :** Squelette d'analyse de menaces selon la méthode **STRIDE** (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege), avec des exemples concrets pour notre projet, prêts à être complétés par l'équipe.

### 3. Infrastructure Azure Bicep (`infra/`)
Bicep est le langage utilisé pour décrire nos ressources Azure sous forme de code (Infrastructure as Code - IaC).
*   **[infra/main.bicep](file:///C:/Users/sidig/.gemini/antigravity/scratch/smart-notes/infra/main.bicep) (L'Orchestrateur) :** C'est le fichier principal. Il n'implémente pas les ressources lui-même, mais il appelle les 4 modules des membres de l'équipe et les câble entre eux. Par exemple, il prend l'identité créée par le Rôle 2 et la transmet à l'App Service du Rôle 1 et à la Base de données du Rôle 3.
*   **[infra/parameters/dev.bicepparam](file:///C:/Users/sidig/.gemini/antigravity/scratch/smart-notes/infra/parameters/dev.bicepparam) :** Fichier contenant les valeurs des variables d'environnement pour le développement (comme la région ou le préfixe des ressources).
*   **Dossier `infra/modules/` (Les Modules par Rôle) :**
    *   **[app-service.bicep](file:///C:/Users/sidig/.gemini/antigravity/scratch/smart-notes/infra/modules/app-service.bicep) (Rôle 1 - App Smart Notes) :** Squelette pour créer l'hébergement web (App Service Plan + Web App). Il consomme les configurations des autres modules (sécurité HTTPS, identité assignée, connexion SQL).
    *   **[identity-keyvault.bicep](file:///C:/Users/sidig/.gemini/antigravity/scratch/smart-notes/infra/modules/identity-keyvault.bicep) (Rôle 2 - Auth & Secrets) :** Squelette pour créer l'identité de l'application et le coffre-fort Key Vault. Il doit accorder les droits d'accès à l'identité selon le principe du moindre privilège.
    *   **[sql-database.bicep](file:///C:/Users/sidig/.gemini/antigravity/scratch/smart-notes/infra/modules/sql-database.bicep) (Rôle 3 - Base de données) :** Squelette pour créer le serveur SQL et la base de données en mode Serverless. Il configure la connexion par identité Entra ID (Passwordless, pas de mot de passe SQL en dur).
    *   **[monitoring.bicep](file:///C:/Users/sidig/.gemini/antigravity/scratch/smart-notes/infra/modules/monitoring.bicep) (Rôle 4 - Supervision) :** Squelette pour créer l'espace Log Analytics (centralisation des logs), Application Insights (supervision web) et configurer Defender for Cloud (sécurité gratuite).

### 4. Automatisation CI/CD (`.github/workflows/`)
*   **[infra-deploy.yml](file:///C:/Users/sidig/.gemini/antigravity/scratch/smart-notes/.github/workflows/infra-deploy.yml) :** Pipeline GitHub Actions déclenché **manuellement** qui déploie toute notre infrastructure Azure à partir des fichiers Bicep.
*   **[app-deploy.yml](file:///C:/Users/sidig/.gemini/antigravity/scratch/smart-notes/.github/workflows/app-deploy.yml) :** Pipeline déclenché lors d'une modification de l'application dans le dossier `app/` pour déployer le code sur l'hébergement Azure existant.
*   **[.gitkeep](file:///C:/Users/sidig/.gemini/antigravity/scratch/smart-notes/.github/workflows/.gitkeep) :** Fichier vide servant uniquement à forcer Git à conserver ce dossier vide au démarrage.

### 5. Application Code (`app/`)
*   **[app/backend/README.md](file:///C:/Users/sidig/.gemini/antigravity/scratch/smart-notes/app/backend/README.md) :** Consignes de sécurité et d'architecture pour le développement de l'API backend (validation des inputs, zéro secret stocké en dur, lecture des secrets depuis le Key Vault via l'identité managée).
*   **[app/frontend/README.md](file:///C:/Users/sidig/.gemini/antigravity/scratch/smart-notes/app/frontend/README.md) :** Consignes de sécurité pour l'interface utilisateur web (redirection vers Entra ID pour l'authentification/MFA, protection contre les failles XSS, HTTPS obligatoire).

---

## 👥 Qui fait quoi ? (Tableau des Rôles)

Chaque membre travaille en priorité sur sa zone dédiée :

| Membre de l'équipe | Rôle Attribué | Fichier de travail prioritaire | Tâches principales |
| :--- | :--- | :--- | :--- |
| **Membre 1** | Rôle 1 : App Smart Notes | `infra/modules/app-service.bicep` | Gérer le site Web App, l'hébergement, forcer le HTTPS/TLS 1.2, et déployer le code applicatif. |
| **Membre 2** (Auteur) | Rôle 2 : Auth & Secrets | `infra/modules/identity-keyvault.bicep` | Gérer l'Identité Managée, le Key Vault, associer les rôles de moindre privilège (RBAC). |
| **Membre 3** | Rôle 3 : Base de Données | `infra/modules/sql-database.bicep` | Gérer Azure SQL, forcer l'authentification Entra ID (Passwordless), configurer le pare-feu. |
| **Membre 4** | Rôle 4 : Supervision | `infra/modules/monitoring.bicep` | Configurer la centralisation des logs (Log Analytics), les métriques (App Insights), et Defender. |

---

## 🚦 Comment collaborer sur Git ? (Pas à Pas)

Pour éviter que le code d'un membre n'écrase celui d'un autre :

1.  **Cloner le dépôt** créé par le groupe.
2.  **Créer sa propre branche locale** avant de commencer à écrire :
    ```bash
    git checkout -b feat/roleN-sujet
    # Exemple pour le rôle 2 : git checkout -b feat/role2-keyvault
    ```
3.  **Travailler exclusivement dans son fichier de module** sous `infra/modules/`. *Ne modifiez pas le fichier d'un autre membre.*
4.  **Respecter les outputs du contrat** : les noms des outputs de votre fichier Bicep ne doivent pas changer car l'orchestrateur `main.bicep` s'appuie dessus pour compiler le projet global.
5.  **Pousser sa branche** et ouvrir une **Pull Request (PR)** sur GitHub.
6.  **Faire valider par un relecteur** : La branche `main` est protégée. Il faut au moins 1 approbation de PR par un autre membre de l'équipe avant de pouvoir fusionner son travail dans le code commun.

---

## 💡 Règles Importantes pour le Budget Étudiant
Chacun possède un crédit Azure individuel limité (~86 €). Pour éviter de tout consommer en quelques jours, nous avons défini des limites économiques par défaut :
*   **Base de données SQL :** Configurée par défaut en mode Serverless avec mise en veille automatique (AutoPause) après 60 minutes d'inactivité.
*   **App Service Plan :** Configuré au tarif gratuit (SKU `F1`).
*   **Supervision :** Log Analytics possède une limite journalière stricte (Daily Cap) d'ingestion à 23 Mo par jour.
*   **Defender for Cloud :** Nous utilisons uniquement la version gratuite (CSPM fondamental). **Ne pas activer de plans Defender payants.**
*   **Resource Group unique :** `rg-smart-notes-dev` hébergera toutes les ressources de test. Pensez à supprimer ce groupe après la démonstration finale pour stopper toute facturation.

---

## ⚙️ Commandes de Déploiement Local

Pour tester son infrastructure localement avec Azure CLI :

1.  Se connecter à son compte :
    ```powershell
    az login
    ```
2.  Créer le groupe de ressources de test :
    ```powershell
    az group create --name rg-smart-notes-dev --location westeurope
    ```
3.  Déployer l'ensemble :
    ```powershell
    az deployment group create --resource-group rg-smart-notes-dev --template-file ./infra/main.bicep --parameters ./infra/parameters/dev.bicepparam
    ```
