import '../constants/constants.dart' show LucidNumExtensions;

class LucidCacheCleanupResult {
  final int removeItems;
  final int freeBytes;
  final Duration duration;

  LucidCacheCleanupResult({required this.removeItems, required this.freeBytes, required this.duration});

  @override
  String toString() {
    return 'LucidCacheCleanupResult{removeItems: $removeItems, freeBytes: $freeBytes, duration: $duration}';
  }

  String get formattedFreeSize => freeBytes.asFileSize;
}
