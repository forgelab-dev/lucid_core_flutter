import '../constants/constants.dart' show LucidLogLevel;

class LucidLogEntry {
  final LucidLogLevel level;
  final String message;
  final DateTime timestamp;
  final String? tag;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? metadata;

  LucidLogEntry({
    required this.level,
    required this.message,
    required this.timestamp,
    this.tag,
    this.error,
    this.stackTrace,
    this.metadata,
  });
}
