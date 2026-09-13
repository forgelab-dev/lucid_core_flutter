import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../core/core.dart';
import 'log_sink/lucid_log_file_sink.dart';

class LucidLogger {
  static final LucidLogger _instance = LucidLogger._internal();

  factory LucidLogger() => _instance;

  LucidLogger._internal();

  LucidLoggerConfig _config = LucidLoggerConfig();
  final LucidDataList<LucidLogEntry> _buffer = [];
  final Dio _remoteClient = Dio();
  Timer? _flushTimer;
  LucidLogFileSink? _fileSink;
  int _currentFileSize = 0;

  /// Initialise le logger avec une configuration
  Future<void> initialize(LucidLoggerConfig config) async {
    _config = config;

    if (_config.outputs.contains(LucidLogOutput.file) || _config.outputs.contains(LucidLogOutput.all)) {
      await _initializeFileLogging();
    }

    if (_config.enableAsync) {
      _startFlushTimer();
    }
  }

  /// Initialise le logging vers un fichier
  Future<void> _initializeFileLogging() async {
    if (_config.logFilePath == null) return;

    _fileSink = LucidLogFileSink();
    _currentFileSize = await _fileSink!.open(_config.logFilePath!);

    if (_currentFileSize >= _config.maxSizeFile) {
      await _rotateLogFile();
    }
  }

  /// Rotation des fichiers de log
  Future<void> _rotateLogFile() async {
    if (_config.logFilePath == null || _fileSink == null) return;

    await _fileSink!.rotate(_config.logFilePath!, _config.maxFile);
    _currentFileSize = 0;
  }

  /// Démarre le timer de flush automatique
  void _startFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(_config.flushInterval, (_) => flush());
  }

  /// Log avec niveau TRACE
  void trace(String message, {String? tag, Map<String, dynamic>? data}) {
    _log(LucidLogLevel.trace, message, tag: tag, data: data);
  }

  /// Log avec niveau DEBUG
  void debug(String message, {String? tag, Map<String, dynamic>? data}) {
    _log(LucidLogLevel.debug, message, tag: tag, data: data);
  }

  /// Log avec niveau INFO
  void info(String message, {String? tag, Map<String, dynamic>? data}) {
    _log(LucidLogLevel.info, message, tag: tag, data: data);
  }

  /// Log avec niveau WARN
  void warn(String message, {String? tag, Map<String, dynamic>? data}) {
    _log(LucidLogLevel.warn, message, tag: tag, data: data);
  }

  /// Log avec niveau ERROR
  void error(String message, {String? tag, Map<String, dynamic>? data, StackTrace? stackTrace}) {
    _log(LucidLogLevel.error, message, tag: tag, data: data, stackTrace: stackTrace);
  }

  /// Log avec niveau FATAL
  void fatal(String message, {String? tag, Map<String, dynamic>? data, StackTrace? stackTrace}) {
    _log(LucidLogLevel.fatal, message, tag: tag, data: data, stackTrace: stackTrace);
  }

  /// Méthode de log principale
  void _log(LucidLogLevel level, String message, {String? tag, Map<String, dynamic>? data, StackTrace? stackTrace}) {
    if (level.value < _config.minLevel.value) return;

    // Obtenir les informations de caller
    String? fileName;
    int? lineNumber;

    if (_config.includeStackTrace || stackTrace != null) {
      final trace = stackTrace ?? StackTrace.current;
      final caller = _parseCaller(trace);
      fileName = caller?['file'].toString();
      lineNumber = int.tryParse("${caller?['line'] ?? 0}") ?? 0;
    }

    final entry = LucidLogEntry(
      timestamp: DateTime.now(),
      logLevel: level,
      message: message,
      tag: tag,
      data: data,
      stackTrace: (_config.includeStackTrace || level == LucidLogLevel.error || level == LucidLogLevel.fatal)
          ? (stackTrace ?? StackTrace.current)
          : null,
      fileName: fileName,
      lineNumber: lineNumber,
    );

    if (_config.enableAsync) {
      _buffer.add(entry);
    } else {
      _processLogEntry(entry);
    }
  }

  /// Parse les informations du caller depuis la stack trace
  Map<String, dynamic>? _parseCaller(StackTrace stackTrace) {
    try {
      final lines = stackTrace.toString().split('\n');
      for (final line in lines) {
        if (line.contains('.dart') && !line.contains('logger.dart')) {
          final regex = RegExp(r'(\S+\.dart):(\d+)');
          final match = regex.firstMatch(line);
          if (match != null) {
            return {'file': match.group(1)?.split('/').last, 'line': int.tryParse(match.group(2) ?? '')};
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Traite une entrée de log
  void _processLogEntry(LucidLogEntry entry) {
    if (_config.outputs.contains(LucidLogOutput.console) || _config.outputs.contains(LucidLogOutput.all)) {
      _writeToConsole(entry);
    }

    if (_config.outputs.contains(LucidLogOutput.file) || _config.outputs.contains(LucidLogOutput.all)) {
      _writeToFile(entry);
    }

    if (_config.outputs.contains(LucidLogOutput.remote) || _config.outputs.contains(LucidLogOutput.all)) {
      _writeToRemote(entry);
    }
  }

  /// Écrit dans la console
  void _writeToConsole(LucidLogEntry entry) {
    final formatted = _formatLogEntry(entry, forConsole: true);
    debugPrint(formatted);
  }

  /// Écrit dans un fichier
  void _writeToFile(LucidLogEntry entry) {
    if (_fileSink == null) return;

    final formatted = _formatLogEntry(entry, forConsole: false);
    _fileSink!.writeLine(formatted);

    _currentFileSize += formatted.length + 1;

    if (_currentFileSize >= _config.maxSizeFile) {
      _rotateLogFile();
    }
  }

  /// Envoie vers un endpoint distant
  void _writeToRemote(LucidLogEntry entry) {
    if (_config.remoteEndpoint == null) return;

    // Implémentation asynchrone pour éviter de bloquer
    Timer.run(() async {
      try {
        await _remoteClient.post<dynamic>(
          _config.remoteEndpoint!,
          data: entry.toJson(),
          options: Options(headers: {'Content-Type': 'application/json', ...?_config.httpHeaders}),
        );
      } catch (e) {
        // En cas d'erreur, on log localement
        debugPrint('Erreur envoi remote log: $e');
      }
    });
  }

  /// Formate une entrée de log
  String _formatLogEntry(LucidLogEntry entry, {required bool forConsole}) {
    final timestamp = _formatTimestamp(entry.timestamp);
    final level = entry.logLevel.name.padRight(5);

    switch (_config.format) {
      case LucidLogFormat.simple:
        return '[$timestamp] $level: ${entry.message}';

      case LucidLogFormat.json:
        return jsonEncode(entry.toJson());

      case LucidLogFormat.detailed:
        final buffer = StringBuffer();

        if (forConsole && _config.enableColors) {
          buffer.write(entry.logLevel.color);
        }
  
        buffer.write('[$timestamp] [$level]');

        if (entry.tag != null) {
          buffer.write(' [${entry.tag}]');
        }

        if (entry.fileName != null) {
          buffer.write(' (${entry.fileName}');
          if (entry.lineNumber != null) {
            buffer.write(':${entry.lineNumber}');
          }
          buffer.write(')');
        }

        buffer.write(': ${entry.message}');

        if (entry.data != null && entry.data!.isNotEmpty) {
          buffer.write('\n  Data: ${jsonEncode(entry.data)}');
        }

        if (entry.stackTrace != null) {
          buffer.write('\n  StackTrace:\n${entry.stackTrace}');
        }

        if (forConsole && _config.enableColors) {
          buffer.write('\x1B[0m'); // Reset couleur
        }

        return buffer.toString();

      case LucidLogFormat.custom:
        if (_config.customFormat != null) {
          return _config.customFormat!
              .replaceAll('{timestamp}', timestamp)
              .replaceAll('{level}', level.trim())
              .replaceAll('{message}', entry.message)
              .replaceAll('{tag}', entry.tag ?? '')
              .replaceAll('{file}', entry.fileName ?? '')
              .replaceAll('{line}', entry.lineNumber?.toString() ?? '');
        }
        return _formatLogEntry(entry, forConsole: forConsole);
    }
  }

  /// Formate le timestamp
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.year.toString().padLeft(4, '0')}-'
        '${timestamp.month.toString().padLeft(2, '0')}-'
        '${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}.'
        '${timestamp.millisecond.toString().padLeft(3, '0')}';
  }

  /// Force le flush du buffer
  void flush() {
    for (final entry in _buffer) {
      _processLogEntry(entry);
    }
    _buffer.clear();
    _fileSink?.flush();
  }

  /// Ferme le logger proprement
  Future<void> close() async {
    _flushTimer?.cancel();
    flush();
    await _fileSink?.close();
  }
}
