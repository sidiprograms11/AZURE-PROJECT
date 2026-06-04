# Smart Notes - Frontend Web App

Cette section contient le code source de l'interface utilisateur (UI) de Smart Notes.

## Technologies
Le choix de la pile technologique (React, Vue.js, HTML/JS natif, Next.js, etc.) est à la discrétion du **Rôle 1 (App Smart Notes)**.

## Directives de Sécurité Critiques
Toute implémentation de code dans ce dossier doit respecter rigoureusement les principes suivants :

1. **Authentification Intégrée & MFA :**
   - Le frontend doit rediriger l'utilisateur vers Microsoft Entra ID pour l'authentification (utilisation de MSAL.js ou d'un wrapper adapté).
   - Veillez à ce que le flux d'authentification supporte l'authentification multifacteur (MFA) exigée par l'organisation.

2. **Sécurité des Sessions :**
   - Si des jetons (JWT) ou des cookies de session sont stockés côté client, utilisez des options sécurisées : cookies `HttpOnly`, `Secure` et `SameSite=Strict`.
   - Protégez l'application contre les vulnérabilités XSS en désinfectant les rendus dynamiques de notes utilisateur (ne pas utiliser de fonctions de rendu HTML brut non sécurisées sans assainissement préalable).

3. **HTTPS et TLS :**
   - L'application doit fonctionner exclusivement en HTTPS. Les requêtes HTTP normales doivent être redirigées automatiquement.
   - Ne pas utiliser de ressources externes non sécurisées (pas de requêtes HTTP mixtes).

4. **Aucune clé API critique côté client :**
   - N'embarquez aucun secret ou clé privée dans le build de production du frontend (les fichiers de build JS sont lisibles par n'importe quel utilisateur via les outils de développement du navigateur).
   - Toute interaction nécessitant des secrets doit être déléguée à l'API Backend.
