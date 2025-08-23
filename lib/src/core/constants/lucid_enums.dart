enum LucidStorageOperation { read, write, delete, create, update, clear, close }

enum LucidScreenSize { extraSmall, small, medium, large, extraLarge }

enum LucidEvictionPolicy { lru, lra, fifo, ttl, priority }

enum LucidCacheStorageType { memory, secure, preferences, hybrid }

enum LucidLogLevel {
  trace(0, 'TRACE', '\x1B[37m'), // Blanc
  debug(1, 'DEBUG', '\x1B[36m'), // Cyan
  info(2, 'INFO', '\x1B[32m'), // Vert
  warn(3, 'WARN', '\x1B[33m'), // Jaune
  error(4, 'ERROR', '\x1B[31m'), // Rouge
  fatal(5, 'FATAL', '\x1B[35m'); // Magenta

  const LucidLogLevel(this.value, this.name, this.color);

  final int value;
  final String name;
  final String color;
}

enum LucidCachePriority {
  low(0),
  normal(1),
  high(2),
  critical(3);

  const LucidCachePriority(this.value);

  final int value;
}
