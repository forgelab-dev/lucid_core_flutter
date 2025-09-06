import 'package:dio/dio.dart';

import '../../../../scripts/logger/logger.dart';

final logger = LucidLogger.instance;

class LoginInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.info("🚀 REQUEST: ${options.method} ${options.uri}");
    if (options.data != null) {
      logger.info('📦 DATA: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    logger.info(
      '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.warn(
      '❌ ERROR: ${err.response?.statusCode} ${err.requestOptions.uri}',
    );
    logger.error('💥 MESSAGE: ${err.message}');
    handler.next(err);
  }
}

class RetryInterceptor extends Interceptor {}

class ErrorHandlerInterceptor extends Interceptor {}
