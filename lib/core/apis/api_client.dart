import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import '../utils/token_utils.dart';
import '../../features/auth/data/models/refresh_token_request_model.dart';
import '../../features/auth/data/models/login_response_model.dart';
import 'api_endpoints.dart';

/// Pending request structure for retry after token refresh
class _PendingRequest {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;

  _PendingRequest(this.requestOptions, this.handler);
}

/// API Client using Dio
/// Configured with base URL and interceptors
/// Automatically adds access token to requests and handles token refresh
class ApiClient {
  ApiClient._();

  static Dio? _dio;
  static Dio? _refreshDio; // Separate Dio instance for refresh token calls
  static bool _isRefreshing = false;
  static final List<_PendingRequest> _pendingRequests = [];

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
          // Skip token refresh for refresh token endpoint
          if (options.path.contains('refresh-token')) {
            return handler.next(options);
          }

          // Check if token is expired and refresh if needed
          final isExpired = await TokenUtils.isTokenExpired();
          if (isExpired && !_isRefreshing) {
            try {
              _isRefreshing = true;
              await _refreshTokenIfNeeded();
              _isRefreshing = false;
              // Get the new token after refresh
              final token = await SecureStorageService.getAccessToken();
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            } catch (e) {
              _isRefreshing = false;
              // If refresh fails, continue with current token
              // The error will be handled by onError interceptor
            }
          } else {
            // Add access token to headers
            final token = await SecureStorageService.getAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized errors by refreshing token
          if (error.response?.statusCode == 401) {
            final requestOptions = error.requestOptions;

            // Skip refresh for refresh token endpoint to avoid infinite loop
            if (requestOptions.path.contains('refresh-token')) {
              return handler.next(error);
            }

            // If already refreshing, queue this request
            if (_isRefreshing) {
              _pendingRequests.add(_PendingRequest(requestOptions, handler));
              return;
            }

            try {
              _isRefreshing = true;
              await _refreshTokenIfNeeded();

              // Get the new token
              final newToken = await SecureStorageService.getAccessToken();
              if (newToken == null || newToken.isEmpty) {
                return handler.next(error);
              }

              // Update the request with new token
              requestOptions.headers['Authorization'] = 'Bearer $newToken';

              // Retry the original request
              final response = await _dio!.fetch(requestOptions);
              handler.resolve(response);

              // Process pending requests
              _processPendingRequests(newToken);
            } catch (e) {
              // Refresh failed, clear tokens and reject pending requests
              await SecureStorageService.clearAll();
              handler.reject(error);
              _rejectPendingRequests(error);
            } finally {
              _isRefreshing = false;
              _pendingRequests.clear();
            }
          } else {
            return handler.next(error);
          }
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

  /// Get or create a separate Dio instance for refresh token calls
  /// This avoids interceptor loops
  static Dio get _refreshDioInstance {
    if (_refreshDio != null) return _refreshDio!;

    final baseUrl = AppConfig.apiUrl;
    final isLocalhost = baseUrl.contains('localhost') || 
                       baseUrl.contains('127.0.0.1') || 
                       baseUrl.contains('10.0.2.2');

    _refreshDio = Dio(
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
      (_refreshDio!.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    return _refreshDio!;
  }

  /// Refresh token if needed
  static Future<void> _refreshTokenIfNeeded() async {
    final refreshToken = await SecureStorageService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('No refresh token available');
    }

    try {
      final request = RefreshTokenRequestModel(refreshToken: refreshToken);
      final response = await _refreshDioInstance.post(
        ApiEndpoints.refreshToken,
        data: request.toJson(),
      );

      final loginResponse = LoginResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Save new tokens to secure storage
      await SecureStorageService.saveAccessToken(loginResponse.accessToken);
      await SecureStorageService.saveRefreshToken(loginResponse.refreshToken);
      await SecureStorageService.saveExpiresAt(loginResponse.expiresAt);
    } catch (e) {
      throw Exception('Failed to refresh token: $e');
    }
  }

  /// Process pending requests after successful token refresh
  static void _processPendingRequests(String newToken) {
    for (final pendingRequest in _pendingRequests) {
      pendingRequest.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      _dio!.fetch(pendingRequest.requestOptions).then(
        (response) => pendingRequest.handler.resolve(response),
        onError: (error) => pendingRequest.handler.reject(error),
      );
    }
  }

  /// Reject all pending requests
  static void _rejectPendingRequests(DioException error) {
    for (final pendingRequest in _pendingRequests) {
      pendingRequest.handler.reject(error);
    }
  }

  /// Reset client (useful for testing or logout)
  static void reset() {
    _dio = null;
    _refreshDio = null;
    _isRefreshing = false;
    _pendingRequests.clear();
  }
}
