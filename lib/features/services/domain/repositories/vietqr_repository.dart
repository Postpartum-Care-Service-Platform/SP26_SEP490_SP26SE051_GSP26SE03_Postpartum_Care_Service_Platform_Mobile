import '../entities/vietqr_bank.dart';

abstract class VietQrRepository {
  Future<List<VietQrBank>> getBanks();
}
