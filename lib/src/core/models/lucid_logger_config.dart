import '../constants/constants.dart';

class LucidLoggerConfig {
  LucidLogLevel minLevel;
  bool enableColors;
  LucidLogFormat format;

  String? logFilePath;
  String? remoteEndpoint;
  LucidHttpHeaders? httpHeaders;

  int maxSizeFile;
  int maxFile;
  String dateFormat;

  bool includeStackTrace;
  bool enableAsync;
  Duration flushInterval;

  List<LucidLogOutput> outputs;

  String? customFormat;

  LucidLoggerConfig({
    this.minLevel = LucidLogLevel.info,
    this.enableColors = true,
    this.format = LucidLogFormat.detailed,
    this.logFilePath,
    this.remoteEndpoint,
    this.httpHeaders,
    this.maxSizeFile = 10 * 1024 * 1024, // 10MB
    this.maxFile = 5,
    this.dateFormat = 'yyyy-MM-dd HH:mm:ss.SSS',
    this.includeStackTrace = false,
    this.enableAsync = true,
    this.flushInterval = const Duration(seconds: 5),
    this.outputs = const [LucidLogOutput.console],
    this.customFormat,
  });
}
