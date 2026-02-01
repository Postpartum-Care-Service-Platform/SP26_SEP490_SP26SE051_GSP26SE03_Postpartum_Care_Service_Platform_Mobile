import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/feedback_model.dart';
import '../models/feedback_type_model.dart';
import '../models/create_feedback_request_model.dart';

/// Feedback Remote Data Source Interface
abstract class FeedbackRemoteDataSource {
  Future<List<FeedbackTypeModel>> getFeedbackTypes();
  Future<List<FeedbackModel>> getMyFeedbacks();
  Future<FeedbackModel> createFeedback(CreateFeedbackRequestModel request);
}

/// Feedback Remote Data Source Implementation
class FeedbackRemoteDataSourceImpl implements FeedbackRemoteDataSource {
  final Dio dio;

  FeedbackRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? ApiClient.dio;

  @override
  Future<List<FeedbackTypeModel>> getFeedbackTypes() async {
    try {
      final response = await dio.get(ApiEndpoints.feedbackTypes);
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => FeedbackTypeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<FeedbackModel>> getMyFeedbacks() async {
    try {
      final response = await dio.get(ApiEndpoints.myFeedbacks);
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => FeedbackModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<FeedbackModel> createFeedback(CreateFeedbackRequestModel request) async {
    try {
      final formData = request.toFormData();
      final formDataMap = <String, dynamic>{};

      // Add form fields
      for (final entry in formData.entries) {
        formDataMap[entry.key] = entry.value;
      }

      // Add images as multipart files
      if (request.images.isNotEmpty) {
        formDataMap['Images'] = request.images.map((file) async {
          return await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          );
        }).toList();

        // Wait for all MultipartFile futures
        final multipartFiles = await Future.wait(
          request.images.map((file) async {
            return await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            );
          }),
        );

        // Dio expects List<MultipartFile> for multiple files with same key
        formDataMap['Images'] = multipartFiles;
      }

      final response = await dio.post(
        ApiEndpoints.createFeedback,
        data: FormData.fromMap(formDataMap),
      );

      return FeedbackModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      String message = 'Có lỗi xảy ra';

      if (data is Map<String, dynamic>) {
        message = data['error'] as String? ??
            data['message'] as String? ??
            message;
      } else if (data is String) {
        message = data;
      }

      switch (statusCode) {
        case 400:
          return 'Dữ liệu không hợp lệ: $message';
        case 401:
          return 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
        case 403:
          return 'Bạn không có quyền thực hiện thao tác này.';
        case 404:
          return 'Không tìm thấy dữ liệu.';
        case 500:
          return 'Lỗi server: $message';
        default:
          return message;
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Kết nối timeout. Vui lòng thử lại.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
    }

    return 'Có lỗi xảy ra: ${error.message}';
  }
}
