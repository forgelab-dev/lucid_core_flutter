import 'lucid_cache_stats.dart' show LucidCacheStats;

class LucidCacheManagerStats {
  final LucidCacheStats? memoryStats;
  final int secureKeysCount;
  final int prefsKeysCount;
  final int totalKeys;

  LucidCacheManagerStats({
    this.memoryStats,
    required this.secureKeysCount,
    required this.prefsKeysCount,
    required this.totalKeys,
  });

  @override
  String toString() {
    return '''
        CacheManagerStats:
          Total Keys: $totalKeys
          Memory Cache: ${memoryStats?.totalItems ?? 0} items (${memoryStats?.formattedSize ?? '0B'})
          Secure Storage: $secureKeysCount keys
          Preferences: $prefsKeysCount keys
        ${memoryStats != null ? '\nMemory Details:\n$memoryStats' : ''}
    ''';
  }
}
