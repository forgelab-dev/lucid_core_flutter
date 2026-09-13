import 'package:dio/dio.dart';

import '../../../core/core.dart';
import '../../../functions/functions.dart';

final logger = LucidLogger();

class LucidLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.info("🚀 REQUEST: ${options.method} ${options.uri}");
    if (options.data != null) {
      logger.info('📦 DATA: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    logger.info('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.warn('❌ ERROR: ${err.response?.statusCode} ${err.requestOptions.uri}');
    logger.error('💥 MESSAGE: ${err.message}');
    handler.next(err);
  }
}

/// Enrichit les [DioException] avec la taxonomie d'exceptions Lucid
/// et déclenche les effets de bord globaux (ex: déconnexion sur 401).
class ErrorHandlerInterceptor extends Interceptor {
  ErrorHandlerInterceptor({this.onUnauthorized});

  /// Appelé lorsqu'une réponse 401 est reçue, pour permettre par exemple
  /// de nettoyer les tokens stockés et forcer une reconnexion.
  final LucidVoidCallBack? onUnauthorized;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final enriched = err.copyWith(error: _mapToLucidException(err));

    if (err.response?.statusCode == 401) {
      onUnauthorized?.call();
    }

    handler.next(enriched);
  }

  LucidAbstractException _mapToLucidException(DioException err) {
    final statusCode = err.response?.statusCode;
    final url = err.requestOptions.uri.toString();

    if (statusCode == 401) return AuthenticationException.unauthorized();
    if (statusCode == 403) return AuthenticationException.permissionDenied();
    if (statusCode == 429) return NetworkException.rateLimitExceeded();
    if (statusCode == 502) return NetworkException.badGateway();
    if (statusCode == 503) return NetworkException.serviceUnavailable();
    if (statusCode != null && statusCode >= 500) return NetworkException.serverError(statusCode, url: url);

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException.timeout();
      case DioExceptionType.connectionError:
        return NetworkException.noInternet();
      default:
        return NetworkException(err.message ?? 'Erreur réseau inconnue', url: url, statusCode: statusCode);
    }
  }
}

/// Réessaie automatiquement les requêtes qui échouent pour des raisons
/// transitoires (timeout, coupure réseau, erreur serveur 5xx).
class RetryInterceptor extends Interceptor {
  RetryInterceptor({required this.dio, this.maxAttempts = 3, this.retryDelay = const Duration(seconds: 2)});

  final Dio dio;
  final int maxAttempts;
  final Duration retryDelay;

  static const String _attemptKey = 'lucid_retry_attempt';

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final attempt = (err.requestOptions.extra[_attemptKey] as int?) ?? 0;

    if (!_isRetryable(err) || attempt >= maxAttempts) {
      handler.next(err);
      return;
    }

    await Future<void>.delayed(retryDelay * (attempt + 1));
    err.requestOptions.extra[_attemptKey] = attempt + 1;

    try {
      final response = await dio.fetch<dynamic>(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    } catch (retryError, stackTrace) {
      handler.next(
        DioException(requestOptions: err.requestOptions, error: retryError, stackTrace: stackTrace),
      );
    }
  }

  bool _isRetryable(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        return statusCode != null && statusCode >= 500;
      default:
        return false;
    }
  }
}
