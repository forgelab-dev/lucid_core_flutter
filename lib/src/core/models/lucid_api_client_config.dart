import 'package:dio/dio.dart';

import '../constants/constants.dart' show LucidHttpHeaders;

class LucidApiClientConfig {
  final String baseUrl;
  final Duration timeout;
  final LucidHttpHeaders headers;
  final List<Interceptor> interceptors;
  final bool enableCache;
  final Duration cacheTimeout;
  final bool enableLogging;
  final int retryAttempts;
  final Duration retryDelay;

  LucidApiClientConfig({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 60),
    this.headers = const {},
    this.interceptors = const [],
    this.enableCache = true,
    this.cacheTimeout = const Duration(minutes: 5),
    this.enableLogging = false,
    this.retryAttempts = 3,
    this.retryDelay = const Duration(seconds: 2),
  });
}
