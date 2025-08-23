import '../constants/constants.dart' show LucidLogLevel;

class LucidLogConfig {
  final LucidLogLevel minLevel;
  final bool showTimestamp;
  final bool showLogLevel;
  final bool showColors;
  final bool showStackTrace;
  final bool enableFileLogging;
  final String? logFilePath;
  final int maxFileSize;
  final int maxBackupFiles;
  final String timestampFormat;
  final Map<LucidLogLevel, String> customColors;
  final bool prettyPrintJson;
  final int maxLineLength;

  const LucidLogConfig({
    this.minLevel = LucidLogLevel.debug,
    this.showTimestamp = true,
    this.showLogLevel = true,
    this.showColors = true,
    this.showStackTrace = false,
    this.enableFileLogging = false,
    this.logFilePath,
    this.maxFileSize = 10 * 1024 * 1024, // 10MB
    this.maxBackupFiles = 5,
    this.timestampFormat = 'yyyy-MM-dd HH:mm:ss.SSS',
    this.customColors = const {},
    this.prettyPrintJson = true,
    this.maxLineLength = 120,
  });
}
