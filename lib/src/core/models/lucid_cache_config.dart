import '../constants/constants.dart' show LucidEvictionPolicy;

class LucidCacheConfig {
  final int maxSize;
  final int maxItems;
  final Duration defaultTtl;
  final Duration cleanupInterval;
  final LucidEvictionPolicy evictionPolicy;
  final bool compressionEnabled;
  final bool encryptionEnabled;
  final bool persistToDisk;
  final String cacheDirectory;

  const LucidCacheConfig({
    this.maxSize = 100 * 1024 * 1024,
    this.maxItems = 10000,
    this.defaultTtl = const Duration(hours: 24),
    this.cleanupInterval = const Duration(minutes: 30),
    this.evictionPolicy = LucidEvictionPolicy.lru,
    this.compressionEnabled = true,
    this.encryptionEnabled = true,
    this.persistToDisk = true,
    this.cacheDirectory = 'lucid_cache',
  });
}
