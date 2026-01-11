import 'dart:convert';
import '../storage/secure_storage_service.dart';
import '../../features/auth/data/models/current_account_model.dart';

/// Service for caching current account information
class CurrentAccountCacheService {
  CurrentAccountCacheService._();

  static const String _keyCurrentAccount = 'current_account_cache';
  static const String _keyCacheTimestamp = 'current_account_cache_timestamp';

  /// Cache duration: 24 hours in milliseconds
  static const int _cacheDurationMs = 24 * 60 * 60 * 1000;

  /// Save current account to cache
  static Future<void> saveCurrentAccount(CurrentAccountModel account) async {
    try {
      final jsonString = jsonEncode(account.toJson());
      await _saveToStorage(_keyCurrentAccount, jsonString);
      await _saveToStorage(
        _keyCacheTimestamp,
        DateTime.now().millisecondsSinceEpoch.toString(),
      );
    } catch (e) {
      // Silently fail - cache is optional
      print('Failed to cache current account: $e');
    }
  }

  /// Get current account from cache
  static Future<CurrentAccountModel?> getCurrentAccount() async {
    try {
      final jsonString = await _getFromStorage(_keyCurrentAccount);
      if (jsonString == null) return null;

      // Check if cache is still valid
      final timestampStr = await _getFromStorage(_keyCacheTimestamp);
      if (timestampStr != null) {
        final timestamp = int.tryParse(timestampStr);
        if (timestamp != null) {
          final now = DateTime.now().millisecondsSinceEpoch;
          if (now - timestamp > _cacheDurationMs) {
            // Cache expired
            await clearCache();
            return null;
          }
        }
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return CurrentAccountModel.fromJson(json);
    } catch (e) {
      // Cache corrupted or invalid
      await clearCache();
      return null;
    }
  }

  /// Clear current account cache
  static Future<void> clearCache() async {
    try {
      await _deleteFromStorage(_keyCurrentAccount);
      await _deleteFromStorage(_keyCacheTimestamp);
    } catch (e) {
      // Silently fail
      print('Failed to clear cache: $e');
    }
  }

  /// Check if cache exists and is valid
  static Future<bool> hasValidCache() async {
    try {
      final account = await getCurrentAccount();
      return account != null;
    } catch (e) {
      return false;
    }
  }

  // Helper methods to work with secure storage
  static Future<void> _saveToStorage(String key, String value) async {
    await SecureStorageService.storage.write(key: key, value: value);
  }

  static Future<String?> _getFromStorage(String key) async {
    return await SecureStorageService.storage.read(key: key);
  }

  static Future<void> _deleteFromStorage(String key) async {
    await SecureStorageService.storage.delete(key: key);
  }
}
