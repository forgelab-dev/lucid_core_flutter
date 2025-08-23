import '../constants/constants.dart' show LucidCachePriority, LucidNumExtensions, LucidDurationExtensions;

class LucidCacheStats {
  final int totalItems;
  final int totalSize;
  final int expiredItems;
  final double hitRate;
  final Duration averageAge;
  final Map<LucidCachePriority, int> priorityDistribution;
  final Map<String, int> tagDistribution;
  final int maxSize;
  final int maxItems;

  LucidCacheStats({
    required this.totalItems,
    required this.totalSize,
    required this.expiredItems,
    required this.hitRate,
    required this.averageAge,
    required this.priorityDistribution,
    required this.tagDistribution,
    required this.maxSize,
    required this.maxItems,
  });

  String get formattedSize => totalSize.asFileSize;

  String get formattedMaxSize => maxSize.asFileSize;

  double get sizeUsagePercent => totalSize / maxSize;

  double get itemsUsagePercent => totalItems / maxItems;

  double get expirationRate => totalItems > 0 ? expiredItems / totalItems : 0.0;

  @override
  String toString() {
    return '''
      CacheStats:
        Items: $totalItems / $maxItems (${(itemsUsagePercent * 100).toStringAsFixed(1)}%)
        Size: $formattedSize / $formattedMaxSize (${(sizeUsagePercent * 100).toStringAsFixed(1)}%)
        Hit Rate: ${(hitRate * 100).toStringAsFixed(1)}%
        Expired Items: $expiredItems (${(expirationRate * 100).toStringAsFixed(1)}%)
        Average Age: ${averageAge.formatted}
  ''';
  }
}
