import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Implémentation disque réelle, utilisée sur Android/iOS/Windows/Linux/macOS.
class LucidFileStore {
  const LucidFileStore();

  bool get isSupported => true;

  Future<String?> resolveCacheDirectory(String subDirectory) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/$subDirectory');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  Future<List<String>> listFiles(String directoryPath, String extension) async {
    final dir = Directory(directoryPath);
    if (!await dir.exists()) return const [];

    return dir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith(extension))
        .map((file) => file.path)
        .toList();
  }

  Future<String?> readFile(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  Future<void> writeFile(String path, String content) async {
    await File(path).writeAsString(content);
  }

  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  Future<bool> fileExists(String path) => File(path).exists();
}
