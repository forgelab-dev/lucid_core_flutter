import 'package:dio/dio.dart';

import '../../core/core.dart';
import '../../mixins/mixins.dart';
import 'handler/handler.dart';
import 'interceptors/interceptors.dart';
import 'lucid_api_helpers.dart';

export 'lucid_api_helpers.dart';

/// Client HTTP haut niveau construit sur Dio.
///
/// Fournit : cache automatique des GET (via [LucidCacheMixin]), retry sur
/// erreurs transitoires, mapping des erreurs vers la taxonomie
/// [LucidAbstractException], upload multipart, et gestion du token d'auth.
class LucidApiClient with LucidCacheMixin {
  LucidApiClient(this.config, {LucidVoidCallBack? onUnauthorized}) : dio = Dio(_buildBaseOptions(config)) {
    _configureInterceptors(onUnauthorized);
  }

  final LucidApiClientConfig config;
  final Dio dio;
  final CacheHelper _cacheKeyHelper = CacheHelper();

  static BaseOptions _buildBaseOptions(LucidApiClientConfig config) {
    return BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.timeout,
      sendTimeout: config.timeout,
      receiveTimeout: config.timeout,
      headers: {'Content-Type': LucidConstants.defaultContentType, 'User-Agent': LucidConstants.defaultUserAgent, ...config.headers},
    );
  }

  void _configureInterceptors(LucidVoidCallBack? onUnauthorized) {
    if (config.enableLogging) {
      dio.interceptors.add(LucidLoggingInterceptor());
    }
    dio.interceptors.add(ErrorHandlerInterceptor(onUnauthorized: onUnauthorized));
    dio.interceptors.add(RetryInterceptor(dio: dio, maxAttempts: config.retryAttempts, retryDelay: config.retryDelay));
    dio.interceptors.addAll(config.interceptors);
  }

  /// Définit (ou retire si `null`) le token d'authentification envoyé sur
  /// chaque requête via l'en-tête `Authorization`.
  void setAuthToken(String? token) {
    if (token == null) {
      dio.options.headers.remove('Authorization');
    } else {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<LucidApiClientResponse<T>> get<T>(
    String endpoint, {
    LucidQueryParams? queryParameters,
    LucidHttpHeaders? headers,
    bool? useCache,
    Duration? cacheTtl,
  }) async {
    final shouldCache = useCache ?? config.enableCache;

    if (!shouldCache) {
      return GetRequestHandler(dio: dio, endpoint: endpoint, queryParameters: queryParameters, headers: headers).execute<T>();
    }

    final cacheKey = _cacheKeyHelper.generateCacheKey(LucidHttpMethod.get.value, endpoint, queryParameters);
    final cached = await getCachedValue<T>(cacheKey);
    if (cached != null) {
      return LucidApiClientResponse.success(cached, fromCache: true);
    }

    final response = await GetRequestHandler(
      dio: dio,
      endpoint: endpoint,
      queryParameters: queryParameters,
      headers: headers,
    ).execute<T>();

    if (response.success && response.data != null) {
      await cacheValue(cacheKey, response.data as T, ttl: cacheTtl ?? config.cacheTimeout);
    }

    return response;
  }

  Future<LucidApiClientResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    LucidQueryParams? queryParameters,
    LucidHttpHeaders? headers,
  }) {
    return StandardRequestHandler(
      dio: dio,
      method: LucidHttpMethod.post,
      endpoint: endpoint,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
    ).execute<T>();
  }

  Future<LucidApiClientResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    LucidQueryParams? queryParameters,
    LucidHttpHeaders? headers,
  }) {
    return StandardRequestHandler(
      dio: dio,
      method: LucidHttpMethod.put,
      endpoint: endpoint,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
    ).execute<T>();
  }

  Future<LucidApiClientResponse<T>> patch<T>(
    String endpoint, {
    dynamic data,
    LucidQueryParams? queryParameters,
    LucidHttpHeaders? headers,
  }) {
    return StandardRequestHandler(
      dio: dio,
      method: LucidHttpMethod.patch,
      endpoint: endpoint,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
    ).execute<T>();
  }

  Future<LucidApiClientResponse<T>> delete<T>(
    String endpoint, {
    dynamic data,
    LucidQueryParams? queryParameters,
    LucidHttpHeaders? headers,
  }) {
    return StandardRequestHandler(
      dio: dio,
      method: LucidHttpMethod.delete,
      endpoint: endpoint,
      data: data,
      queryParameters: queryParameters,
      headers: headers,
    ).execute<T>();
  }

  Future<LucidApiClientResponse<T>> uploadFile<T>(
    String endpoint, {
    required LucidDataList<LucidUploadFile> files,
    String fieldName = 'file',
    LucidJsonMap? additionalData,
    LucidHttpHeaders? headers,
    LucidValueCallBack<double>? onSendProgress,
  }) {
    return FileUploadRequestHandler(
      dio: dio,
      endpoint: endpoint,
      files: files,
      fieldName: fieldName,
      additionalData: additionalData,
      headers: headers,
      onSendProgress: onSendProgress,
    ).execute<T>();
  }

  /// Ferme le client sous-jacent. À appeler quand le client n'est plus utilisé.
  void close({bool force = false}) => dio.close(force: force);
}
