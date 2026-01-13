import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration
/// Loads environment variables from .env file
class AppConfig {
  AppConfig._();

  // Base URL configuration
  static String get baseUrl {
    final url = dotenv.env['BASE_URL'] ?? '';
    
    // On Android emulator, replace localhost with 10.0.2.2
    if (Platform.isAndroid && url.contains('localhost')) {
      return url.replaceAll('localhost', '10.0.2.2');
    }
    
    return url;
  }
  
  // API URL (base URL + /api suffix)
  static String get apiUrl => '$baseUrl/api';
  
  // Google OAuth 2.0 Web Client ID
  static String get googleWebClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
  
  /// Initialize configuration
  /// Call this in main() before runApp()
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }
}

