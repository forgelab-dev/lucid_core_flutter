import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

import '../../../scripts/logger/logger.dart';
import '../../core/core.dart';

class LucidCacheStorage {
  LucidCacheStorage._({required this.config});

  static LucidCacheStorage? _instance;

  final logger = LucidLogger.instance;

  final LucidCacheConfig config;
  final LucidEntriesMap<LucidCacheItem> _memoryCache = {};
  final LucidEntriesMap<DateTime> _accessLog = {};

  Directory? _cacheDirectory;
  bool _isInitialized = false;

  int _hitCount = 0;
  int _missCount = 0;

  static Future<LucidCacheStorage> getInstance({
    LucidCacheConfig? config,
  }) async {
    _instance ??= LucidCacheStorage._(
      config: config ?? const LucidCacheConfig(),
    );
    await _instance!._initialize();
    return _instance!;
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      if (config.persistToDisk) {
        await _initializeDiskStorage();
        await _loadFromDisk();
      }

      _startCleanupTimer();
      _isInitialized = true;
    } catch (e) {
      throw CacheException('Erreur lors de l\'initialisation du cache: $e');
    }
  }

  Future<void> _initializeDiskStorage() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDirectory = Directory('${appDir.path}/${config.cacheDirectory}');

      if (!await _cacheDirectory!.exists()) {
        await _cacheDirectory!.create(recursive: true);
      }
    } catch (e) {
      throw CacheException('Impossible de créer le répertoire de cache: $e');
    }
  }

  Future<void> _loadFromDisk() async {
    if (_cacheDirectory == null) return;

    try {
      final files = _cacheDirectory!.listSync().whereType<File>().where(
        (file) => file.path.endsWith('.cache'),
      );

      for (final file in files) {
        try {
          final content = await file.readAsString();
          final item = LucidCacheItem.fromJson(content);

          if (!item.isExpired) {
            _memoryCache[item.key] = item;
          } else {
            await file.delete();
          }
        } catch (e) {
          await file.delete();
        }
      }
    } catch (e) {
      throw CacheException('Erreur lors du chargement depuis le disque: $e');
    }
  }

  int get hitCount => _hitCount;

  int get missCount => _missCount;

  int get totalRequests => _hitCount + _missCount;

  double get hitRate => _calculateHitRate();

  String _serializeData(dynamic data) {
    try {
      return jsonEncode(data);
    } catch (e) {
      throw CacheException('Impossible de sérialiser les données: $e');
    }
  }

  T? _deserializeData<T>(String data) {
    try {
      final decoded = jsonDecode(data);
      return decoded as T?;
    } catch (e) {
      throw CacheException('Impossible de désérialiser les données: $e');
    }
  }

  String _hashKey(String key) {
    return sha256.convert(utf8.encode(key)).toString();
  }

  String? _findLeastRecentlyUsed() {
    DateTime? oldestAccess;
    String? keyToEvict;

    for (final entry in _accessLog.entries) {
      if (oldestAccess == null || entry.value.isBefore(oldestAccess)) {
        oldestAccess = entry.value;
        keyToEvict = entry.key;
      }
    }

    return keyToEvict;
  }

  String? _findLeastRecentlyAccessed() {
    DateTime? oldestAccess;
    String? keyToEvict;

    for (final entry in _memoryCache.entries) {
      final item = entry.value;
      if (oldestAccess == null || item.lastAccessedAt.isBefore(oldestAccess)) {
        oldestAccess = item.lastAccessedAt;
        keyToEvict = entry.key;
      }
    }

    return keyToEvict;
  }

  String? _findOldest() {
    DateTime? oldest;
    String? keyToEvict;

    for (final entry in _memoryCache.entries) {
      final item = entry.value;
      if (oldest == null || item.createdAt.isBefore(oldest)) {
        oldest = item.createdAt;
        keyToEvict = entry.key;
      }
    }

    return keyToEvict;
  }

  String? _findShortestTtl() {
    Duration? shortestTtl;
    String? keyToEvict;

    for (final entry in _memoryCache.entries) {
      final item = entry.value;
      final remainingTtl = item.timeUntilExpiry;

      if (remainingTtl != null &&
          (shortestTtl == null || remainingTtl < shortestTtl)) {
        shortestTtl = remainingTtl;
        keyToEvict = entry.key;
      }
    }

    return keyToEvict;
  }

  String? _findLowestPriority() {
    LucidCachePriority? lowestPriority;
    String? keyToEvict;

    for (final entry in _memoryCache.entries) {
      final item = entry.value;
      if (item.priority != LucidCachePriority.critical &&
          (lowestPriority == null ||
              item.priority.value < lowestPriority.value)) {
        lowestPriority = item.priority;
        keyToEvict = entry.key;
      }
    }

    return keyToEvict;
  }

  int _getCurrentSize() {
    return _memoryCache.values.fold<int>(
      0,
      (sum, item) => sum + item.sizeInBytes,
    );
  }

  double _calculateHitRate() {
    final totalRequests = _hitCount + _missCount;
    if (totalRequests == 0) return 0.0;
    return _hitCount / totalRequests;
  }

  Duration _calculateAverageAge() {
    if (_memoryCache.isEmpty) return Duration.zero;

    final totalAge = _memoryCache.values.fold<int>(
      0,
      (sum, item) => sum + item.age.inMilliseconds,
    );

    return Duration(milliseconds: totalAge ~/ _memoryCache.length);
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw const CacheException('Cache service non initialisé');
    }
  }

  void _startCleanupTimer() {
    Timer.periodic(config.cleanupInterval, (_) => _performCleanup());
  }

  void resetHitRateStats() {
    _hitCount = 0;
    _missCount = 0;
  }

  Future<void> _saveToDisk(LucidCacheItem item) async {
    if (_cacheDirectory == null) return;

    try {
      final file = File('${_cacheDirectory!.path}/${_hashKey(item.key)}.cache');
      await file.writeAsString(item.toJson());
    } catch (e) {
      logger.info('Erreur lors de la sauvegarde sur disque: $e');
    }
  }

  Future<void> _enforceConstraints() async {
    while (_getCurrentSize() > config.maxSize) {
      await _evictOne();
    }

    while (_memoryCache.length > config.maxItems) {
      await _evictOne();
    }
  }

  Future<void> _evictOne() async {
    if (_memoryCache.isEmpty) return;

    String? keyToEvict;

    switch (config.evictionPolicy) {
      case LucidEvictionPolicy.lru:
        keyToEvict = _findLeastRecentlyUsed();
        break;
      case LucidEvictionPolicy.lra:
        keyToEvict = _findLeastRecentlyAccessed();
        break;
      case LucidEvictionPolicy.fifo:
        keyToEvict = _findOldest();
        break;
      case LucidEvictionPolicy.ttl:
        keyToEvict = _findShortestTtl();
        break;
      case LucidEvictionPolicy.priority:
        keyToEvict = _findLowestPriority();
        break;
    }

    if (keyToEvict != null) {
      await delete(keyToEvict);
    }
  }

  Future<void> _performCleanup() async {
    final keysToDelete = <String>[];

    for (final entry in _memoryCache.entries) {
      if (entry.value.isExpired) {
        keysToDelete.add(entry.key);
      }
    }

    for (final key in keysToDelete) {
      await delete(key);
    }
  }

  Future<void> put(
    String key,
    dynamic data, {
    Duration? ttl,
    List<String> tags = const [],
    LucidCachePriority priority = LucidCachePriority.normal,
    LucidJsonMap metadata = const {},
    bool forceOverwrite = false,
  }) async {
    _ensureInitialized();

    if (!forceOverwrite && await containsKey(key)) {
      final existing = _memoryCache[key]!;
      if (existing.priority == LucidCachePriority.critical) {
        throw CacheException('Impossible d\'écraser un élément critique: $key');
      }
    }

    final serializedData = _serializeData(data);
    final now = DateTime.now();

    final item = LucidCacheItem(
      key: key,
      value: serializedData,
      createdAt: now,
      lastAccessedAt: now,
      ttl: ttl ?? config.defaultTtl,
      tags: tags,
      priority: priority,
      metadata: metadata,
    );

    _memoryCache[key] = item;
    _accessLog[key] = now;

    if (config.persistToDisk) {
      await _saveToDisk(item);
    }

    await _enforceConstraints();
  }

  Future<T?> get<T>(String key) async {
    _ensureInitialized();

    final item = _memoryCache[key];
    if (item == null) {
      _missCount++;
      return null;
    }

    if (item.isExpired) {
      await delete(key);
      _missCount++;
      return null;
    }

    _hitCount++;
    _accessLog[key] = DateTime.now();
    _memoryCache[key] = item.touch();

    return _deserializeData<T>(item.value);
  }

  Future<T?> getOrPut<T>(
    String key,
    LucidAsyncValueCallBack<T> factory, {
    Duration? ttl,
    List<String> tags = const [],
    LucidCachePriority priority = LucidCachePriority.normal,
  }) async {
    final cached = await get<T>(key);
    if (cached != null) return cached;

    final value = await factory();
    await put(key, value, ttl: ttl, tags: tags, priority: priority);
    return value;
  }

  Future<bool> containsKey(String key) async {
    _ensureInitialized();

    final item = _memoryCache[key];
    if (item == null) return false;

    if (item.isExpired) {
      await delete(key);
      return false;
    }

    return true;
  }

  Future<bool> delete(String key) async {
    _ensureInitialized();

    final removed = _memoryCache.remove(key) != null;
    _accessLog.remove(key);

    if (config.persistToDisk && _cacheDirectory != null) {
      final file = File('${_cacheDirectory!.path}/${_hashKey(key)}.cache');
      if (await file.exists()) {
        await file.delete();
      }
    }

    return removed;
  }

  Future<void> clear() async {
    _ensureInitialized();

    _memoryCache.clear();
    _accessLog.clear();

    if (config.persistToDisk && _cacheDirectory != null) {
      final files = _cacheDirectory!.listSync().whereType<File>().where(
        (file) => file.path.endsWith('.cache'),
      );

      for (final file in files) {
        await file.delete();
      }
    }
  }

  Future<LucidJsonMap> getByTag(String tag) async {
    _ensureInitialized();

    final result = <String, dynamic>{};

    for (final entry in _memoryCache.entries) {
      final item = entry.value;
      if (item.tags.contains(tag) && !item.isExpired) {
        result[entry.key] = _deserializeData<LucidCacheItem>(item.value);
      }
    }

    return result;
  }

  Future<int> deleteByTag(String tag) async {
    _ensureInitialized();

    final keysToDelete = <String>[];

    for (final entry in _memoryCache.entries) {
      if (entry.value.tags.contains(tag)) {
        keysToDelete.add(entry.key);
      }
    }

    for (final key in keysToDelete) {
      await delete(key);
    }

    return keysToDelete.length;
  }

  Future<bool> updateTtl(String key, Duration newTtl) async {
    _ensureInitialized();

    final item = _memoryCache[key];
    if (item == null || item.isExpired) return false;

    _memoryCache[key] = item.copyWith(ttl: newTtl);

    if (config.persistToDisk) {
      await _saveToDisk(_memoryCache[key]!);
    }

    return true;
  }

  Future<LucidCacheStats> getStats() async {
    _ensureInitialized();

    await _performCleanup();

    final totalItems = _memoryCache.length;
    final totalSize = _memoryCache.values.fold<int>(
      0,
      (sum, item) => sum + item.sizeInBytes,
    );

    final expiredCount = _memoryCache.values
        .where((item) => item.isExpired)
        .length;

    final priorityCount = <LucidCachePriority, int>{};
    for (final priority in LucidCachePriority.values) {
      priorityCount[priority] = _memoryCache.values
          .where((item) => item.priority == priority)
          .length;
    }

    final tagCount = <String, int>{};
    for (final item in _memoryCache.values) {
      for (final tag in item.tags) {
        tagCount[tag] = (tagCount[tag] ?? 0) + 1;
      }
    }

    return LucidCacheStats(
      totalItems: totalItems,
      totalSize: totalSize,
      expiredItems: expiredCount,
      hitRate: _calculateHitRate(),
      averageAge: _calculateAverageAge(),
      priorityDistribution: priorityCount,
      tagDistribution: tagCount,
      maxSize: config.maxSize,
      maxItems: config.maxItems,
    );
  }

  Future<void> exportToFile(String filePath) async {
    _ensureInitialized();

    final exportData = {
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'config': {
        'maxSize': config.maxSize,
        'maxItems': config.maxItems,
        'defaultTtl': config.defaultTtl.inMilliseconds,
      },
      'items': _memoryCache.values.map((item) => item.toMap()).toList(),
    };

    final file = File(filePath);
    await file.writeAsString(jsonEncode(exportData));
  }

  Future<void> importFromFile(
    String filePath, {
    bool clearExisting = false,
  }) async {
    _ensureInitialized();

    if (clearExisting) {
      await clear();
    }

    final file = File(filePath);
    if (!await file.exists()) {
      throw CacheException('Fichier d\'import non trouvé: $filePath');
    }

    try {
      final content = await file.readAsString();
      final importData = jsonDecode(content) as Map<String, dynamic>;

      final items = importData['items'] as List;

      for (final itemData in items) {
        final item = LucidCacheItem.fromMap(itemData as Map<String, dynamic>);
        if (!item.isExpired) {
          _memoryCache[item.key] = item;
          if (config.persistToDisk) {
            await _saveToDisk(item);
          }
        }
      }
    } catch (e) {
      throw CacheException('Erreur lors de l\'import: $e');
    }
  }

  Future<void> dispose() async {
    if (config.persistToDisk) {
      for (final item in _memoryCache.values) {
        await _saveToDisk(item);
      }
    }

    _memoryCache.clear();
    _accessLog.clear();
    _isInitialized = false;
  }
}
