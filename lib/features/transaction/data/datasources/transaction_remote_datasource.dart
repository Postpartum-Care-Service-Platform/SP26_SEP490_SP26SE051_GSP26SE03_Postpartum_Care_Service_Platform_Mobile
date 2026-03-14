import 'package:dio/dio.dart';

import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/transaction_with_customer_model.dart';

abstract class TransactionRemoteDataSource {
  /// Staff/Admin: Lấy toàn bộ giao dịch trong hệ thống
  Future<List<TransactionWithCustomerModel>> getAllTransactions();
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final Dio dio;

  TransactionRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? ApiClient.dio;

  @override
  Future<List<TransactionWithCustomerModel>> getAllTransactions() async {
    final response = await dio.get(ApiEndpoints.getAllTransactions);
    final data = response.data as List<dynamic>;
    return data
        .map(
          (e) => TransactionWithCustomerModel.fromJson(
            e as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}

