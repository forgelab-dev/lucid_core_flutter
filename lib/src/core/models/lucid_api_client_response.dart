import '../constants/constants.dart' show LucidHttpHeaders;

class LucidApiClientResponse<T> {
  final bool success;
  final T? data;
  final String? message;

  final int? statusCode;
  final LucidHttpHeaders? headers;
  final bool fromCache;

  LucidApiClientResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.headers,
    this.fromCache = false,
  });

  factory LucidApiClientResponse.success(
    T data, {
    String? message,
    int? statusCode,
    LucidHttpHeaders? headers,
    bool fromCache = false,
  }) {
    return LucidApiClientResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
      headers: headers,
      fromCache: fromCache,
    );
  }

  factory LucidApiClientResponse.error(String message, {int? statusCode, LucidHttpHeaders? headers}) {
    return LucidApiClientResponse<T>(success: false, message: message, statusCode: statusCode, headers: headers);
  }

  @override
  String toString() {
    return 'LucidApiClientResponse{success: $success, data: $data, message: $message, statusCode: $statusCode, headers: $headers, fromCache: $fromCache}';
  }
}
