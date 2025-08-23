import 'dart:convert';

import '../constants/constants.dart' show LucidDataList, LucidJsonMap, LucidCachePriority, LucidDurationExtensions;

class LucidCacheItem {
  final String key;
  final String value;
  final DateTime createdAt;
  final DateTime lastAccessedAt;
  final Duration? ttl;
  final LucidDataList<String> tags;
  final LucidCachePriority priority;
  final LucidJsonMap metadata;

  LucidCacheItem({
    required this.key,
    required this.value,
    required this.createdAt,
    required this.lastAccessedAt,
    this.ttl,
    this.tags = const [],
    this.priority = LucidCachePriority.normal,
    this.metadata = const {},
  });

  LucidCacheItem copyWith({
    String? key,
    String? value,
    DateTime? createdAt,
    DateTime? lastAccessedAt,
    Duration? ttl,
    LucidDataList<String>? tags,
    LucidCachePriority? priority,
    LucidJsonMap? metadata,
  }) {
    return LucidCacheItem(
      key: key ?? this.key,
      value: value ?? this.value,
      createdAt: createdAt ?? this.createdAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      ttl: ttl ?? this.ttl,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
      metadata: metadata ?? this.metadata,
    );
  }

  LucidCacheItem touch() => copyWith(lastAccessedAt: DateTime.now());

  LucidJsonMap toMap() {
    return {
      'key': key,
      'value': value,
      'createdAt': createdAt,
      'lastAccessedAt': lastAccessedAt,
      'ttl': ttl,
      'tags': tags,
      'priority': priority,
      'metadata': metadata,
    };
  }

  factory LucidCacheItem.fromMap(LucidJsonMap map) {
    return LucidCacheItem(
      key: map['key'] as String,
      value: map['value'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastAccessedAt: DateTime.parse(map['lastAccessedAt'] as String),
      ttl: map['ttl'] != null ? Duration(milliseconds: map['ttl'] as int) : null,
      tags: LucidDataList<String>.from(map['tags'] as List),
      priority: LucidCachePriority.values[map['priority'] as int],
      metadata: LucidJsonMap.from(map['metadata'] as Map),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory LucidCacheItem.fromJson(String json) => LucidCacheItem.fromMap(jsonDecode(json) as LucidJsonMap);

  @override
  String toString() {
    return 'CacheItem(key: $key, size: ${sizeInBytes}B, expired: $isExpired, age: ${age.formatted})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LucidCacheItem && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;

  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().isAfter(createdAt.add(ttl!));
  }

  Duration? get timeUntilExpiry {
    if (ttl == null) return null;
    final expiryTime = createdAt.add(ttl!);
    final now = DateTime.now();
    return expiryTime.isAfter(now) ? expiryTime.difference(now) : Duration.zero;
  }

  int get sizeInBytes => value.length * 2;

  Duration get age => DateTime.now().difference(createdAt);

  Duration get timeSinceLastAccess => DateTime.now().difference(lastAccessedAt);
}
