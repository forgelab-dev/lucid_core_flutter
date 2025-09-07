import '../../services/manager/manager.dart' show LucidStorageManager;
import '../constants/constants.dart';
import '../models/models.dart';
import 'lucid_config_helpers.dart';

class LucidCacheHelper {
  LucidCacheHelper._();

  static LucidStorageManager? _manager;

  static Future<void> initialize({LucidCacheManagerConfig? config}) async {
    _manager = await LucidStorageManager.getInstance(config: config);
  }

  static LucidStorageManager get manager {
    if (_manager == null) {
      throw StateError('LucidCacheHelper non initialisé. Appelez LucidCacheHelper.initialize() d\'abord.');
    }
    return _manager!;
  }

  static Future<void> cache<T>(String key, T value, {Duration? ttl}) async {
    await manager.put(key, value, ttl: ttl);
  }

  static Future<T?> retrieve<T>(String key, {T? defaultValue}) async {
    return await manager.get<T>(key, defaultValue: defaultValue);
  }

  static Future<T> cacheOrGet<T>(String key, Future<T> Function() factory, {Duration? ttl}) async {
    return await manager.getOrPut<T>(key, factory, ttl: ttl);
  }

  static Future<bool> remove(String key) async {
    return await manager.delete(key);
  }

  static Future<bool> exists(String key) async {
    return await manager.containsKey(key);
  }

  static Future<void> cleanup() async {
    await manager.cleanup();
  }

  static Future<String> stats() async {
    final stats = await manager.getStats();
    return stats.toString();
  }

  static ImageLucidCacheHelper get images => ImageLucidCacheHelper._(manager);

  static ApiLucidCacheHelper get api => ApiLucidCacheHelper._(manager);

  static PreferencesLucidCacheHelper get preferences => PreferencesLucidCacheHelper._(manager);

  static SecureLucidCacheHelper get secure => SecureLucidCacheHelper._(manager);

  static SessionLucidCacheHelper get session => SessionLucidCacheHelper._(manager);
}

class ImageLucidCacheHelper {
  const ImageLucidCacheHelper._(this._manager);

  final LucidStorageManager _manager;

  static const String _prefix = 'image_';
  static const Duration _defaultTtl = Duration(days: 7);

  Future<void> cacheImageData(String imageUrl, String base64Data) async {
    await _manager.put('${_prefix}data_${imageUrl.hashCode}', base64Data, ttl: _defaultTtl, tags: ['image', 'asset']);
  }

  Future<String?> getImageData(String imageUrl) async {
    return await _manager.get<String>('${_prefix}data_${imageUrl.hashCode}');
  }

  Future<void> cacheImageMetadata(String imageUrl, LucidJsonMap metadata) async {
    await _manager.putJson('${_prefix}meta_${imageUrl.hashCode}', metadata, ttl: _defaultTtl);
  }

  Future<LucidJsonMap?> getImageMetadata(String imageUrl) async {
    return await _manager.getJson('${_prefix}meta_${imageUrl.hashCode}');
  }

  Future<void> clearImageCache() async {
    await _manager.deleteByTag('image');
  }
}

class ApiLucidCacheHelper {
  const ApiLucidCacheHelper._(this._manager);

  final LucidStorageManager _manager;

  static const String _prefix = 'api_';
  static const Duration _defaultTtl = Duration(minutes: 15);

  Future<void> cacheResponse(String endpoint, LucidJsonMap response, {Duration? ttl, String? version}) async {
    final key = '$_prefix${endpoint.hashCode}${version != null ? '_$version' : ''}';
    await _manager.putJson(key, {
      'data': response,
      'cachedAt': DateTime.now().toIso8601String(),
      'endpoint': endpoint,
      'version': version,
    }, ttl: ttl ?? _defaultTtl);
  }

  Future<LucidJsonMap?> getResponse(String endpoint, {String? version}) async {
    final key = '$_prefix${endpoint.hashCode}${version != null ? '_$version' : ''}';
    final cached = await _manager.getJson(key);
    return cached?['data'] as LucidJsonMap?;
  }

  Future<void> invalidateEndpoint(String endpoint) async {
    final allKeys = await _getAllApiKeys();
    final keysToDelete = allKeys.where((key) => key.contains('${endpoint.hashCode}'));

    for (final key in keysToDelete) {
      await _manager.delete(key);
    }
  }

  Future<void> clearApiCache() async {
    await _manager.deleteByTag('api');
  }

  Future<List<String>> _getAllApiKeys() async {
    // TODO: Simulation - dans la vraie implémentation, il faudrait une méthode pour lister les clés
    return [];
  }
}

class PreferencesLucidCacheHelper {
  PreferencesLucidCacheHelper._(this._manager, [LucidConfigHelpers? config])
    : _config = config ?? LucidGlobalConfig.current;

  final LucidStorageManager _manager;
  final LucidConfigHelpers _config;

  Future<void> setTheme(String theme) async {
    await _manager.saveUserPreference('theme', theme);
  }

  Future<String?> getTheme() async {
    return await _manager.getUserPreference<String>('theme');
  }

  Future<void> setLocale(String locale) async {
    await _manager.saveUserPreference('locale', locale);
  }

  Future<String?> getLocale() async {
    return await _manager.getUserPreference<String>('locale', defaultValue: _config.appLocale);
  }

  Future<void> setFirstLaunch(bool isFirstLaunch) async {
    await _manager.saveUserPreference('first_launch', isFirstLaunch);
  }

  Future<bool> isFirstLaunch() async {
    return await _manager.getUserPreference<bool>('first_launch', defaultValue: true) ?? true;
  }

  Future<void> setAnalyticsConsent(bool consent) async {
    await _manager.saveUserPreference('analytics_consent', consent);
  }

  Future<bool?> getAnalyticsConsent() async {
    return await _manager.getUserPreference<bool>('analytics_consent');
  }

  Future<void> setCustomSetting<T>(String key, T value) async {
    await _manager.saveUserPreference('custom_$key', value);
  }

  Future<T?> getCustomSetting<T>(String key, {T? defaultValue}) async {
    return await _manager.getUserPreference<T>('custom_$key', defaultValue: defaultValue);
  }
}

class SecureLucidCacheHelper {
  const SecureLucidCacheHelper._(this._manager);

  final LucidStorageManager _manager;

  Future<void> saveCredential(String key, String value) async {
    await _manager.put(key, value, storageType: LucidCacheStorageType.secure, isSecure: true);
  }

  Future<String?> getCredential(String key) async {
    return await _manager.get<String>(key, storageType: LucidCacheStorageType.secure);
  }

  Future<void> saveAuthToken(String token) async {
    await _manager.saveAuthToken(token);
  }

  Future<String?> getAuthToken() async {
    return await _manager.getAuthToken();
  }

  Future<void> saveRefreshToken(String token) async {
    await _manager.saveRefreshToken(token);
  }

  Future<String?> getRefreshToken() async {
    return await _manager.getRefreshToken();
  }

  Future<void> clearAllSecureData() async {
    await _manager.clearAuthTokens();
    await _manager.clear(storageType: LucidCacheStorageType.secure);
  }

  Future<void> saveEncryptedData<T>(String key, T data) async {
    await _manager.put(key, data, storageType: LucidCacheStorageType.secure, isSecure: true);
  }

  Future<T?> getEncryptedData<T>(String key) async {
    return await _manager.get<T>(key, storageType: LucidCacheStorageType.secure);
  }
}

class SessionLucidCacheHelper {
  const SessionLucidCacheHelper._(this._manager);

  final LucidStorageManager _manager;

  static const Duration _sessionTtl = Duration(minutes: 30);
  static const String _prefix = 'session_';

  Future<void> startSession(String userId, LucidJsonMap sessionData) async {
    await _manager.put(
      '${_prefix}user_$userId',
      sessionData,
      ttl: _sessionTtl,
      priority: LucidCachePriority.high,
      tags: ['session', 'user'],
    );
  }

  Future<LucidJsonMap?> getSession(String userId) async {
    return await _manager.get<LucidJsonMap>('${_prefix}user_$userId');
  }

  Future<void> updateSession(String userId, LucidJsonMap updates) async {
    final existing = await getSession(userId) ?? <String, dynamic>{};
    existing.addAll(updates);
    await startSession(userId, existing);
  }

  Future<void> endSession(String userId) async {
    await _manager.delete('${_prefix}user_$userId');
  }

  Future<void> extendSession(String userId) async {
    final sessionData = await getSession(userId);
    if (sessionData != null) {
      await startSession(userId, sessionData);
    }
  }

  Future<bool> isSessionActive(String userId) async {
    return await _manager.containsKey('${_prefix}user_$userId');
  }

  Future<void> clearAllSessions() async {
    await _manager.deleteByTag('session');
  }
}

class LucidCacheMethodDecorator<T> {
  const LucidCacheMethodDecorator({
    this.ttl = const Duration(minutes: 15),
    this.key,
    this.tags = const [],
    this.storageType = LucidCacheStorageType.memory,
  });

  final Duration ttl;
  final String? key;
  final List<String> tags;
  final LucidCacheStorageType storageType;

  Future<T> execute(String methodName, Future<T> Function() method, {List<dynamic> args = const []}) async {
    final cacheKey = key ?? _generateCacheKey(methodName, args);

    return await LucidCacheHelper.manager.getOrPut<T>(cacheKey, method, ttl: ttl, tags: tags, storageType: storageType);
  }

  String _generateCacheKey(String methodName, List<dynamic> args) {
    final argsHash = args.isNotEmpty ? args.map((e) => e.hashCode).join('_') : '';
    return 'method_${methodName}_$argsHash';
  }
}

class LucidCacheKeyBuilder {
  LucidCacheKeyBuilder._(this._segments);

  factory LucidCacheKeyBuilder() => LucidCacheKeyBuilder._([]);

  factory LucidCacheKeyBuilder.withPrefix(String prefix) => LucidCacheKeyBuilder._([prefix]);

  final List<String> _segments;

  LucidCacheKeyBuilder add(String segment) {
    return LucidCacheKeyBuilder._([..._segments, segment]);
  }

  LucidCacheKeyBuilder addAll(List<String> segments) {
    return LucidCacheKeyBuilder._([..._segments, ...segments]);
  }

  LucidCacheKeyBuilder withVersion(String version) {
    return add('v$version');
  }

  LucidCacheKeyBuilder withUserId(String userId) {
    return add('user_$userId');
  }

  LucidCacheKeyBuilder withTimestamp() {
    return add('ts_${DateTime.now().millisecondsSinceEpoch}');
  }

  String build() => _segments.join('_');

  @override
  String toString() => build();
}
