import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../../../../core/constants/app_strings.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';
import '../models/verify_email_request_model.dart';
import '../models/verify_email_response_model.dart';
import '../models/forgot_password_request_model.dart';
import '../models/forgot_password_response_model.dart';
import '../models/verify_reset_otp_request_model.dart';
import '../models/verify_reset_otp_response_model.dart';
import '../models/reset_password_request_model.dart';
import '../models/reset_password_response_model.dart';
import '../models/refresh_token_request_model.dart';

/// Remote data source for authentication
abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<RegisterResponseModel> register(RegisterRequestModel request);
  Future<VerifyEmailResponseModel> verifyEmail(VerifyEmailRequestModel request);
  Future<ForgotPasswordResponseModel> resendOtp(ForgotPasswordRequestModel request);
  Future<ForgotPasswordResponseModel> forgotPassword(
    ForgotPasswordRequestModel request,
  );
  Future<VerifyResetOtpResponseModel> verifyResetOtp(
    VerifyResetOtpRequestModel request,
  );
  Future<ResetPasswordResponseModel> resetPassword(
    ResetPasswordRequestModel request,
  );
  Future<LoginResponseModel> refreshToken(RefreshTokenRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? ApiClient.dio;

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await dio.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data as Map<String, dynamic>?;
        final errorMessage = _parseErrorMessage(responseData);
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Parse error message from API response
  /// Handles both validation errors (400) and authentication errors (401)
  String _parseErrorMessage(Map<String, dynamic>? responseData) {
    if (responseData == null) return AppStrings.errorLoginFailed;

    // Handle validation errors (400) - format: {"errors": {"Field": ["Error message"]}}
    if (responseData.containsKey('errors')) {
      final errors = responseData['errors'] as Map<String, dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        final errorMessages = <String>[];
        errors.forEach((field, messages) {
          if (messages is List) {
            errorMessages.addAll(
              messages.map((msg) => msg.toString()),
            );
          } else {
            errorMessages.add(messages.toString());
          }
        });
        return errorMessages.join('\n');
      }
    }

    // Handle authentication errors (401) - format: {"error": "Error message"}
    if (responseData.containsKey('error')) {
      return responseData['error'] as String;
    }

    // Fallback to message or default
    return responseData['message'] as String? ?? AppStrings.errorLoginFailed;
  }

  @override
  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await dio.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );

      return RegisterResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data as Map<String, dynamic>?;
        final errorMessage = _parseErrorMessage(responseData);
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<VerifyEmailResponseModel> verifyEmail(VerifyEmailRequestModel request) async {
    try {
      final response = await dio.post(
        ApiEndpoints.verifyEmail,
        data: request.toJson(),
      );

      return VerifyEmailResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data as Map<String, dynamic>?;
        final errorMessage = _parseErrorMessage(responseData);
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<ForgotPasswordResponseModel> forgotPassword(
    ForgotPasswordRequestModel request,
  ) async {
    try {
      final response = await dio.post(
        ApiEndpoints.forgotPassword,
        data: request.toJson(),
      );

      return ForgotPasswordResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data as Map<String, dynamic>?;
        final errorMessage = _parseErrorMessage(responseData);
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<VerifyResetOtpResponseModel> verifyResetOtp(
    VerifyResetOtpRequestModel request,
  ) async {
    try {
      final response = await dio.post(
        ApiEndpoints.verifyResetOtp,
        data: request.toJson(),
      );

      return VerifyResetOtpResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data as Map<String, dynamic>?;
        final errorMessage = _parseErrorMessage(responseData);
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<ResetPasswordResponseModel> resetPassword(
    ResetPasswordRequestModel request,
  ) async {
    try {
      final response = await dio.post(
        ApiEndpoints.resetPassword,
        data: request.toJson(),
      );

      return ResetPasswordResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data as Map<String, dynamic>?;
        final errorMessage = _parseErrorMessage(responseData);
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<ForgotPasswordResponseModel> resendOtp(
    ForgotPasswordRequestModel request,
  ) async {
    try {
      final response = await dio.post(
        ApiEndpoints.resendOtp,
        data: request.toJson(),
      );

      return ForgotPasswordResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data as Map<String, dynamic>?;
        final errorMessage = _parseErrorMessage(responseData);
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<LoginResponseModel> refreshToken(RefreshTokenRequestModel request) async {
    try {
      // Create a new Dio instance without interceptors to avoid circular calls
      final baseUrl = dio.options.baseUrl;
      final refreshDio = Dio(
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

      final response = await refreshDio.post(
        ApiEndpoints.refreshToken,
        data: request.toJson(),
      );

      return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data as Map<String, dynamic>?;
        final errorMessage = _parseErrorMessage(responseData);
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}

