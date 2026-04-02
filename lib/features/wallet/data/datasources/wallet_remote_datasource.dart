import 'package:dio/dio.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/wallet_model.dart';
import '../models/wallet_transaction_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> getMyWallet();
  Future<List<WalletTransactionModel>> getMyWalletTransactions();
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final Dio dio;

  WalletRemoteDataSourceImpl({required this.dio});

  @override
  Future<WalletModel> getMyWallet() async {
    try {
      final response = await dio.get(ApiEndpoints.myWallet);
      return WalletModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Return an empty wallet if backend hasn't created one yet
        return const WalletModel(balance: 0.0);
      }
      rethrow;
    }
  }

  @override
  Future<List<WalletTransactionModel>> getMyWalletTransactions() async {
    try {
      final response = await dio.get(ApiEndpoints.myWalletTransactions);
      if (response.data is List) {
         return (response.data as List).map((e) => WalletTransactionModel.fromJson(e)).toList();
      } else if (response.data != null && response.data['items'] != null) {
         return (response.data['items'] as List).map((e) => WalletTransactionModel.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    }
  }
}
