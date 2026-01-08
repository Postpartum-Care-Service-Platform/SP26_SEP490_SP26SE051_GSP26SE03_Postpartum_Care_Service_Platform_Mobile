import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for storing sensitive data
class SecureStorageService {
  SecureStorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Keys
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyExpiresAt = 'expires_at';

  // Access Token
  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  // Refresh Token
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  // Expires At
  static Future<void> saveExpiresAt(String expiresAt) async {
    await _storage.write(key: _keyExpiresAt, value: expiresAt);
  }

  static Future<String?> getExpiresAt() async {
    return await _storage.read(key: _keyExpiresAt);
  }

  // Clear all
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

