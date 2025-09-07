import '../constants/constants.dart';

class LucidLogEntry {
  final DateTime timestamp;
  final LucidLogLevel logLevel;
  final String message;
  final String? tag;
  final LucidJsonMap? data;
  final StackTrace? stackTrace;
  final String? fileName;
  final int? lineNumber;

  LucidLogEntry({
    required this.timestamp,
    required this.logLevel,
    required this.message,
    this.tag,
    this.data,
    this.stackTrace,
    this.fileName,
    this.lineNumber,
  });

  LucidJsonMap toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'level': logLevel.name,
    'message': message,
    if (tag != null) 'tag': tag,
    if (data != null) 'data': data,
    if (fileName != null) 'file': fileName,
    if (lineNumber != null) 'line': lineNumber,
    if (stackTrace != null) 'stackTrace': stackTrace.toString(),
  };
}
