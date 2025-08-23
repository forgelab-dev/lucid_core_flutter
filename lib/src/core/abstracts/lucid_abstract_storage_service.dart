abstract class LucidAbstractStorageService {
  Future<void> write(String key, String value);

  Future<String?> read(String key);

  Future<void> delete(String key);

  Future<bool> containsKey(String key);

  Future<void> clear();

  Future<Set<String>> getKeys();

  Future<void> close();
}
