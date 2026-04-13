import '../../domain/entities/vietqr_bank.dart';
import '../../domain/repositories/vietqr_repository.dart';
import '../datasources/vietqr_remote_datasource.dart';

class VietQrRepositoryImpl implements VietQrRepository {
  final VietQrRemoteDataSource remoteDataSource;

  VietQrRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<VietQrBank>> getBanks() async {
    return await remoteDataSource.getBanks();
  }

  @override
  Future<List<VietQrBank>> getAndroidDeeplinkApps() async {
    return await remoteDataSource.getAndroidDeeplinkApps();
  }

  @override
  Future<List<VietQrBank>> getIosDeeplinkApps() async {
    return await remoteDataSource.getIosDeeplinkApps();
  }
}
