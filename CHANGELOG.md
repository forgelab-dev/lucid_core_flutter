# Changelog

## [0.5.0](https://github.com/forgelab-dev/lucid_core_flutter/compare/v0.4.0...v0.5.0) (2026-11-10)


### Fonctionnalités

* **list:** LucidSwipeActions pour agir en glissant une ligne ([bc57dff](https://github.com/forgelab-dev/lucid_core_flutter/commit/bc57dfffb5b1101fde2d1f07a0bb1c1e623c06f5))
* **list:** LucidSwipeActions pour agir en glissant une ligne ([30b1fc1](https://github.com/forgelab-dev/lucid_core_flutter/commit/30b1fc1c7e7333211ed1f847d0648346722b028a))

## [0.4.0](https://github.com/forgelab-dev/lucid_core_flutter/compare/v0.3.1...v0.4.0) (2026-11-10)


### Fonctionnalités

* **app:** LucidApp.router pour les apps à routeur déclaratif ([a135a1d](https://github.com/forgelab-dev/lucid_core_flutter/commit/a135a1ddeeed5f1d1048e43f9150bcce1cee621e))
* **app:** LucidApp.router pour les apps à routeur déclaratif ([3652ada](https://github.com/forgelab-dev/lucid_core_flutter/commit/3652ada7b13a68b6c8991eb85fe3e9d12394af13))
* **inputs:** aide, majuscules et erreur sur LucidTextField ([cacca8c](https://github.com/forgelab-dev/lucid_core_flutter/commit/cacca8ceafa8da384b7c7723fd87a2520875db38))
* **inputs:** aide, majuscules et erreur sur LucidTextField ([171dcfd](https://github.com/forgelab-dev/lucid_core_flutter/commit/171dcfd7ed095e7e5c67451096bc80d406d7e221))


### Corrections

* **navigation:** séparer push/pop pour cohabiter avec go_router ([8df015b](https://github.com/forgelab-dev/lucid_core_flutter/commit/8df015bbfb92ad635c02d521be8f6d5a95b48ff8))
* **navigation:** séparer push/pop pour cohabiter avec go_router ([10dd16a](https://github.com/forgelab-dev/lucid_core_flutter/commit/10dd16ae19e403b3c1dc0aca064b26bec5d99248))
* **theme:** ne plus confisquer le passage clair/sombre de Flutter ([87111ab](https://github.com/forgelab-dev/lucid_core_flutter/commit/87111abc5f35c08276710c54d690971c2c7c442f))
* **theme:** ne plus confisquer le passage clair/sombre de Flutter ([5fa360c](https://github.com/forgelab-dev/lucid_core_flutter/commit/5fa360c016dacacd1afcb7967643d332560c3276))

## [0.3.1](https://github.com/forgelab-dev/lucid_core_flutter/compare/v0.3.0...v0.3.1) (2026-11-09)


### Corrections

* **android:** compiler contre l'API 36 ([b2c899f](https://github.com/forgelab-dev/lucid_core_flutter/commit/b2c899f090c587a62bcf3ace50d1827954e72241))
* **android:** compiler contre l'API 36 ([5a3d4fa](https://github.com/forgelab-dev/lucid_core_flutter/commit/5a3d4fa068b68510a745254c0bbbd952417368cf))

## [0.3.0](https://github.com/forgelab-dev/lucid_core_flutter/compare/v0.2.0...v0.3.0) (2026-11-07)


### Fonctionnalités

* **widgets:** ajouter LucidCard, carte statique ou interactive ([5909453](https://github.com/forgelab-dev/lucid_core_flutter/commit/5909453ade81b2123d3a641e38e30e80f09206df))
* **widgets:** ajouter LucidCard, carte statique ou interactive ([0c3f976](https://github.com/forgelab-dev/lucid_core_flutter/commit/0c3f976d0128055a9f893444c566f1ef269729dd)), closes [#7](https://github.com/forgelab-dev/lucid_core_flutter/issues/7)

## [0.2.0](https://github.com/forgelab-dev/lucid_core_flutter/compare/v0.1.0...v0.2.0) (2026-09-19)


### Fonctionnalités

* **example:** application de démonstration de LucidApiClient ([268604d](https://github.com/forgelab-dev/lucid_core_flutter/commit/268604da2451bb005f5293b8cc6fb9b0b097a21b))
* **example:** démontrer LucidApiClient sur une API simulée ([f07f930](https://github.com/forgelab-dev/lucid_core_flutter/commit/f07f930037d1ce80472509d785fc00a7cb60151c))

## [0.1.0](https://github.com/forgelab-dev/lucid_core_flutter/compare/v0.0.1...v0.1.0) (2026-09-15)


### ⚠ BREAKING CHANGES

* le package est désormais distribué sous licence Apache 2.0.

### Fonctionnalités

* passer le package en open source sous licence Apache 2.0 et préparer pub.dev ([3e9b1cc](https://github.com/forgelab-dev/lucid_core_flutter/commit/3e9b1cc7af2a5ca0bac7ad13d73256d79b9d3f75))

## 0.0.1

* Client API HTTP (`LucidApiClient`) : GET/POST/PUT/PATCH/DELETE, upload multipart, cache-first sur les GET (via `LucidStorageManager`), retry automatique sur erreurs transitoires, mapping des erreurs vers la taxonomie `LucidAbstractException`.
* Authentification : implémentations Firebase (`LucidFirebaseAuthService`) et Supabase (`LucidSupabaseAuthService`) de `LucidAbstractAuthService`. La connexion sociale (Google/Apple) est découplée de tout SDK tiers : l'app hôte fournit les jetons via un callback (`LucidOAuthTokens`), ce qui garde le plugin léger pour les projets sans connexion sociale.
* Correction : `LucidSecureStorage.delete` effaçait tout le stockage sécurisé au lieu d'une seule clé ; le refresh token partageait la même clé que le token d'accès.
* Mise à jour des dépendances majeures (`flutter_secure_storage`, `local_auth`, `connectivity_plus`, `package_info_plus`, `device_info_plus`, `permission_handler`, `share_plus`, `flutter_local_notifications`).
* Correction majeure de compatibilité multi-plateforme : `lib.dart` exportait inconditionnellement l'implémentation web (`dart:js_interop`), ce qui cassait la compilation du plugin sur toute plateforme non-web (dont les tests). `LucidLogger` (fichier + envoi distant) et `LucidCacheStorage` (persistance disque) utilisaient `dart:io` sans garde de plateforme ; extraits derrière des implémentations conditionnelles (`LucidLogFileSink`, `LucidFileStore`) qui se dégradent proprement sur le web. `LucidDeviceInfoUtils` ne reconnaissait que Android/iOS (tout le reste retournait "Unknown") ; il reconnaît maintenant aussi Web, Windows, Linux et macOS via `device_info_plus`, sans dépendre de `dart:io`.
* Correction de `LucidConfigHelpers`/`LucidOverrideConfig` : les overrides dynamiques ne s'appliquaient qu'aux clés inconnues (le `noSuchMethod` n'était jamais atteint pour une propriété réelle comme `appName`, déjà définie par les mixins). Introduction de `LucidAbstractConfigResolver` (`core/abstracts/`), point d'indirection unique utilisé par tous les mixins de config, que `LucidOverrideConfig` redéfinit pour donner la priorité aux overrides — sans dupliquer la logique sur chacune des 70+ propriétés. `LucidConfigHelpers` retourne aussi `null` proprement (au lieu de lever une exception) pour une propriété dynamique inconnue.
* Thème par défaut (`LucidThemes.defaultLight`/`defaultDark`) aligné sur la charte graphique LucidForge Africa (navy `#020617`, or `#D4A017`, textes/gris de la palette officielle).
* `LucidCacheStorage` chiffre (AES-256-GCM) et compresse (gzip) réellement les entrées persistées sur disque quand `LucidCacheConfig.encryptionEnabled`/`compressionEnabled` sont actifs (nouveau `LucidCacheCodec`, clé générée une fois puis conservée dans le stockage sécurisé). Ces flags étaient déclarés mais totalement ignorés auparavant.
* Correction critique : `LucidCacheItem.toMap()` plaçait des `DateTime`/`Duration`/enum bruts dans la map avant `jsonEncode`, ce qui faisait planter `toJson()`/`exportToFile()` à chaque appel (persistance disque et export du cache étaient donc cassés).
* Correction : `LucidConstants.defaultCountryCode` valait `"FR"` alors que le reste des valeurs par défaut (locale `fr_BJ`, devise `XOF`/`F CFA`) cible le Bénin ; corrigé en `"BJ"`.
* Correction : `LucidEnvironmentConfig.current` vérifiait `kDebugMode` avant `FLUTTER_ENV=staging`, rendant le mode staging inatteignable en debug.
* Nettoyage des extensions (`lucid_extensions.dart`) : plusieurs méthodes (`List.take/skip`, `num.clamp`, `TextEditingController.clear`) étaient totalement inaccessibles car masquées par des méthodes du même nom déjà déclarées par le type de base — supprimées. `num.formatted` (séparateur de milliers) pouvait insérer un espace au milieu de la partie décimale pour les nombres à 6+ décimales — corrigé.
* Dédoublonnage : `num.lerp`/`LucidMathUtils.lerp` et `num.roundToDecimals`/`LucidMathUtils.roundToDecimals` étaient deux implémentations indépendantes (avec un comportement différent pour `lerp` : clampée vs non-clampée) ; `num.*` délègue maintenant à `LucidMathUtils`. `context.isDarkTheme` lisait `Theme.of(context)` alors que `context.currentTheme` (même extension) lit `LucidThemeNotifier` — deux sources de vérité pouvant diverger ; unifié sur `currentTheme`.
* `LucidCacheMixin`/`LucidServiceCacheMixin` : `clearClassCache()` et `defaultServiceTags` ne servaient à rien car `cacheValue`/`cacheOrGetValue` ne posaient jamais de tag — corrigé, les valeurs sont maintenant taguées.
* Première série de widgets (`lib/src/widgets/`), tous branchés sur le thème et `LucidL10n` (pas de texte dupliqué) : `LucidApp` (câble thème + l10n en un point d'entrée), `LucidListManager` (liste/grille/carrousel, pull-to-refresh, pagination infinie, un seul widget selon `LucidListMode`), `LucidNavigationManager` (bottom bar/rail/drawer permanent/onglets d'app bar/menu déroulant, adaptatif selon la taille d'écran via `LucidNavMode.auto`), `LucidButton` (primaire/secondaire/contour/texte, état de chargement), `LucidTextField`/`.email`/`.password` (validation via les extensions `String` déjà existantes), `LucidEmptyState`/`LucidErrorState` (texte par défaut tiré de `LucidL10n`, définition unique réutilisée partout, y compris par `LucidListManager`).
* TODO: gestion du cache/storage (migration inter-versions, listing des clés API), reste des widgets (dropdown/sélecteur/popup, cartes).
