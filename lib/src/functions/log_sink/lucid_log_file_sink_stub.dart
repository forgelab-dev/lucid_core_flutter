/// Sink de repli pour le web : le logging fichier n'a pas de sens dans un
/// navigateur (pas de système de fichiers), donc il est simplement no-op au
/// lieu de faire échouer la compilation du package sur cette plateforme.
class LucidLogFileSink {
  Future<int> open(String path) async => 0;

  void writeLine(String line) {}

  Future<void> rotate(String basePath, int maxFiles) async {}

  Future<void> flush() async {}

  Future<void> close() async {}
}
