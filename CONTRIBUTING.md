# Contribuer à lucid_core_flutter

Merci de vouloir contribuer au core Flutter de LucidForge. Ce document décrit le processus à suivre pour que chaque contribution soit intégrée proprement.

## Prérequis

- Flutter stable (voir `pubspec.yaml` pour la version minimale du SDK)
- Dart 3.8+

## Installation

```bash
flutter pub get
```

## Convention de code

- Le projet suit `analysis_options.yaml` (flutter_lints + règles strictes : `strict-casts`, `strict-inference`, `strict-raw-types`).
- Exécuter `dart format` avant de soumettre.
- Nommage : préfixe `Lucid` pour les classes publiques, fichiers `lucid_*.dart` en snake_case.
- Une classe publique par fichier ; les fichiers barrel (`*.dart` d'agrégation) exportent les API publiques du dossier.
- Documentation : doc comment (`///`) sur toute API publique.
- Pas de `print`/`debugPrint` dans le code livré — utiliser `LucidLogger`.

## Tests

Toute nouvelle fonctionnalité ou correction doit être couverte par des tests :

```bash
flutter test
```

Vérifier aussi l'analyse statique avant de pousser :

```bash
flutter analyze
```

## Processus de contribution

1. Forker le dépôt (contributeurs externes) ou créer une branche depuis `master` (membres de l'organisation `forgelab-dev`) : `feat/ma-fonctionnalite`, `fix/correction`, `refactor/...`.
2. Commiter avec [Conventional Commits](https://www.conventionalcommits.org/) en français : `feat(scope): description`.
3. Pousser la branche et ouvrir une Pull Request vers `master`.
4. La CI (analyse + tests) doit passer.
5. Un mainteneur relit et fusionne.

## Versions et releases

Les versions sont gérées automatiquement par [release-please](https://github.com/googleapis/release-please) (workflow `.github/workflows/release.yml`) :

1. À chaque merge sur `master`, le workflow ouvre ou met à jour une PR « publier la version X.Y.Z ». Elle incrémente `version` dans `pubspec.yaml` et complète `CHANGELOG.md` à partir des messages de commit.
2. Merger cette PR crée le tag `vX.Y.Z` et la release GitHub correspondante.
3. Le tag déclenche le workflow `.github/workflows/publish.yml`, qui publie la version sur [pub.dev](https://pub.dev/packages/lucid_core_flutter) après analyse et tests.

Le type de commit détermine la version (avant la 1.0.0) : `feat` → mineure, `fix` / `perf` → patch, `!` ou `BREAKING CHANGE` → mineure. Les commits `docs`, `style`, `test`, `chore`, `ci` et `build` ne déclenchent pas de release.

Ne jamais modifier la version ni le CHANGELOG à la main, ni créer de tag manuellement.

## Structure du projet

- `lib/src/core/` — abstracts, constantes, helpers, modèles, thèmes, utilitaires
- `lib/src/functions/` — logger et sinks
- `lib/src/mixins/` — mixins de configuration et de cache
- `lib/src/provider/` — providers (thème)
- `lib/src/services/` — API, auth (Firebase/Supabase), stockage, manager
- `lib/src/widgets/` — widgets partagés (app, boutons, feedback, inputs, listes, navigation)
- `lib/l10n/` — traductions FR/EN (fichiers ARB + code généré)
- `test/` — tests unitaires et de plateforme

## Signalement de bugs

Ouvrir une issue avec : la version du package, la plateforme concernée, un exemple minimal de reproduction et le résultat attendu vs obtenu.