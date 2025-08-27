import 'package:shared_preferences/shared_preferences.dart';

import '../../core/abstracts/abstracts.dart';
import '../../core/constants/constants.dart';
import '../../services/logger/logger.dart';

class LucidSharedPreferencesStorage implements LucidAbstractStorageService {
  LucidSharedPreferencesStorage._();

  static LucidSharedPreferencesStorage? _instance;

  final logger = LucidLogger.instance;

  SharedPreferences? _prefs;

  static Future<LucidSharedPreferencesStorage> getInstance() async {
    _instance ??= LucidSharedPreferencesStorage._();
    await _instance!.init();
    return _instance!;
  }

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<void> clear() async {
    try {
      await _prefs!.clear();
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
    return _prefs!.containsKey(key);
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _prefs!.remove(key);
    } catch (e) {
      throw StorageException.clearError(path: key);
    }
  }

  @override
  Future<Set<String>> getKeys() async {
    return _prefs!.getKeys();
  }

  @override
  Future<String?> read(String key) async {
    try {
      return _prefs!.getString(key);
    } catch (e) {
      throw StorageException.readError(path: key);
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _prefs!.setString(key, value);
    } catch (e) {
      throw StorageException.writeError(path: key);
    }
  }
}
