import '../models/models.dart' show LucidLogEntry;

abstract class LucidAbstractLogAppender {
  void append(LucidLogEntry entry, String formattedMessage);

  void close();
}
