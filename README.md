# lucid_core_flutter

[![pub.dev](https://img.shields.io/badge/pub.dev-lucid_core_flutter-blue)](https://pub.dev/packages/lucid_core_flutter)

Core des projets Flutter de LucidForge Africa — Fournit des utilitaires, widgets et services communs pour tous les projets LucidForge.

## Getting Started

Ce package est le socle commun des applications Flutter de LucidForge Africa. Il centralise les services, utilitaires et widgets réutilisables afin de garantir une cohérence technique et visuelle sur l'ensemble des projets.

Pour l'ajouter à votre projet :

```yaml
dependencies:
  lucid_core_flutter: ^0.0.1
```

Pour commencer avec le développement Flutter, consultez la [documentation en ligne](https://docs.flutter.dev), qui propose des tutoriels, des exemples, des guides sur le développement mobile et une référence complète de l'API.

## Features

- **Client API HTTP** (`LucidApiClient`) : GET/POST/PUT/PATCH/DELETE, upload multipart, cache-first sur les GET, retry automatique sur erreurs transitoires et mapping des erreurs vers la taxonomie `LucidAbstractException`.
- **Authentification** : implémentations Firebase (`LucidFirebaseAuthService`) et Supabase (`LucidSupabaseAuthService`) de `LucidAbstractAuthService`, avec connexion sociale découplée de tout SDK tiers.
- **Stockage & persistance** : stockage sécurisé (`LucidSecureStorage`), cache chiffré (AES-256-GCM) et compressé (gzip) sur disque (`LucidCacheStorage`), préférences partagées.
- **Configuration** : résolveur de configuration unifié (`LucidAbstractConfigResolver`) avec overrides dynamiques, environnement (dev/staging/prod) et constantes par défaut.
- **Thème** : thèmes clair/sombre alignés sur la charte graphique LucidForge Africa (navy `#020617`, or `#D4A017`).
- **Widgets** : `LucidApp`, `LucidListManager`, `LucidNavigationManager`, `LucidButton`, `LucidTextField`, `LucidEmptyState`, `LucidErrorState` — tous branchés sur le thème et la localisation.
- **Internationalisation** : localisation française (`LucidL10n`) et extensions utilitaires (`String`, `num`, `BuildContext`, etc.).

## API Reference

La référence complète de l'API est disponible dans la [documentation du package](https://github.com/forgelab-dev/lucid_core_flutter/wiki).

## License

Copyright (c) 2024 LucidForge Africa. Tous droits réservés. Voir le fichier [LICENSE](LICENSE) pour plus de détails.