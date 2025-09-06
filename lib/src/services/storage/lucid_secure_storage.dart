import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../scripts/logger/logger.dart';
import '../../core/core.dart'
    show
        LucidAbstractStorageService,
        LucidConfigHelpers,
        LucidGlobalConfig,
        StorageException;

class LucidSecureStorage implements LucidAbstractStorageService {
  static LucidSecureStorage? _instance;

  late FlutterSecureStorage _secureStorage;

  final LucidConfigHelpers _config;

  final logger = LucidLogger.instance;

  static LucidSecureStorage getInstance([LucidConfigHelpers? config]) {
    final configToUse = config ?? LucidGlobalConfig.current;
    _instance ??= LucidSecureStorage._(configToUse);
    return _instance!;
  }

  LucidSecureStorage._(this._config) {
    _initializeStorage();
  }

  void _initializeStorage() {
    _secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        sharedPreferencesName: _config.storageSecureStorageKey,
        preferencesKeyPrefix: _config.storagePrefixKey,
      ),
      iOptions: IOSOptions(
        groupId: _config.storageGroupName,
        accountName: _config.appName,
      ),
    );
  }

  @override
  Future<void> clear() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw StorageException.clearError();
    }
  }

  @override
  Future<void> close() async {
    logger.warn("Fermeture du storage");
  }

  @override
  Future<bool> containsKey(String key) async {
    return await _secureStorage.containsKey(key: key);
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw StorageException.clearError(path: key);
    }
  }

  @override
  Future<Set<String>> getKeys() async {
    try {
      final data = await _secureStorage.readAll();
      return data.keys.toSet();
    } catch (e) {
      throw const StorageException("Impossible de récupérer les clés");
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      throw StorageException.readError(path: key);
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      throw StorageException.writeError(path: key);
    }
  }

  Future<void> saveAuthToken(String token) async {
    await write(_config.storageTokenKey, token);
  }

  Future<String?> getAuthToken() async {
    return await read(_config.storageTokenKey);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await write(_config.storageTokenKey, refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await read(_config.storageTokenKey);
  }

  Future<void> clearAuthTokens() async {
    await delete(_config.storageTokenKey);
    await delete(_config.storageTokenKey);
  }
}
