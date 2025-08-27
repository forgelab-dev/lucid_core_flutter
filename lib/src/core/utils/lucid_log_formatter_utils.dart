import 'dart:convert';

import '../models/lucid_log_config.dart' show LucidLogConfig;
import '../models/lucid_log_entry.dart' show LucidLogEntry;

class LucidLogFormatterUtils {
  final LucidLogConfig config;

  LucidLogFormatterUtils(this.config);

  String format(LucidLogEntry entry) {
    final buffer = StringBuffer();

    // Reset couleur
    const String reset = '\x1B[0m';

    // Couleur du niveau
    String levelColor = config.customColors[entry.level] ?? entry.level.color;
    if (!config.showColors) levelColor = '';

    // Timestamp
    if (config.showTimestamp) {
      buffer.write('$levelColor[${_formatTimestamp(entry.timestamp)}]$reset ');
    }

    // Niveau de log
    if (config.showLogLevel) {
      buffer.write('$levelColor[${entry.level.name.padRight(5)}]$reset ');
    }

    // Tag
    if (entry.tag != null) {
      buffer.write('$levelColor[${entry.tag}]$reset ');
    }

    final String formattedMessage = _formatMessage(entry.message);
    buffer.write('$levelColor$formattedMessage$reset');

    // Métadonnées
    if (entry.metadata != null && entry.metadata!.isNotEmpty) {
      buffer.write(' $levelColor${_formatMetadata(entry.metadata!)}$reset');
    }

    // Erreur
    if (entry.error != null) {
      buffer.write('\n${levelColor}Error: ${entry.error}$reset');
    }

    // Stack trace
    if (config.showStackTrace && entry.stackTrace != null) {
      buffer.write('\n$levelColor${_formatStackTrace(entry.stackTrace!)}$reset');
    }

    return buffer.toString();
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.year.toString().padLeft(4, '0')}-'
        '${timestamp.month.toString().padLeft(2, '0')}-'
        '${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}.'
        '${timestamp.millisecond.toString().padLeft(3, '0')}';
  }

  String _formatMessage(String message) {
    // Essayer de parser comme JSON pour un pretty print
    if (config.prettyPrintJson) {
      try {
        final dynamic json = jsonDecode(message);
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(json);
      } finally {}
    }

    // Diviser les lignes trop longues
    if (message.length > config.maxLineLength) {
      return _wrapText(message, config.maxLineLength);
    }

    return message;
  }

  String _formatMetadata(Map<String, dynamic> metadata) {
    final buffer = StringBuffer('| ');
    metadata.forEach((key, value) {
      buffer.write('$key: $value ');
    });
    return buffer.toString().trim();
  }

  String _formatStackTrace(StackTrace stackTrace) {
    return stackTrace
        .toString()
        .split('\n')
        .take(10) // Limiter à 10 lignes
        .map((line) => '  $line')
        .join('\n');
  }

  String _wrapText(String text, int maxLength) {
    if (text.length <= maxLength) return text;

    final buffer = StringBuffer();
    int start = 0;

    while (start < text.length) {
      int end = start + maxLength;
      if (end >= text.length) {
        buffer.write(text.substring(start));
        break;
      }

      // Essayer de couper au dernier espace
      final int lastSpace = text.lastIndexOf(' ', end);
      if (lastSpace > start) {
        end = lastSpace;
      }

      buffer.write(text.substring(start, end));
      if (end < text.length) {
        buffer.write('\n  '); // Indentation pour les lignes suivantes
      }

      start = end + (text[end] == ' ' ? 1 : 0);
    }

    return buffer.toString();
  }
}
