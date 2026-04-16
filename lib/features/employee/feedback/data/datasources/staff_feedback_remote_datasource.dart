import 'package:dio/dio.dart';
import '../models/staff_feedback_model.dart';
import '../../../../../core/apis/api_client.dart';
import '../../../../../core/apis/api_endpoints.dart';

abstract class StaffFeedbackRemoteDataSource {
  Future<List<StaffFeedbackModel>> getMyFeedbacksForStaff();
}

class StaffFeedbackRemoteDataSourceImpl implements StaffFeedbackRemoteDataSource {
  final Dio dio;

  StaffFeedbackRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<StaffFeedbackModel>> getMyFeedbacksForStaff() async {
    try {
      final response = await dio.get(ApiEndpoints.myFeedbacksForStaff);
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => StaffFeedbackModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load feedbacks for staff');
      }
    } catch (e) {
      throw Exception('Failed to load feedbacks for staff: $e');
    }
  }
}
