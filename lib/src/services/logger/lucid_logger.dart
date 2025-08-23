import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/core.dart'
    show LucidLogFormatter, LucidLogConfig, LucidLogEntry, LucidAbstractLogAppender, LucidLogLevel;

class LucidConsoleAppender implements LucidAbstractLogAppender {
  final LucidLogConfig config;

  LucidConsoleAppender(this.config);

  @override
  void append(LucidLogEntry entry, String formattedMessage) {
    debugPrint(formattedMessage);
  }

  @override
  void close() {
    debugPrint('LucidConsoleAppender closed');
  }
}

class LucidFileAppender implements LucidAbstractLogAppender {
  final LucidLogConfig config;
  File? _logFile;

  LucidFileAppender(this.config) {
    if (config.enableFileLogging && config.logFilePath != null) {
      _initLogFile();
    }
  }

  void _initLogFile() {
    _logFile = File(config.logFilePath!);
    if (!_logFile!.existsSync()) {
      _logFile!.createSync(recursive: true);
    }
  }

  @override
  void append(LucidLogEntry entry, String formattedMessage) {
    if (_logFile == null) return;

    try {
      // Vérifier la taille du fichier
      if (_logFile!.lengthSync() > config.maxFileSize) {
        _rotateLogFile();
      }

      // Écrire sans les codes couleur
      final cleanMessage = _removeColorCodes(formattedMessage);
      _logFile!.writeAsStringSync('$cleanMessage\n', mode: FileMode.append);
    } catch (e) {
      debugPrint('Erreur lors de l\'écriture dans le fichier de log: $e');
    }
  }

  String _removeColorCodes(String message) {
    return message.replaceAll(RegExp(r'\x1B\[[0-9;]*m'), '');
  }

  void _rotateLogFile() {
    try {
      // Supprimer le plus ancien fichier de sauvegarde
      final oldestBackup = File('${config.logFilePath}.${config.maxBackupFiles}');
      if (oldestBackup.existsSync()) {
        oldestBackup.deleteSync();
      }

      // Renommer les fichiers de sauvegarde
      for (int i = config.maxBackupFiles - 1; i >= 1; i--) {
        final currentBackup = File('${config.logFilePath}.$i');
        final nextBackup = File('${config.logFilePath}.${i + 1}');
        if (currentBackup.existsSync()) {
          currentBackup.renameSync(nextBackup.path);
        }
      }

      // Renommer le fichier courant
      _logFile!.renameSync('${config.logFilePath}.1');

      // Créer un nouveau fichier
      _initLogFile();
    } catch (e) {
      debugPrint('Erreur lors de la rotation du fichier de log: $e');
    }
  }

  @override
  void close() {
    debugPrint('LucidFileAppender close');
  }
}

class LucidLogger {
  static LucidLogger? _instance;

  static LucidLogger get instance => _instance ??= LucidLogger._();

  LucidLogConfig _config = const LucidLogConfig();
  final List<LucidAbstractLogAppender> _appenders = [];
  late LucidLogFormatter _formatter;

  LucidLogger._() {
    _init();
  }

  void _init() {
    _formatter = LucidLogFormatter(_config);
    _appenders.clear();
    _appenders.add(LucidConsoleAppender(_config));
    if (_config.enableFileLogging) {
      _appenders.add(LucidFileAppender(_config));
    }
  }

  // Configuration
  void configure(LucidLogConfig config) {
    _config = config;
    _init();
  }

  // Méthodes de logging
  void trace(String message, {String? tag, Map<String, dynamic>? metadata}) {
    _log(LucidLogLevel.trace, message, tag: tag, metadata: metadata);
  }

  void debug(String message, {String? tag, Map<String, dynamic>? metadata}) {
    _log(LucidLogLevel.debug, message, tag: tag, metadata: metadata);
  }

  void info(String message, {String? tag, Map<String, dynamic>? metadata}) {
    _log(LucidLogLevel.info, message, tag: tag, metadata: metadata);
  }

  void warn(String message, {String? tag, Map<String, dynamic>? metadata}) {
    _log(LucidLogLevel.warn, message, tag: tag, metadata: metadata);
  }

  void error(String message, {Object? error, StackTrace? stackTrace, String? tag, Map<String, dynamic>? metadata}) {
    _log(LucidLogLevel.error, message, error: error, stackTrace: stackTrace, tag: tag, metadata: metadata);
  }

  void fatal(String message, {Object? error, StackTrace? stackTrace, String? tag, Map<String, dynamic>? metadata}) {
    _log(LucidLogLevel.fatal, message, error: error, stackTrace: stackTrace, tag: tag, metadata: metadata);
  }

  // Log avec objet structuré
  void logObject(LucidLogLevel level, String message, Object object, {String? tag}) {
    String jsonMessage = message;
    try {
      const encoder = JsonEncoder.withIndent('  ');
      jsonMessage = '$message\n${encoder.convert(object)}';
    } catch (e) {
      jsonMessage = '$message\n${object.toString()}';
    }
    _log(level, jsonMessage, tag: tag);
  }

  void _log(
    LucidLogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
    Map<String, dynamic>? metadata,
  }) {
    if (level.value < _config.minLevel.value) return;

    final entry = LucidLogEntry(
      level: level,
      message: message,
      timestamp: DateTime.now(),
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
    );

    final formattedMessage = _formatter.format(entry);

    for (final appender in _appenders) {
      appender.append(entry, formattedMessage);
    }
  }

  // Fermeture propre
  void close() {
    for (final appender in _appenders) {
      appender.close();
    }
    _appenders.clear();
  }
}

// Extension pour faciliter l'utilisation
extension LoggerExtension on Object {
  void logDebug(String message, {String? tag}) {
    LucidLogger.instance.debug(message, tag: tag ?? runtimeType.toString());
  }

  void logInfo(String message, {String? tag}) {
    LucidLogger.instance.info(message, tag: tag ?? runtimeType.toString());
  }

  void logWarn(String message, {String? tag}) {
    LucidLogger.instance.warn(message, tag: tag ?? runtimeType.toString());
  }

  void logError(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    LucidLogger.instance.error(message, error: error, stackTrace: stackTrace, tag: tag ?? runtimeType.toString());
  }
}
