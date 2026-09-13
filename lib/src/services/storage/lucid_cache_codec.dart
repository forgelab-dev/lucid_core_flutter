import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:encrypt/encrypt.dart' as enc;

import '../../core/core.dart' show LucidAbstractStorageService;

/// Compresse (gzip) et/ou chiffre (AES-256-GCM) le contenu persisté sur
/// disque par [LucidCacheStorage].
///
/// À l'écriture : compression puis chiffrement (les données chiffrées ne
/// compressent plus). À la lecture : déchiffrement puis décompression.
class LucidCacheCodec {
  LucidCacheCodec({required this.compressionEnabled, enc.Key? encryptionKey})
    : _encrypter = encryptionKey != null ? enc.Encrypter(enc.AES(encryptionKey, mode: enc.AESMode.gcm)) : null;

  final bool compressionEnabled;
  final enc.Encrypter? _encrypter;

  static const int _ivLength = 12;
  static const String _keyStorageKey = 'lucid_cache_encryption_key';

  /// Construit un codec, en récupérant (ou générant et persistant) la clé de
  /// chiffrement dans [keyStorage] si [encryptionEnabled] est vrai.
  static Future<LucidCacheCodec> create({
    required bool compressionEnabled,
    required bool encryptionEnabled,
    LucidAbstractStorageService? keyStorage,
  }) async {
    enc.Key? key;
    if (encryptionEnabled && keyStorage != null) {
      key = await _loadOrCreateKey(keyStorage);
    }
    return LucidCacheCodec(compressionEnabled: compressionEnabled, encryptionKey: key);
  }

  static Future<enc.Key> _loadOrCreateKey(LucidAbstractStorageService storage) async {
    final existing = await storage.read(_keyStorageKey);
    if (existing != null) return enc.Key.fromBase64(existing);

    final newKey = enc.Key.fromSecureRandom(32);
    await storage.write(_keyStorageKey, newKey.base64);
    return newKey;
  }

  String encode(String plainText) {
    List<int> bytes = utf8.encode(plainText);

    if (compressionEnabled) {
      bytes = const GZipEncoder().encodeBytes(bytes);
    }

    final encrypter = _encrypter;
    if (encrypter != null) {
      final iv = enc.IV.fromSecureRandom(_ivLength);
      final encrypted = encrypter.encryptBytes(bytes, iv: iv);
      bytes = [...iv.bytes, ...encrypted.bytes];
    }

    return base64Encode(bytes);
  }

  String decode(String encoded) {
    List<int> bytes = base64Decode(encoded);

    final encrypter = _encrypter;
    if (encrypter != null) {
      final iv = enc.IV(Uint8List.fromList(bytes.sublist(0, _ivLength)));
      final cipherBytes = Uint8List.fromList(bytes.sublist(_ivLength));
      bytes = encrypter.decryptBytes(enc.Encrypted(cipherBytes), iv: iv);
    }

    if (compressionEnabled) {
      bytes = const GZipDecoder().decodeBytes(bytes);
    }

    return utf8.decode(bytes);
  }
}
