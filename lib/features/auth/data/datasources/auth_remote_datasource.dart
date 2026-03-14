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
import '../models/current_account_model.dart';
import '../models/google_sign_in_request_model.dart';
import '../models/change_password_request_model.dart';
import '../models/change_password_response_model.dart';
import '../models/create_customer_request_model.dart';
import '../models/create_customer_response_model.dart';

/// Remote data source for authentication
abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<RegisterResponseModel> register(RegisterRequestModel request);
  Future<CreateCustomerResponseModel> createCustomer(
    CreateCustomerRequestModel request,
  );
  Future<VerifyEmailResponseModel> verifyEmail(VerifyEmailRequestModel request);
  Future<ForgotPasswordResponseModel> resendOtp(
    ForgotPasswordRequestModel request,
  );
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
  Future<LoginResponseModel> googleSignIn(GoogleSignInRequestModel request);
  Future<CurrentAccountModel> getCurrentAccount();
  Future<CurrentAccountModel> getAccountById(String id);
  Future<ChangePasswordResponseModel> changePassword(
    ChangePasswordRequestModel request,
  );
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
  /// Also handles String responses (e.g., 404 errors)
  String _parseErrorMessage(dynamic responseData) {
    if (responseData == null) return AppStrings.errorLoginFailed;

    // Handle String response (e.g., 404 Not Found)
    if (responseData is String) {
      return responseData;
    }

    // Handle Map response
    if (responseData is Map<String, dynamic>) {
      final responseMap = responseData;

      // Handle validation errors (400) - format: {"errors": {"Field": ["Error message"]}}
      if (responseMap.containsKey('errors')) {
        final errors = responseMap['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          final errorMessages = <String>[];
          errors.forEach((field, messages) {
            if (messages is List) {
              errorMessages.addAll(messages.map((msg) => msg.toString()));
            } else {
              errorMessages.add(messages.toString());
            }
          });
          return errorMessages.join('\n');
        }
      }

      // Handle authentication errors (401) - format: {"error": "Error message"}
      if (responseMap.containsKey('error')) {
        return responseMap['error'] as String;
      }

      // Fallback to message or default
      return responseMap['message'] as String? ?? AppStrings.errorLoginFailed;
    }

    // Fallback for other types
    return responseData.toString();
  }

  @override
  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await dio.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );

      return RegisterResponseModel.fromJson(
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
  Future<CreateCustomerResponseModel> createCustomer(
    CreateCustomerRequestModel request,
  ) async {
    try {
      final response = await dio.post(
        ApiEndpoints.createCustomer,
        data: request.toJson(),
      );

      return CreateCustomerResponseModel.fromJson(
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
  Future<VerifyEmailResponseModel> verifyEmail(
    VerifyEmailRequestModel request,
  ) async {
    try {
      final response = await dio.post(
        ApiEndpoints.verifyEmail,
        data: request.toJson(),
      );

      return VerifyEmailResponseModel.fromJson(
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
  Future<LoginResponseModel> refreshToken(
    RefreshTokenRequestModel request,
  ) async {
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

  @override
  Future<LoginResponseModel> googleSignIn(
    GoogleSignInRequestModel request,
  ) async {
    try {
      final response = await dio.post(
        ApiEndpoints.googleSignIn,
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

  @override
  Future<CurrentAccountModel> getCurrentAccount() async {
    try {
      final response = await dio.get(ApiEndpoints.getCurrentAccount);

      return CurrentAccountModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
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
  Future<CurrentAccountModel> getAccountById(String id) async {
    try {
      final response = await dio.get(ApiEndpoints.getAccountById(id));

      return CurrentAccountModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final responseData = e.response?.data;
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
  Future<ChangePasswordResponseModel> changePassword(
    ChangePasswordRequestModel request,
  ) async {
    try {
      final response = await dio.post(
        ApiEndpoints.changePassword,
        data: request.toJson(),
      );

      return ChangePasswordResponseModel.fromJson(
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
}
