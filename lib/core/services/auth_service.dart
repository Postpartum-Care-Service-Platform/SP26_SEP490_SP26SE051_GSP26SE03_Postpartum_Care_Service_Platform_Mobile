import '../storage/secure_storage_service.dart';

/// Authentication service for checking token validity
class AuthService {
  AuthService._();

  /// Check if user is authenticated (has valid token)
  static Future<bool> isAuthenticated() async {
    final accessToken = await SecureStorageService.getAccessToken();
    final expiresAt = await SecureStorageService.getExpiresAt();

    // No token or expiresAt
    if (accessToken == null || accessToken.isEmpty || expiresAt == null) {
      return false;
    }

    // Check if token is expired
    try {
      final expiresDateTime = DateTime.parse(expiresAt);
      final now = DateTime.now();
      
      // Add 5 minutes buffer to refresh before actual expiration
      final bufferTime = const Duration(minutes: 5);
      
      return expiresDateTime.isAfter(now.add(bufferTime));
    } catch (e) {
      // If parsing fails, consider token invalid
      return false;
    }
  }

  /// Clear all authentication data
  static Future<void> logout() async {
    await SecureStorageService.clearAll();
  }
}

