import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/refund_request_model.dart';

/// Interface for refund request remote data source
abstract class RefundRequestRemoteDataSource {
  Future<List<RefundRequestModel>> createRefundRequest({
    required int bookingId,
    required String bankName,
    required String accountNumber,
    required String accountHolder,
    required String reason,
  });

  Future<List<RefundRequestModel>> createHomeStaffWithdrawRequest({
    required int requestedAmount,
    required String bankName,
    required String accountNumber,
    required String accountHolder,
    required String reason,
  });

  Future<List<RefundRequestModel>> getMyRefundRequests();
}

/// Implementation of refund request remote data source
class RefundRequestRemoteDataSourceImpl
    implements RefundRequestRemoteDataSource {
  final Dio dio;

  RefundRequestRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? ApiClient.dio;

  @override
  Future<List<RefundRequestModel>> createRefundRequest({
    required int bookingId,
    required String bankName,
    required String accountNumber,
    required String accountHolder,
    required String reason,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.createRefundRequest,
        data: {
          'bookingId': bookingId,
          'bankName': bankName,
          'accountNumber': accountNumber,
          'accountHolder': accountHolder,
          'reason': reason,
        },
      );

      final data = response.data;

      if (data is List) {
        return data
            .map((e) =>
                RefundRequestModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (data is Map<String, dynamic>) {
        return [RefundRequestModel.fromJson(data)];
      }

      return [];
    } on DioException catch (e) {
      final errorData = e.response?.data;
      String message = 'Không thể tạo yêu cầu hoàn tiền';
      
      if (errorData is Map<String, dynamic>) {
        final error = errorData['error'] ?? errorData['message'] ?? errorData['title'];
        if (error == 'A refund request for this booking already exists') {
          message = 'Đơn hoàn tiền cho booking này đã tồn tại và đang được chờ xử lý.';
        } else if (error != null) {
          message = error.toString();
        }
      }
      throw Exception(message);
    }
  }

  @override
  Future<List<RefundRequestModel>> createHomeStaffWithdrawRequest({
    required int requestedAmount,
    required String bankName,
    required String accountNumber,
    required String accountHolder,
    required String reason,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.createRefundRequestByHomeStaff,
        data: {
          'requestedAmount': requestedAmount,
          'bankName': bankName,
          'accountNumber': accountNumber,
          'accountHolder': accountHolder,
          'reason': reason,
        },
      );

      final data = response.data;

      if (data is List) {
        return data
            .map((e) => RefundRequestModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (data is Map<String, dynamic>) {
        return [RefundRequestModel.fromJson(data)];
      }

      return [];
    } on DioException catch (e) {
      final errorData = e.response?.data;
      String message = 'Không thể tạo yêu cầu rút tiền';

      if (errorData is Map<String, dynamic>) {
        final error =
            errorData['error'] ?? errorData['message'] ?? errorData['title'];
        if (error != null) {
          message = error.toString();
        }
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Không thể tạo yêu cầu rút tiền: $e');
    }
  }

  @override
  Future<List<RefundRequestModel>> getMyRefundRequests() async {
    try {
      final response = await dio.get(ApiEndpoints.myRefundRequests);

      final data = response.data;

      if (data is List) {
        return data
            .map((e) =>
                RefundRequestModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['title'] ??
          'Không thể tải danh sách yêu cầu hoàn tiền';
      throw Exception(message);
    } catch (e) {
      throw Exception('Không thể tải danh sách yêu cầu hoàn tiền: $e');
    }
  }
}
