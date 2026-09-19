import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Trace d'un appel tel que l'adaptateur simulé l'a vu passer.
///
/// Un `attempt` supérieur à 1 sur un même chemin signifie que
/// `RetryInterceptor` a rejoué la requête.
class MockCall {
  const MockCall({
    required this.method,
    required this.path,
    required this.statusCode,
    required this.attempt,
  });

  final String method;
  final String path;

  /// Code HTTP renvoyé, ou `null` quand l'échec est au niveau transport
  /// (délai dépassé, coupure réseau) et qu'aucune réponse n'existe.
  final int? statusCode;

  /// Numéro de passage sur ce chemin depuis le dernier [MockApiAdapter.reset].
  final int attempt;
}

/// Adaptateur HTTP simulé, branché sous `Dio` à la place du vrai client réseau.
///
/// Il est volontairement placé au niveau de l'adaptateur et non dans un
/// `Interceptor` : toute la chaîne d'intercepteurs de [LucidApiClient]
/// (journalisation, mapping des erreurs, retry) s'exécute donc exactement
/// comme en production. Un intercepteur simulé, lui, court-circuiterait
/// précisément ce qu'on veut démontrer.
class MockApiAdapter implements HttpClientAdapter {
  MockApiAdapter({
    this.onCall,
    this.latency = const Duration(milliseconds: 220),
  });

  /// Appelé à chaque passage, pour alimenter le journal affiché à l'écran.
  final void Function(MockCall call)? onCall;

  /// Latence simulée, pour que les états de chargement soient visibles.
  final Duration latency;

  final Map<String, int> _attempts = <String, int>{};

  /// Remet les compteurs à zéro, afin que le scénario instable échoue
  /// à nouveau au prochain essai.
  void reset() => _attempts.clear();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await Future<void>.delayed(latency);

    final path = options.path;
    final attempt = _attempts[path] = (_attempts[path] ?? 0) + 1;

    void trace(int? statusCode) {
      onCall?.call(
        MockCall(
          method: options.method,
          path: path,
          statusCode: statusCode,
          attempt: attempt,
        ),
      );
    }

    switch (path) {
      // Succès simple. Le second appel ne parviendra pas jusqu'ici : le cache
      // du client répond avant, et la réponse porte alors `fromCache: true`.
      case MockRoutes.profile:
        trace(200);
        return _json(200, <String, dynamic>{
          'id': 'usr_7f3a',
          'name': 'Fridel Prude',
          'role': 'Développeur mobile Flutter',
          'team': 'flutter',
        });

      // Échoue deux fois en 503 puis réussit : `RetryInterceptor` considère
      // les 5xx comme transitoires et rejoue la requête.
      case MockRoutes.flaky:
        if (attempt < 3) {
          trace(503);
          return _json(503, <String, dynamic>{
            'message': 'Service momentanément indisponible',
          });
        }
        trace(200);
        return _json(200, <String, dynamic>{
          'period': '2026-09',
          'deployments': 42,
          'attempts_needed': attempt,
        });

      // 401 : déclenche le rappel `onUnauthorized` et devient une
      // `AuthenticationException.unauthorized()`.
      case MockRoutes.unauthorized:
        trace(401);
        return _json(401, <String, dynamic>{'message': 'Jeton expiré'});

      // 404 : erreur définitive, jamais rejouée.
      case MockRoutes.notFound:
        trace(404);
        return _json(404, <String, dynamic>{
          'message': 'Ressource introuvable',
        });

      // Échec transport : aucune réponse HTTP. Rejoué comme les 5xx, puis
      // mappé vers `NetworkException.timeout()` une fois les essais épuisés.
      case MockRoutes.timeout:
        trace(null);
        throw DioException.connectionTimeout(
          timeout: options.connectTimeout ?? const Duration(seconds: 1),
          requestOptions: options,
        );

      default:
        trace(404);
        return _json(404, <String, dynamic>{
          'message': 'Route simulée inconnue : $path',
        });
    }
  }

  ResponseBody _json(int statusCode, Map<String, dynamic> body) {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Chemins reconnus par [MockApiAdapter].
abstract final class MockRoutes {
  static const String profile = '/me';
  static const String flaky = '/reports/monthly';
  static const String unauthorized = '/admin/keys';
  static const String notFound = '/unknown';
  static const String timeout = '/slow';
}
