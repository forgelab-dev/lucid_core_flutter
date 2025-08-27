import '../core/core.dart';
import '../services/manager/manager.dart';

mixin LucidCacheMixin {
  LucidStorageManager get _cache => LucidCacheHelper.manager;

  Future<void> cacheValue<T>(String key, T value, {Duration? ttl}) async {
    final prefixedKey = '${runtimeType.toString().toLowerCase()}_$key';
    await _cache.put(prefixedKey, value, ttl: ttl);
  }

  Future<T?> getCachedValue<T>(String key, {T? defaultValue}) async {
    final prefixedKey = '${runtimeType.toString().toLowerCase()}_$key';
    return await _cache.get<T>(prefixedKey, defaultValue: defaultValue);
  }

  Future<T> cacheOrGetValue<T>(String key, Future<T> Function() factory, {Duration? ttl}) async {
    final prefixedKey = '${runtimeType.toString().toLowerCase()}_$key';
    return await _cache.getOrPut<T>(prefixedKey, factory, ttl: ttl);
  }

  Future<bool> removeCachedValue(String key) async {
    final prefixedKey = '${runtimeType.toString().toLowerCase()}_$key';
    return await _cache.delete(prefixedKey);
  }

  Future<void> clearClassCache() async {
    // Implémentation simplifiée - dans la vraie version, il faudrait
    // une méthode pour lister et supprimer par préfixe
    await _cache.deleteByTag(runtimeType.toString().toLowerCase());
  }
}

mixin LucidServiceCacheMixin on LucidCacheMixin {
  Duration get defaultServiceTtl => const Duration(minutes: 15);

  List<String> get defaultServiceTags => [runtimeType.toString().toLowerCase(), 'service'];

  Future<void> cacheServiceResponse<T>(String endpoint, T response) async {
    await cacheValue('response_${endpoint.hashCode}', response, ttl: defaultServiceTtl);
  }

  Future<T?> getCachedServiceResponse<T>(String endpoint) async {
    return await getCachedValue<T>('response_${endpoint.hashCode}');
  }

  Future<void> invalidateServiceCache(String endpoint) async {
    await removeCachedValue('response_${endpoint.hashCode}');
  }
}
