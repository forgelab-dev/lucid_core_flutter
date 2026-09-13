import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core/core.dart';

class CacheHelper {
  String generateCacheKey(String method, String endpoint, LucidQueryParams? queryParameters) {
    final buffer = StringBuffer("${method}_$endpoint");
    if (queryParameters?.isNotNullOrEmpty ?? false) {
      buffer.write('_${queryParameters?.entries.map((e) => '${e.key}=${e.value}').join('&')}');
    }
    return buffer.toString();
  }
}

class HeadersHelper {
  static LucidHttpHeaders extractHeaders(Headers headers) {
    final result = <String, String>{};
    headers.forEach((key, values) {
      if (values.isNotEmpty) result[key] = values.first;
    });
    return result;
  }
}

class ErrorHelper {
  static LucidApiClientResponse<T> handleError<T>(dynamic error) {
    if (error is DioException) {
      return _handleDioException<T>(error);
    }
    return LucidApiClientResponse.error('Erreur inattendue: $error');
  }

  static LucidApiClientResponse<T> _handleDioException<T>(DioException error) {
    final enriched = error.error;
    if (enriched is LucidAbstractException) {
      return LucidApiClientResponse.error(enriched.message, statusCode: error.response?.statusCode);
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return LucidApiClientResponse.error('Délai d\'attente dépassé', statusCode: 408);
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 500;
        final message = _getErrorMessage(error.response?.data) ?? 'Erreur serveur';
        return LucidApiClientResponse.error(message, statusCode: statusCode);
      case DioExceptionType.cancel:
        return LucidApiClientResponse.error('Requête annulée');
      case DioExceptionType.connectionError:
        return LucidApiClientResponse.error('Erreur de connexion');
      default:
        return LucidApiClientResponse.error('Erreur inconnue: ${error.message}');
    }
  }

  static String? _getErrorMessage(dynamic responseData) {
    if (responseData is LucidJsonMap) {
      return "${responseData['message'] ?? responseData['error'] ?? responseData['detail']}";
    }
    return responseData?.toString();
  }
}

class FormDataHelper {
  static FormData createFormData(LucidDataList<LucidUploadFile> files, String fieldName, LucidJsonMap? additionalData) {
    final formData = FormData();

    for (final upload in files) {
      formData.files.add(MapEntry(fieldName, MultipartFile.fromBytes(upload.file, filename: upload.name)));
    }

    _addAdditionalData(formData, additionalData);
    return formData;
  }

  static FormData createSingleFileFormData(
    String fieldName,
    String fileName,
    Uint8List file,
    LucidJsonMap? additionalData,
  ) {
    final formData = FormData();

    formData.files.add(MapEntry(fieldName, MultipartFile.fromBytes(file, filename: fileName)));

    _addAdditionalData(formData, additionalData);
    return formData;
  }

  static void _addAdditionalData(FormData formData, LucidJsonMap? additionalData) {
    if (additionalData != null) {
      additionalData.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
    }
  }
}
