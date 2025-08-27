import '../constants/constants.dart' show LucidErrorSeverity, LucidJsonMap;

abstract class LucidAbstractException implements Exception {
  const LucidAbstractException(
    this.message, {
    this.code,
    this.severity = LucidErrorSeverity.error,
    this.context,
    this.timestamp,
    this.stackTrace,
  });

  final String message;
  final String? code;
  final LucidErrorSeverity severity;
  final LucidJsonMap? context;
  final DateTime? timestamp;
  final StackTrace? stackTrace;

  DateTime get createdAt => timestamp ?? DateTime.now();

  bool get isCritical => severity == LucidErrorSeverity.critical;

  bool get isRecoverable => severity != LucidErrorSeverity.critical;

  String get formattedContext {
    if (context == null || context!.isEmpty) return '';

    final buffer = StringBuffer();
    context!.forEach((key, value) => buffer.writeln("  $key: $value"));
    return buffer.toString();
  }

  String get details {
    final buffer = StringBuffer();
    buffer.writeln('Exception: $runtimeType');
    buffer.writeln('Message: $message');

    if (code != null) buffer.writeln('Code: $code');
    buffer.writeln('Severity: ${severity.name}');
    buffer.writeln('Timestamp: ${createdAt.toIso8601String()}');

    if (context != null && context!.isNotEmpty) {
      buffer.writeln('Context:');
      buffer.write(formattedContext);
    }

    return buffer.toString().trim();
  }

  LucidJsonMap toMap() {
    return {
      'type': runtimeType.toString(),
      'message': message,
      'code': code,
      'severity': severity.name,
      'timestamp': createdAt.toIso8601String(),
      'context': context,
    };
  }

  LucidAbstractException copyWith({
    String? message,
    String? code,
    LucidErrorSeverity? severity,
    LucidJsonMap? context,
    DateTime? timestamp,
    StackTrace? stackTrace,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LucidAbstractException &&
            runtimeType == other.runtimeType &&
            message == other.message &&
            code == other.code &&
            severity == other.severity);
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code, severity);

  @override
  String toString() {
    final severityIcon = severity.icon;
    final codeStr = code != null ? ' [$code]' : '';
    return '$severityIcon $runtimeType: $message$codeStr';
  }
}
