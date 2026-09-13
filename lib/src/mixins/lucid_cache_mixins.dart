import '../core/core.dart';
import '../services/manager/manager.dart';

mixin LucidCacheMixin {
  LucidStorageManager get _cache => LucidCacheHelper.manager;

  String get _classTag => runtimeType.toString().toLowerCase();

  Future<void> cacheValue<T>(String key, T value, {Duration? ttl, LucidDataList<String> tags = const []}) async {
    final prefixedKey = '${_classTag}_$key';
    await _cache.put(prefixedKey, value, ttl: ttl, tags: {_classTag, ...tags}.toList());
  }

  Future<T?> getCachedValue<T>(String key, {T? defaultValue}) async {
    final prefixedKey = '${_classTag}_$key';
    return await _cache.get<T>(prefixedKey, defaultValue: defaultValue);
  }

  Future<T> cacheOrGetValue<T>(
    String key,
    Future<T> Function() factory, {
    Duration? ttl,
    LucidDataList<String> tags = const [],
  }) async {
    final prefixedKey = '${_classTag}_$key';
    return await _cache.getOrPut<T>(prefixedKey, factory, ttl: ttl, tags: {_classTag, ...tags}.toList());
  }

  Future<bool> removeCachedValue(String key) async {
    final prefixedKey = '${_classTag}_$key';
    return await _cache.delete(prefixedKey);
  }

  /// Supprime toutes les valeurs mises en cache par cette classe (identifiées
  /// par leur tag [_classTag], ajouté automatiquement par [cacheValue] et
  /// [cacheOrGetValue]).
  Future<void> clearClassCache() async {
    await _cache.deleteByTag(_classTag);
  }
}

mixin LucidServiceCacheMixin on LucidCacheMixin {
  Duration get defaultServiceTtl => const Duration(minutes: 15);

  List<String> get defaultServiceTags => [runtimeType.toString().toLowerCase(), 'service'];

  Future<void> cacheServiceResponse<T>(String endpoint, T response) async {
    await cacheValue('response_${endpoint.hashCode}', response, ttl: defaultServiceTtl, tags: defaultServiceTags);
  }

  Future<T?> getCachedServiceResponse<T>(String endpoint) async {
    return await getCachedValue<T>('response_${endpoint.hashCode}');
  }

  Future<void> invalidateServiceCache(String endpoint) async {
    await removeCachedValue('response_${endpoint.hashCode}');
  }
}
