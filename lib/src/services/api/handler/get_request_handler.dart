import 'package:dio/dio.dart';

import '../../../core/core.dart';
import '../lucid_api_helpers.dart' show ErrorHelper, HeadersHelper;

class GetRequestHandler extends LucidAbstractRequestHandler {
  GetRequestHandler({required this.dio, required this.endpoint, this.queryParameters, this.headers});

  final Dio dio;
  final String endpoint;
  final LucidQueryParams? queryParameters;
  final LucidHttpHeaders? headers;

  @override
  Future<LucidApiClientResponse<T>> execute<T>() async {
    try {
      final response = await dio.get<dynamic>(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
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
