import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/contract_model.dart';

/// Contract Remote Data Source Interface
abstract class ContractRemoteDataSource {
  /// Get contract by booking ID
  Future<ContractModel> getContractByBookingId(int bookingId);

  /// Export contract as PDF
  Future<List<int>> exportContractPdf(int contractId);
}

/// Contract Remote Data Source Implementation
class ContractRemoteDataSourceImpl implements ContractRemoteDataSource {
  final Dio dio;

  ContractRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? ApiClient.dio;

  @override
  Future<ContractModel> getContractByBookingId(int bookingId) async {
    try {
      final response = await dio.get(
        ApiEndpoints.getContractByBookingId(bookingId),
      );

      return ContractModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Failed to get contract: ${e.response?.statusCode}',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<List<int>> exportContractPdf(int contractId) async {
    try {
      final response = await dio.get(
        ApiEndpoints.exportContractPdf(contractId),
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      // Response data is already List<int> when responseType is bytes
      if (response.data is List<int>) {
        return response.data as List<int>;
      } else if (response.data is List) {
        // Fallback: convert List<dynamic> to List<int>
        return (response.data as List).cast<int>();
      } else {
        throw Exception('Unexpected response type');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Failed to export contract PDF: ${e.response?.statusCode}',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
