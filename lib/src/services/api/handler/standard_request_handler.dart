import 'package:dio/dio.dart';

import '../../../core/core.dart';
import '../lucid_api_helpers.dart' show ErrorHelper, HeadersHelper;

/// Exécute les requêtes POST / PUT / PATCH / DELETE.
class StandardRequestHandler extends LucidAbstractRequestHandler {
  StandardRequestHandler({
    required this.dio,
    required this.method,
    required this.endpoint,
    this.data,
    this.queryParameters,
    this.headers,
  });

  final Dio dio;
  final LucidHttpMethod method;
  final String endpoint;
  final dynamic data;
  final LucidQueryParams? queryParameters;
  final LucidHttpHeaders? headers;

  @override
  Future<LucidApiClientResponse<T>> execute<T>() async {
    try {
      final response = await dio.request<dynamic>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method.value, headers: headers),
      );

      return LucidApiClientResponse.success(
        response.data as T,
        statusCode: response.statusCode,
        headers: HeadersHelper.extractHeaders(response.headers),
      );
    } catch (e) {
      return ErrorHelper.handleError<T>(e);
    }
  }
}
