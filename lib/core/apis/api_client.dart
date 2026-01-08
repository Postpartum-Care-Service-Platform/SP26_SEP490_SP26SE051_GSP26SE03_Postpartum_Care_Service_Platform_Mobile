import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';

/// API Client using Dio
/// Configured with base URL and interceptors
/// Automatically adds access token to requests
class ApiClient {
  ApiClient._();

  static Dio? _dio;

  static Dio get dio {
    if (_dio != null) return _dio!;

    final baseUrl = AppConfig.apiUrl;
    final isLocalhost = baseUrl.contains('localhost') || 
                       baseUrl.contains('127.0.0.1') || 
                       baseUrl.contains('10.0.2.2');

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // For development with localhost and self-signed certificates
    if (isLocalhost && !kReleaseMode) {
      (_dio!.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    // Add interceptors
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add access token to headers
          final token = await SecureStorageService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          // Handle errors globally
          return handler.next(error);
        },
      ),
    );

    // Add logging interceptor in debug mode
    // _dio!.interceptors.add(LogInterceptor(
    //   requestBody: true,
    //   responseBody: true,
    // ));

    return _dio!;
  }

  /// Reset client (useful for testing or logout)
  static void reset() {
    _dio = null;
  }
}

