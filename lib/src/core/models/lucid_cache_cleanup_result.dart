import '../constants/constants.dart' show LucidNumExtensions;

class LucidCacheCleanupResult {
  final int removedItems;
  final int freedBytes;
  final Duration duration;

  LucidCacheCleanupResult({required this.removedItems, required this.freedBytes, required this.duration});

  @override
  String toString() {
    return 'LucidCacheCleanupResult{removedItems: $removedItems, freedBytes: $freedBytes, duration: $duration}';
  }

  String get formattedFreeSize => freedBytes.asFileSize;
}
