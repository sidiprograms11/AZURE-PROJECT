# Smart Notes - Backend API

Cette section contient le code source de l'API backend de Smart Notes.

## Technologies
Le choix de la pile technologique (Node.js/Express, .NET Core, Python/FastAPI, etc.) est à la discrétion du **Rôle 1 (App Smart Notes)**.

## Directives de Sécurité Critiques
Toute implémentation de code dans ce dossier doit respecter rigoureusement les principes suivants :

1. **Aucun secret en dur :**
   - Aucune clé d'API, mot de passe de base de données ou secret de session ne doit figurer dans le code source ou dans les fichiers de configuration commités (ex: `appsettings.json`, `.env`).
   - Utilisez la bibliothèque Azure Identity (`@azure/identity` pour Node, `Azure.Identity` pour .NET) pour vous connecter aux ressources Azure de manière passwordless.
   - Les secrets externes doivent être lus à la volée depuis Azure Key Vault via la **User-Assigned Managed Identity**.

2. **Validation stricte des entrées (Input Validation) :**
   - Validez tous les payloads JSON reçus sur les endpoints de l'API (utilisation de bibliothèques comme `zod`, `joi`, ou les annotations de validation .NET).
   - Protégez l'application contre les attaques classiques du Top 10 OWASP : Injections SQL (les ORM et l'authentification Entra-only aident à cela), injections de commandes, Cross-Site Scripting (XSS).

3. **Authentification & Autorisation :**
   - Validez les jetons (tokens) d'authentification fournis par Microsoft Entra ID pour chaque requête.
   - Appliquez un contrôle d'accès strict au niveau de la base de données : vérifiez systématiquement que l'utilisateur demandeur possède la note associée (IDOR prevention).

4. **HTTPS obligatoire :**
   - L'API doit rejeter toute requête non HTTPS et exiger TLS 1.2 minimum.
