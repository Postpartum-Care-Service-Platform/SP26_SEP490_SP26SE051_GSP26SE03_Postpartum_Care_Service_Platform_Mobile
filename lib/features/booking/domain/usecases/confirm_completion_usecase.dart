import '../repositories/booking_repository.dart';

/// Customer confirms checkout completion (2-step verification)
class ConfirmCompletionUsecase {
  final BookingRepository repository;

  ConfirmCompletionUsecase(this.repository);

  Future<String> call(int id) async {
    return await repository.confirmCompletion(id);
  }
}
