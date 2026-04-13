import '../entities/vietqr_bank.dart';

abstract class VietQrRepository {
  Future<List<VietQrBank>> getBanks();
  Future<List<VietQrBank>> getAndroidDeeplinkApps();
  Future<List<VietQrBank>> getIosDeeplinkApps();
}
