import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

/// Secure storage service with AES-256 encryption
///
/// This service provides encrypted storage for sensitive data like auth tokens.
/// It uses:
/// - AES-256-CBC encryption for data
/// - FlutterSecureStorage for encryption keys (stored in Android Keystore/iOS Keychain)
/// - PKCS7 padding
class SecureStorageService {
  // FlutterSecureStorage instance - stores encryption key securely in OS keychain
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Keys for storing encryption key and IV
  static const _encryptionKeyStorageKey = 'aes_encryption_key';
  static const _encryptionIVStorageKey = 'aes_encryption_iv';

  // Singleton pattern
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  encrypt.Key? _encryptionKey;
  encrypt.IV? _encryptionIV;

  /// Initialize encryption keys
  /// This should be called once when the app starts
  Future<void> initialize() async {
    // Try to load existing encryption key
    String? keyString = await _secureStorage.read(key: _encryptionKeyStorageKey);
    String? ivString = await _secureStorage.read(key: _encryptionIVStorageKey);

    if (keyString != null && ivString != null) {
      // Use existing key and IV
      _encryptionKey = encrypt.Key.fromBase64(keyString);
      _encryptionIV = encrypt.IV.fromBase64(ivString);
    } else {
      // Generate new key and IV
      _encryptionKey = encrypt.Key.fromSecureRandom(32); // 256-bit key
      _encryptionIV = encrypt.IV.fromSecureRandom(16); // 128-bit IV

      // Store them securely
      await _secureStorage.write(
        key: _encryptionKeyStorageKey,
        value: _encryptionKey!.base64,
      );
      await _secureStorage.write(
        key: _encryptionIVStorageKey,
        value: _encryptionIV!.base64,
      );
    }
  }

  /// Encrypt and store a value
  Future<void> write(String key, String value) async {
    if (_encryptionKey == null || _encryptionIV == null) {
      await initialize();
    }

    // Encrypt the value using AES-256-CBC
    final encrypter = encrypt.Encrypter(
      encrypt.AES(_encryptionKey!, mode: encrypt.AESMode.cbc),
    );

    final encrypted = encrypter.encrypt(value, iv: _encryptionIV!);

    // Store encrypted value in secure storage
    await _secureStorage.write(
      key: 'encrypted_$key',
      value: encrypted.base64,
    );
  }

  /// Read and decrypt a value
  Future<String?> read(String key) async {
    if (_encryptionKey == null || _encryptionIV == null) {
      await initialize();
    }

    // Read encrypted value
    final encryptedValue = await _secureStorage.read(key: 'encrypted_$key');

    if (encryptedValue == null) {
      return null;
    }

    try {
      // Decrypt the value
      final encrypter = encrypt.Encrypter(
        encrypt.AES(_encryptionKey!, mode: encrypt.AESMode.cbc),
      );

      final decrypted = encrypter.decrypt64(encryptedValue, iv: _encryptionIV!);
      return decrypted;
    } catch (e) {
      // If decryption fails, return null
      return null;
    }
  }

  /// Delete a value
  Future<void> delete(String key) async {
    await _secureStorage.delete(key: 'encrypted_$key');
  }

  /// Delete all encrypted values
  Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
  }

  /// Check if a key exists
  Future<bool> containsKey(String key) async {
    final value = await _secureStorage.read(key: 'encrypted_$key');
    return value != null;
  }

  // =========================================================================
  // Convenience methods for common data types
  // =========================================================================

  /// Store an integer
  Future<void> writeInt(String key, int value) async {
    await write(key, value.toString());
  }

  /// Read an integer
  Future<int?> readInt(String key) async {
    final value = await read(key);
    return value != null ? int.tryParse(value) : null;
  }

  /// Store a boolean
  Future<void> writeBool(String key, bool value) async {
    await write(key, value.toString());
  }

  /// Read a boolean
  Future<bool?> readBool(String key) async {
    final value = await read(key);
    return value != null ? value.toLowerCase() == 'true' : null;
  }

  /// Store a JSON object
  Future<void> writeJson(String key, Map<String, dynamic> json) async {
    await write(key, jsonEncode(json));
  }

  /// Read a JSON object
  Future<Map<String, dynamic>?> readJson(String key) async {
    final value = await read(key);
    return value != null ? jsonDecode(value) : null;
  }
}
