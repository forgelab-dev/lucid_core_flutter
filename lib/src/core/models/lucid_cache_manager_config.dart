import '../constants/constants.dart';
import 'lucid_cache_config.dart';

class LucidCacheManagerConfig {
  final bool enableMemoryCache;
  final bool enableSecureStorage;
  final bool enablePrefsStorage;
  final LucidCacheStorageType defaultStorageType;
  final LucidCacheConfig memoryCacheConfig;
  final bool autoMigration;
  final int compressionThreshold;

  const LucidCacheManagerConfig({
    this.enableMemoryCache = true,
    this.enableSecureStorage = true,
    this.enablePrefsStorage = true,
    this.defaultStorageType = LucidCacheStorageType.memory,
    this.memoryCacheConfig = const LucidCacheConfig(),
    this.autoMigration = true,
    this.compressionThreshold = 1024,
  });
}
