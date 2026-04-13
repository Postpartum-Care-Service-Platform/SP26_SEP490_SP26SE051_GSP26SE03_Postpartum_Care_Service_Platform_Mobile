import 'package:dio/dio.dart';
import '../models/vietqr_bank_model.dart';

abstract class VietQrRemoteDataSource {
  Future<List<VietQrBankModel>> getBanks();
}

class VietQrRemoteDataSourceImpl implements VietQrRemoteDataSource {
  final Dio dio;

  VietQrRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<VietQrBankModel>> getBanks() async {
    try {
      final response = await dio.get('https://api.vietqr.io/v2/banks');
      final data = response.data;

      if (data is Map<String, dynamic> && data['code'] == '00') {
        return (data['data'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(VietQrBankModel.fromJson)
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch banks from VietQR: $e');
    }
  }
}
