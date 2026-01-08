import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration
/// Loads environment variables from .env file
class AppConfig {
  AppConfig._();

  static String get baseUrl {
    final url = dotenv.env['BASE_URL'] ?? '';
    
    // On Android emulator, replace localhost with 10.0.2.2
    if (Platform.isAndroid && url.contains('localhost')) {
      return url.replaceAll('localhost', '10.0.2.2');
    }
    
    return url;
  }
  
  static String get apiUrl => '$baseUrl/api';
  
  /// Initialize configuration
  /// Call this in main() before runApp()
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }
}

