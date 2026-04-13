import 'dart:io';
import '../entities/vietqr_bank.dart';
import '../repositories/vietqr_repository.dart';

class GetVietQrDeeplinkApps {
  final VietQrRepository repository;

  GetVietQrDeeplinkApps(this.repository);

  Future<List<VietQrBank>> execute() async {
    if (Platform.isIOS) {
      return await repository.getIosDeeplinkApps();
    } else {
      // Default to Android for Android and others (like web/desktop for testing)
      return await repository.getAndroidDeeplinkApps();
    }
  }
}
