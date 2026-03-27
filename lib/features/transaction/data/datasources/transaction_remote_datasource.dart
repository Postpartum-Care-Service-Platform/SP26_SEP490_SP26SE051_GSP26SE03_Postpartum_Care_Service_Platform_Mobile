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

  // Fast-fix cache cho danh sách giao dịch toàn hệ thống.
  static List<TransactionWithCustomerModel>? _allTransactionsCache;

  TransactionRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? ApiClient.dio;

  @override
  Future<List<TransactionWithCustomerModel>> getAllTransactions() async {
    Future<Response<dynamic>> requestOnce() {
      return dio.get(
        ApiEndpoints.getAllTransactions,
        options: Options(
          receiveTimeout: const Duration(seconds: 90),
          sendTimeout: const Duration(seconds: 90),
        ),
      );
    }

    try {
      final response = await requestOnce();
      final data = response.data as List<dynamic>;
      final transactions = data
          .map(
            (e) => TransactionWithCustomerModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();

      _allTransactionsCache = transactions;
      return transactions;
    } on DioException catch (e) {
      final isTimeout =
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout;

      if (isTimeout) {
        try {
          final retryResponse = await requestOnce();
          final retryData = retryResponse.data as List<dynamic>;
          final retryTransactions = retryData
              .map(
                (item) => TransactionWithCustomerModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList();

          _allTransactionsCache = retryTransactions;
          return retryTransactions;
        } on DioException {
          if (_allTransactionsCache != null) {
            return _allTransactionsCache!;
          }
          throw Exception('Kết nối tới máy chủ chậm. Vui lòng thử lại sau ít phút.');
        }
      }

      if (_allTransactionsCache != null) {
        return _allTransactionsCache!;
      }

      throw Exception('Không thể tải danh sách giao dịch: ${e.message}');
    }
  }
}

