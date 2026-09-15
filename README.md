# lucid_core_flutter

[![pub.dev](https://img.shields.io/pub/v/lucid_core_flutter.svg)](https://pub.dev/packages/lucid_core_flutter)
[![License: Apache 2.0](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![CI](https://github.com/forgelab-dev/lucid_core_flutter/actions/workflows/ci.yml/badge.svg)](https://github.com/forgelab-dev/lucid_core_flutter/actions/workflows/ci.yml)

Socle Flutter de LucidForge Africa : client API, authentification, stockage chiffré, thème et widgets réutilisables. Développé par [ForgeLab](https://github.com/forgelab-dev), le laboratoire open source de LucidForge Africa.

## Getting Started

Ce package est le socle commun des applications Flutter de LucidForge Africa, dont l'application mobile de [ForgeNet](https://github.com/forgelab-dev/lfa-forgenet). Il centralise les services, utilitaires et widgets réutilisables afin de garantir une cohérence technique et visuelle sur l'ensemble des projets.

Depuis pub.dev :

```bash
flutter pub add lucid_core_flutter
```

Ou, pour suivre une version précise du dépôt :

```yaml
dependencies:
  lucid_core_flutter:
    git:
      url: https://github.com/forgelab-dev/lucid_core_flutter.git
      ref: v0.0.1
```

Les versions disponibles sont listées dans les [releases](https://github.com/forgelab-dev/lucid_core_flutter/releases) et le [CHANGELOG](CHANGELOG.md).

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

Chaque API publique est documentée par des doc comments (`///`). La référence est générée automatiquement sur [pub.dev](https://pub.dev/documentation/lucid_core_flutter/latest/), ou en local avec :

```bash
dart doc
```

## Contribuer

Les contributions sont les bienvenues : voir [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Distribué sous [licence Apache 2.0](LICENSE). Copyright 2025-2026 LucidForge Africa.

La licence couvre le code, pas la marque : les noms « LucidForge Africa » et « ForgeLab » ainsi que leurs logos ne peuvent pas être utilisés pour présenter un produit dérivé comme officiel sans autorisation écrite.
