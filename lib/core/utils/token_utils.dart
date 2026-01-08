import '../storage/secure_storage_service.dart';

/// Token utility functions
class TokenUtils {
  TokenUtils._();

  /// Check if token is expired based on expiresAt timestamp
  /// Returns true if token is expired or will expire within the next minute
  static Future<bool> isTokenExpired() async {
    try {
      final expiresAtStr = await SecureStorageService.getExpiresAt();
      if (expiresAtStr == null || expiresAtStr.isEmpty) {
        return true; // Consider expired if no expiry info
      }

      final expiresAt = DateTime.parse(expiresAtStr).toUtc();
      final now = DateTime.now().toUtc();
      
      // Add 1 minute buffer to refresh before actual expiration
      const buffer = Duration(minutes: 1);
      return now.add(buffer).isAfter(expiresAt);
    } catch (e) {
      // If parsing fails, consider expired
      return true;
    }
  }

  /// Check if token is expired (synchronous version with provided expiresAt)
  static bool isTokenExpiredSync(String? expiresAtStr) {
    if (expiresAtStr == null || expiresAtStr.isEmpty) {
      return true;
    }

    try {
      final expiresAt = DateTime.parse(expiresAtStr).toUtc();
      final now = DateTime.now().toUtc();
      
      // Add 1 minute buffer to refresh before actual expiration
      const buffer = Duration(minutes: 1);
      return now.add(buffer).isAfter(expiresAt);
    } catch (e) {
      return true;
    }
  }
}
