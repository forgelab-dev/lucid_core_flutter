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

1. Forker le dépôt et créer une branche : `feat/ma-fonctionnalite`, `fix/correction`, `refactor/...`.
2. Commiter avec [Conventional Commits](https://www.conventionalcommits.org/) en français : `feat(scope): description`.
3. Pousser la branche et ouvrir une Pull Request vers `master`.
4. La CI (analyse + tests) doit passer.
5. Un mainteneur relit et fusionne.

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