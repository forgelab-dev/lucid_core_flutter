import 'package:dio/dio.dart';

import '../../../core/core.dart';
import '../lucid_api_helpers.dart' show ErrorHelper, FormDataHelper, HeadersHelper;

class FileUploadRequestHandler extends LucidAbstractRequestHandler {
  FileUploadRequestHandler({
    required this.dio,
    required this.endpoint,
    required this.files,
    this.fieldName = 'file',
    this.additionalData,
    this.headers,
    this.onSendProgress,
  });

  final Dio dio;
  final String endpoint;
  final LucidDataList<LucidUploadFile> files;
  final String fieldName;
  final LucidJsonMap? additionalData;
  final LucidHttpHeaders? headers;
  final LucidValueCallBack<double>? onSendProgress;

  @override
  Future<LucidApiClientResponse<T>> execute<T>() async {
    try {
      final formData = FormDataHelper.createFormData(files, fieldName, additionalData);

      final response = await dio.post<dynamic>(
        endpoint,
        data: formData,
        options: Options(headers: headers),
        onSendProgress: onSendProgress == null ? null : (sent, total) => onSendProgress!(total > 0 ? sent / total : 0),
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
