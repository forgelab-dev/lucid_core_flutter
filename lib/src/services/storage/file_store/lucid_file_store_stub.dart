/// Implémentation de repli pour le web (pas de système de fichiers) : le
/// cache disque et l'export/import de fichiers sont désactivés proprement au
/// lieu de faire échouer la compilation du package sur cette plateforme.
class LucidFileStore {
  const LucidFileStore();

  bool get isSupported => false;

  Future<String?> resolveCacheDirectory(String subDirectory) async => null;

  Future<List<String>> listFiles(String directoryPath, String extension) async => const [];

  Future<String?> readFile(String path) async => null;

  Future<void> writeFile(String path, String content) async {}

  Future<void> deleteFile(String path) async {}

  Future<bool> fileExists(String path) async => false;
}
