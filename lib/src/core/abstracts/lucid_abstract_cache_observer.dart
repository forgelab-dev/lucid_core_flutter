abstract class LucidAbstractCacheObserver {
  void onCacheHit(String key, dynamic value);

  void onCacheMiss(String key);

  void onCachePut(String key, dynamic value, Duration? ttl);

  void onCacheDelete(String key);

  void onCacheClear();

  void onCacheError(String operation, Object error, StackTrace stackTrace);
}
