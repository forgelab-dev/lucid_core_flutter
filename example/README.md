# Démonstration de `lucid_core_flutter`

Application exemple qui exerce `LucidApiClient` **sans aucun appel réseau réel**.

```bash
cd example
flutter pub get
flutter run          # ou : flutter test
```

## Comment la simulation fonctionne

Le client HTTP réel est remplacé par un `HttpClientAdapter` simulé, et non par
un `Interceptor` :

```dart
_client.dio.httpClientAdapter = MockApiAdapter();
```

L'adaptateur se situe **sous** toute la chaîne d'intercepteurs. Journalisation,
mapping des erreurs et rejeu automatique s'exécutent donc exactement comme en
production. Un intercepteur simulé court-circuiterait précisément ce que la
démonstration cherche à montrer.

## Scénarios

| Route | Comportement simulé | Ce qu'il démontre |
|---|---|---|
| `GET /me` | 200 | Cache : le second appel renvoie `fromCache: true` sans toucher au réseau |
| `GET /reports/monthly` | 503, 503, puis 200 | `RetryInterceptor` rejoue les 5xx transitoires |
| `GET /admin/keys` | 401 | `AuthenticationException` et rappel `onUnauthorized` |
| `GET /unknown` | 404 | Erreur définitive, jamais rejouée |
| `GET /slow` | échec transport | `NetworkException.timeout()` après épuisement des essais |

Le journal réseau affiche chaque passage réellement parvenu à l'adaptateur :
c'est là qu'on voit la différence entre une réponse servie par le cache
(aucun passage) et un rejeu (trois passages).

## Réglages propres à la démonstration

Deux écarts volontaires par rapport aux valeurs par défaut du package :

- `retryDelay` à 300 ms au lieu de 2 s, pour que le rejeu reste visible sans
  faire patienter ;
- cache **en mémoire uniquement**, sans chiffrement ni persistance, afin que
  l'exemple tourne sur les six plateformes sans dépendre du trousseau système.

Une application réelle conserve les valeurs par défaut.

## Limite connue du package

Sur un code d'erreur non explicitement mappé (404 par exemple),
`ErrorHandlerInterceptor` enveloppe l'exception avant que `ErrorHelper` ne
puisse lire le corps de la réponse. Le message renvoyé est alors le texte
interne de Dio, en anglais, au lieu du message du serveur :

```
This exception was thrown because the response has a status code of 404…
```

Les codes mappés (401, 403, 429, 5xx) et les erreurs de transport ne sont pas
concernés. Le scénario « Introuvable (404) » rend le problème visible.
