import '../entities/vietqr_bank.dart';
import '../repositories/vietqr_repository.dart';

class GetVietQrBanks {
  final VietQrRepository repository;

  GetVietQrBanks(this.repository);

  Future<List<VietQrBank>> execute() async {
    return await repository.getBanks();
  }
}
