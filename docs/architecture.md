# Architecture de Référence - Smart Notes

Ce document décrit l'architecture technique globale et les flux de données du projet **Smart Notes**, conçus selon les principes du **Zero Trust** et du **Moindre privilège**.

## Schéma Conceptuel des Flux

```
   [Utilisateur]
         │
         │ (1) Requête HTTPS (TLS 1.2+)
         ▼
 ┌─────────────────┐       (2) Authentification / MFA
 │   Entra ID      │◄─────────────────────────────────┐
 └─────────────────┘                                  │
                                                      │
 ┌─────────────────┐                                  │
 │   App Service   │◄─────────────────────────────────┘
 │  (Smart Notes)  │
 └────────┬────────┘
          │
          ├──────────────────────────┐
          │ (3) Lecture secrets      │ (4) Requête SQL (Passwordless)
          ▼                          ▼
 ┌─────────────────┐       ┌──────────────────┐
 │    Key Vault    │       │   Azure SQL DB   │
 └─────────────────┘       └──────────────────┘
          │                          │
          └────────────┬─────────────┘
                       │
                       │ (5) Logs d'audit & métriques (Diagnostics)
                       ▼
             ┌────────────────────┐
             │   Azure Monitor    │
             │ (Log Analytics) &  │
             │ App Insights       │
             └────────────────────┘
```

## Description des Flux

1. **Accès Utilisateur (HTTPS uniquement) :**
   L'utilisateur accède au site web de Smart Notes hébergé sur Azure App Service. La communication est chiffrée de bout en bout en transit via HTTPS, avec une exigence minimale de **TLS 1.2** et désactivation de FTPS.

2. **Authentification & MFA (Entra ID) :**
   L'authentification de l'utilisateur final s'effectue via Microsoft Entra ID. La politique de sécurité exige l'activation de l'authentification multifacteur (MFA) via les *Security Defaults* ou le contrôle d'accès conditionnel.

3. **Accès aux Secrets (Key Vault via Managed Identity) :**
   L'application Smart Notes s'exécute sous une **Identité Managée Assignée par l'Utilisateur (User-Assigned Managed Identity)**. Aucun secret Azure (comme les clés ou chaînes de connexion) n'est stocké dans le code source de l'application ou dans les fichiers de configuration de production. L'App Service s'authentifie auprès d'Azure Key Vault en utilisant cette identité, récupérant uniquement les clés nécessaires au fonctionnement de l'application (ex: clés de chiffrement de cookies, API tierces).

4. **Accès Base de Données (Azure SQL Passwordless) :**
   Pour la connexion à la base de données Azure SQL Database, l'application utilise l'authentification **Entra-only / Passwordless**. La base de données SQL n'accepte pas de mot de passe SQL local. Elle utilise directement l'identité managée de l'App Service comme administrateur ou utilisateur de base de données pour accorder les permissions d'accès, respectant le principe du moindre privilège.

5. **Supervision, Audit et Protection (Diagnostics & Defender) :**
   - Toutes les ressources (Key Vault, SQL, App Service) exportent leurs journaux de diagnostic et d'audit vers le **Log Analytics Workspace**.
   - **Application Insights** capture les métriques applicatives, les temps de réponse et les erreurs.
   - **Microsoft Defender for Cloud** (Tier gratuit CSPM) assure le contrôle de conformité continue de l'infrastructure cloud pour détecter les mauvaises configurations de sécurité.
