import 'dart:io';

/// Implémentation disque réelle du sink de log fichier.
class LucidLogFileSink {
  IOSink? _sink;

  Future<int> open(String path) async {
    final file = File(path);

    if (await file.exists()) {
      final size = (await file.stat()).size;
      _sink = file.openWrite(mode: FileMode.append);
      return size;
    }

    await file.create(recursive: true);
    _sink = file.openWrite(mode: FileMode.append);
    return 0;
  }

  void writeLine(String line) => _sink?.writeln(line);

  Future<void> rotate(String basePath, int maxFiles) async {
    await _sink?.close();

    final extension = basePath.split('.').last;
    final nameWithoutExt = basePath.substring(0, basePath.lastIndexOf('.'));

    for (int i = maxFiles - 1; i > 0; i--) {
      final oldFile = File('$nameWithoutExt.$i.$extension');
      final newFile = File('$nameWithoutExt.${i + 1}.$extension');

      if (await oldFile.exists()) {
        if (i == maxFiles - 1) {
          await oldFile.delete();
        } else {
          await oldFile.rename(newFile.path);
        }
      }
    }

    final currentFile = File(basePath);
    if (await currentFile.exists()) {
      await currentFile.rename('$nameWithoutExt.1.$extension');
    }

    _sink = File(basePath).openWrite();
  }

  Future<void> flush() async => _sink?.flush();

  Future<void> close() async => _sink?.close();
}
