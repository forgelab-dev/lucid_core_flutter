import 'dart:convert';
import 'dart:typed_data';

import '../../services/storage/storage.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import 'lucid_config_helpers.dart';

class LucidStorageHelpers {
  LucidStorageHelpers._();

  static LucidStorageHelpers? _instance;
  static LucidConfigHelpers? _helperConfig;

  LucidCacheStorage? _mainCache;
  LucidSecureStorage? _secureStorage;
  LucidSharedPreferencesStorage? _prefsStorage;
  LucidCacheManagerConfig? _config;

  static Future<LucidStorageHelpers> getInstance({
    LucidCacheManagerConfig? config,
    LucidConfigHelpers? helperConfig,
  }) async {
    _helperConfig = helperConfig ?? LucidGlobalConfig.current;
    _instance ??= LucidStorageHelpers._();
    await _instance!._initialize(config ?? const LucidCacheManagerConfig());
    return _instance!;
  }

  Future<void> _initialize(LucidCacheManagerConfig config) async {
    _config = config;

    try {
      if (config.enableMemoryCache) {
        _mainCache = await LucidCacheStorage.getInstance(config: config.memoryCacheConfig);
      }

      if (config.enableSecureStorage) {
        _secureStorage = LucidSecureStorage.getInstance();
      }

      if (config.enablePrefsStorage) {
        _prefsStorage = await LucidSharedPreferencesStorage.getInstance();
      }

      if (config.autoMigration) {
        await _performMigration();
      }
    } catch (e) {
      throw CacheException('Erreur lors de l\'initialisation du CacheManager: $e');
    }
  }

  Future<void> put<T>(
    String key,
    T value, {
    LucidCacheStorageType? storageType,
    Duration? ttl,
    LucidDataList<String> tags = const [],
    LucidCachePriority priority = LucidCachePriority.normal,
    bool isSecure = false,
  }) async {
    final storage = storageType ?? _determineStorageType(key, value, isSecure);

    switch (storage) {
      case LucidCacheStorageType.memory:
        await _putInMemory(key, value, ttl: ttl, tags: tags, priority: priority);
        break;
      case LucidCacheStorageType.secure:
        await _putInSecure(key, value);
        break;
      case LucidCacheStorageType.preferences:
        await _putInPrefs(key, value);
        break;
      case LucidCacheStorageType.hybrid:
        await _putInHybrid(key, value, ttl: ttl, tags: tags, priority: priority);
        break;
    }
  }

  Future<T?> get<T>(String key, {LucidCacheStorageType? storageType, T? defaultValue}) async {
    if (storageType != null) {
      return await _getFromStorage<T>(key, storageType) ?? defaultValue;
    }

    for (final storage in [
      LucidCacheStorageType.memory,
      LucidCacheStorageType.preferences,
      LucidCacheStorageType.secure,
    ]) {
      final value = await _getFromStorage<T>(key, storage);
      if (value != null) return value;
    }

    return defaultValue;
  }

  Future<T> getOrPut<T>(
    String key,
    LucidAsyncValueCallBack<T> factory, {
    LucidCacheStorageType? storageType,
    Duration? ttl,
    LucidDataList<String> tags = const [],
    bool isSecure = false,
  }) async {
    final cached = await get<T>(key, storageType: storageType);
    if (cached != null) return cached;

    final value = await factory();
    await put(key, value, storageType: storageType, ttl: ttl, tags: tags, isSecure: isSecure);
    return value;
  }

  Future<bool> containsKey(String key, {LucidCacheStorageType? storageType}) async {
    if (storageType != null) {
      return await _containsKeyInStorage(key, storageType);
    }

    for (final storage in LucidCacheStorageType.values) {
      if (await _containsKeyInStorage(key, storage)) return true;
    }

    return false;
  }

  Future<bool> delete(String key, {LucidCacheStorageType? storageType}) async {
    bool deleted = false;

    if (storageType != null) {
      return await _deleteFromStorage(key, storageType);
    }

    for (final storage in LucidCacheStorageType.values) {
      if (await _deleteFromStorage(key, storage)) deleted = true;
    }

    return deleted;
  }

  Future<void> clear({LucidCacheStorageType? storageType}) async {
    if (storageType != null) {
      await _clearStorage(storageType);
      return;
    }

    final futures = <Future<void>>[];
    for (final storage in LucidCacheStorageType.values) {
      futures.add(_clearStorage(storage));
    }
    await Future.wait(futures);
  }

  Future<void> putAll<T>(
    LucidEntriesMap<T> entries, {
    LucidCacheStorageType? storageType,
    Duration? ttl,
    LucidDataList<String> tags = const [],
  }) async {
    final futures = entries.entries.map(
      (entry) => put(entry.key, entry.value, storageType: storageType, ttl: ttl, tags: tags),
    );
    await Future.wait(futures);
  }

  Future<Map<String, T?>> getAll<T>(LucidDataList<String> keys, {LucidCacheStorageType? storageType}) async {
    final result = <String, T?>{};
    final futures = keys.map((key) async {
      final value = await get<T>(key, storageType: storageType);
      return MapEntry(key, value);
    });

    final entries = await Future.wait(futures);
    for (final entry in entries) {
      result[entry.key] = entry.value;
    }

    return result;
  }

  Future<LucidJsonMap> getByTag(String tag) async {
    if (_mainCache == null) return {};
    return await _mainCache!.getByTag(tag);
  }

  Future<int> deleteByTag(String tag) async {
    if (_mainCache == null) return 0;
    return await _mainCache!.deleteByTag(tag);
  }

  Future<void> putJson(
    String key,
    LucidJsonMap json, {
    LucidCacheStorageType storageType = LucidCacheStorageType.memory,
    Duration? ttl,
  }) async {
    await put(key, json, storageType: storageType, ttl: ttl);
  }

  Future<LucidJsonMap?> getJson(String key, {LucidCacheStorageType? storageType}) async {
    return await get<LucidJsonMap>(key, storageType: storageType);
  }

  Future<void> putList<T>(
    String key,
    List<T> list, {
    LucidCacheStorageType storageType = LucidCacheStorageType.memory,
    Duration? ttl,
  }) async {
    await put(key, list, storageType: storageType, ttl: ttl);
  }

  Future<List<T>?> getList<T>(String key, {LucidCacheStorageType? storageType}) async {
    final result = await get<List<dynamic>>(key, storageType: storageType);
    return result?.cast<T>();
  }

  Future<void> putBytes(
    String key,
    Uint8List bytes, {
    LucidCacheStorageType storageType = LucidCacheStorageType.memory,
    Duration? ttl,
  }) async {
    final base64String = base64Encode(bytes);
    await put(key, base64String, storageType: storageType, ttl: ttl);
  }

  Future<Uint8List?> getBytes(String key, {LucidCacheStorageType? storageType}) async {
    final base64String = await get<String>(key, storageType: storageType);
    if (base64String == null) return null;

    try {
      return base64Decode(base64String);
    } catch (e) {
      return null;
    }
  }

  Future<LucidCacheManagerStats> getStats() async {
    final memoryStats = _mainCache != null ? await _mainCache!.getStats() : null;
    final secureKeys = _secureStorage != null ? await _secureStorage!.getKeys() : <String>{};
    final prefsKeys = _prefsStorage != null ? await _prefsStorage!.getKeys() : <String>{};

    return LucidCacheManagerStats(
      memoryStats: memoryStats,
      secureKeysCount: secureKeys.length,
      prefsKeysCount: prefsKeys.length,
      totalKeys: (memoryStats?.totalItems ?? 0) + secureKeys.length + prefsKeys.length,
    );
  }

  Future<LucidCacheCleanupResult> cleanup({
    bool removeExpired = true,
    bool compactStorage = true,
    Duration? olderThan,
  }) async {
    int removedItems = 0;
    int freedBytes = 0;

    if (_mainCache != null && removeExpired) {
      final statsBefore = await _mainCache!.getStats();
      final statsAfter = await _mainCache!.getStats();
      removedItems += statsBefore.expiredItems;
      freedBytes += statsBefore.totalSize - statsAfter.totalSize;
    }

    return LucidCacheCleanupResult(removedItems: removedItems, freedBytes: freedBytes, duration: Duration.zero);
  }

  Future<void> exportCache(String filePath, {LucidCacheStorageType? storageType}) async {
    if (storageType == null || storageType == LucidCacheStorageType.memory) {
      await _mainCache?.exportToFile(filePath);
    }
  }

  Future<void> importCache(String filePath, {bool clearExisting = false}) async {
    await _mainCache?.importFromFile(filePath, clearExisting: clearExisting);
  }

  Future<void> saveAuthToken(String token) async {
    await _secureStorage?.saveAuthToken(token);
  }

  Future<String?> getAuthToken() async {
    return await _secureStorage?.getAuthToken();
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await _secureStorage?.saveRefreshToken(refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage?.getRefreshToken();
  }

  Future<void> clearAuthTokens() async {
    await _secureStorage?.clearAuthTokens();
  }

  Future<void> saveUserPreference<T>(String key, T value) async {
    await put('${_helperConfig?.storageUserPrefsKey}_$key', value, storageType: LucidCacheStorageType.preferences);
  }

  Future<T?> getUserPreference<T>(String key, {T? defaultValue}) async {
    return await get<T>(
      '${_helperConfig?.storageUserPrefsKey}_$key',
      storageType: LucidCacheStorageType.preferences,
      defaultValue: defaultValue,
    );
  }

  LucidCacheStorageType _determineStorageType<T>(String key, T value, bool isSecure) {
    if (isSecure || _isSecurityRelatedKey(key)) {
      return LucidCacheStorageType.secure;
    }

    if (_isUserPreferenceKey(key)) {
      return LucidCacheStorageType.preferences;
    }

    return _config?.defaultStorageType ?? LucidCacheStorageType.memory;
  }

  bool _isSecurityRelatedKey(String key) {
    const securityKeys = ['token', 'auth', 'password', 'secret', 'key', 'credential'];
    return securityKeys.any((secKey) => key.toLowerCase().contains(secKey));
  }

  bool _isUserPreferenceKey(String key) {
    const prefKeys = ['theme', 'locale', 'setting', 'preference', 'config'];
    return prefKeys.any((prefKey) => key.toLowerCase().contains(prefKey));
  }

  Future<void> _putInMemory<T>(
    String key,
    T value, {
    Duration? ttl,
    LucidDataList<String> tags = const [],
    LucidCachePriority priority = LucidCachePriority.normal,
  }) async {
    await _mainCache?.put(key, value, ttl: ttl, tags: tags, priority: priority);
  }

  Future<void> _putInSecure<T>(String key, T value) async {
    if (_secureStorage == null) return;
    final serialized = _serializeValue(value);
    await _secureStorage!.write(key, serialized);
  }

  Future<void> _putInPrefs<T>(String key, T value) async {
    if (_prefsStorage == null) return;
    final serialized = _serializeValue(value);
    await _prefsStorage!.write(key, serialized);
  }

  Future<void> _putInHybrid<T>(
    String key,
    T value, {
    Duration? ttl,
    LucidDataList<String> tags = const [],
    LucidCachePriority priority = LucidCachePriority.normal,
  }) async {
    await _putInMemory(key, value, ttl: ttl, tags: tags, priority: priority);

    await _putInPrefs('backup_$key', value);
  }

  Future<T?> _getFromStorage<T>(String key, LucidCacheStorageType storageType) async {
    switch (storageType) {
      case LucidCacheStorageType.memory:
        return await _mainCache?.get<T>(key);
      case LucidCacheStorageType.secure:
        if (_secureStorage == null) return null;
        final serialized = await _secureStorage!.read(key);
        return serialized != null ? _deserializeValue<T>(serialized) : null;
      case LucidCacheStorageType.preferences:
        if (_prefsStorage == null) return null;
        final serialized = await _prefsStorage!.read(key);
        return serialized != null ? _deserializeValue<T>(serialized) : null;
      case LucidCacheStorageType.hybrid:
        final memoryValue = await _mainCache?.get<T>(key);
        if (memoryValue != null) return memoryValue;
        return await _getFromStorage<T>('backup_$key', LucidCacheStorageType.preferences);
    }
  }

  Future<bool> _containsKeyInStorage(String key, LucidCacheStorageType storageType) async {
    switch (storageType) {
      case LucidCacheStorageType.memory:
        return await _mainCache?.containsKey(key) ?? false;
      case LucidCacheStorageType.secure:
        return await _secureStorage?.containsKey(key) ?? false;
      case LucidCacheStorageType.preferences:
        return await _prefsStorage?.containsKey(key) ?? false;
      case LucidCacheStorageType.hybrid:
        return await _containsKeyInStorage(key, LucidCacheStorageType.memory) ||
            await _containsKeyInStorage('backup_$key', LucidCacheStorageType.preferences);
    }
  }

  Future<bool> _deleteFromStorage(String key, LucidCacheStorageType storageType) async {
    switch (storageType) {
      case LucidCacheStorageType.memory:
        return await _mainCache?.delete(key) ?? false;
      case LucidCacheStorageType.secure:
        try {
          await _secureStorage?.delete(key);
          return true;
        } catch (e) {
          return false;
        }
      case LucidCacheStorageType.preferences:
        try {
          await _prefsStorage?.delete(key);
          return true;
        } catch (e) {
          return false;
        }
      case LucidCacheStorageType.hybrid:
        final deleted1 = await _deleteFromStorage(key, LucidCacheStorageType.memory);
        final deleted2 = await _deleteFromStorage('backup_$key', LucidCacheStorageType.preferences);
        return deleted1 || deleted2;
    }
  }

  Future<void> _clearStorage(LucidCacheStorageType storageType) async {
    switch (storageType) {
      case LucidCacheStorageType.memory:
        await _mainCache?.clear();
        break;
      case LucidCacheStorageType.secure:
        await _secureStorage?.clear();
        break;
      case LucidCacheStorageType.preferences:
        await _prefsStorage?.clear();
        break;
      case LucidCacheStorageType.hybrid:
        await _clearStorage(LucidCacheStorageType.memory);
        await _clearStorage(LucidCacheStorageType.preferences);
        break;
    }
  }

  String _serializeValue<T>(T value) {
    try {
      if (value is String) return value;
      return jsonEncode(value);
    } catch (e) {
      throw CacheException('Impossible de sérialiser la valeur: $e');
    }
  }

  T? _deserializeValue<T>(String value) {
    try {
      if (T == String) return value as T;
      final decoded = jsonDecode(value);
      return decoded as T;
    } catch (e) {
      if (T == String) return value as T;
      return null;
    }
  }

  Future<void> _performMigration() async {
    // TODO: Logique de migration entre versions
  }

  Future<void> dispose() async {
    await _mainCache?.dispose();
    _instance = null;
  }
}
