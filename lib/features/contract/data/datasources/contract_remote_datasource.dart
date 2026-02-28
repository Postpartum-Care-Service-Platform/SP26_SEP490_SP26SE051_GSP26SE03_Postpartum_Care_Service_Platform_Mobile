import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/contract_model.dart';
import '../models/contract_preview_model.dart';

/// Contract Remote Data Source Interface
abstract class ContractRemoteDataSource {
  /// Get contract by booking ID
  Future<ContractModel> getContractByBookingId(int bookingId);

  /// Export contract as PDF
  Future<List<int>> exportContractPdf(int contractId);

  /// Staff/Admin: Get contract by ID
  Future<ContractModel> getContractById(int id);

  /// Staff/Admin: Create contract automatically from booking
  Future<ContractModel> createContractFromBooking(int bookingId);

  /// Staff/Admin: Send contract for customer to view/sign
  Future<String> sendContract(int id);

  /// Staff/Admin: Preview contract by booking (draft HTML)
  Future<ContractPreviewModel> previewContractByBooking(int bookingId);

  /// Staff/Admin: Get all contracts
  Future<List<ContractModel>> getAllContracts();

  /// Staff/Admin: Get contracts that have no schedule
  Future<List<ContractModel>> getNoScheduleContracts();

  /// Staff/Admin: Upload signed contract (file URL + signed date)
  Future<String> uploadSigned({
    required int id,
    required String fileUrl,
    required DateTime signedDate,
  });

  /// Staff/Admin: Update contract content (dates / prices / customer info)
  Future<ContractModel> updateContent(
    int id, {
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
    DateTime? checkinDate,
    DateTime? checkoutDate,
    double? totalPrice,
    double? discountAmount,
    double? finalAmount,
  });
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

  @override
  Future<ContractModel> getContractById(int id) async {
    try {
      final response = await dio.get(
        ApiEndpoints.getContractById(id),
      );
      return ContractModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Failed to get contract by id: ${e.response?.statusCode}',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<ContractModel> createContractFromBooking(int bookingId) async {
    try {
      final response = await dio.post(
        ApiEndpoints.createContractFromBooking(bookingId),
      );
      return ContractModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Failed to create contract from booking: ${e.response?.statusCode}',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<String> sendContract(int id) async {
    try {
      final response = await dio.put(
        ApiEndpoints.sendContract(id),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ?? 'Đã gửi hợp đồng cho khách hàng';
      }
      return 'Đã gửi hợp đồng cho khách hàng';
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Failed to send contract: ${e.response?.statusCode}',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<List<ContractModel>> getAllContracts() async {
    try {
      final response = await dio.get(ApiEndpoints.getAllContracts);
      final data = response.data as List<dynamic>;
      return data
          .map((e) => ContractModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Failed to get contracts: ${e.response?.statusCode}',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<List<ContractModel>> getNoScheduleContracts() async {
    try {
      final response = await dio.get(ApiEndpoints.getNoScheduleContracts);
      final data = response.data as List<dynamic>;
      return data
          .map((e) => ContractModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Failed to get no-schedule contracts: ${e.response?.statusCode}',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<String> uploadSigned({
    required int id,
    required String fileUrl,
    required DateTime signedDate,
  }) async {
    try {
      final body = {
        'fileUrl': fileUrl,
        'signedDate': signedDate.toIso8601String().split('T')[0],
      };
      final response = await dio.put(
        ApiEndpoints.uploadSignedContract(id),
        data: body,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ?? 'Upload hợp đồng đã ký thành công';
      }
      return 'Upload hợp đồng đã ký thành công';
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Failed to upload signed contract: ${e.response?.statusCode}',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<ContractModel> updateContent(
    int id, {
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
    DateTime? checkinDate,
    DateTime? checkoutDate,
    double? totalPrice,
    double? discountAmount,
    double? finalAmount,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (customerName != null && customerName.trim().isNotEmpty) {
        body['customerName'] = customerName.trim();
      }
      if (customerPhone != null && customerPhone.trim().isNotEmpty) {
        body['customerPhone'] = customerPhone.trim();
      }
      if (customerAddress != null && customerAddress.trim().isNotEmpty) {
        body['customerAddress'] = customerAddress.trim();
      }
      String _d(DateTime d) => d.toIso8601String().split('T')[0];
      if (effectiveFrom != null) body['effectiveFrom'] = _d(effectiveFrom);
      if (effectiveTo != null) body['effectiveTo'] = _d(effectiveTo);
      if (checkinDate != null) body['checkinDate'] = _d(checkinDate);
      if (checkoutDate != null) body['checkoutDate'] = _d(checkoutDate);
      if (totalPrice != null) body['totalPrice'] = totalPrice;
      if (discountAmount != null) body['discountAmount'] = discountAmount;
      if (finalAmount != null) body['finalAmount'] = finalAmount;

      final response = await dio.put(
        ApiEndpoints.updateContractContent(id),
        data: body,
      );
      return ContractModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Failed to update contract content: ${e.response?.statusCode}',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<ContractPreviewModel> previewContractByBooking(int bookingId) async {
    try {
      final response = await dio.get(
        ApiEndpoints.previewContractByBooking(bookingId),
      );
      return ContractPreviewModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Failed to preview contract: ${e.response?.statusCode}',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
