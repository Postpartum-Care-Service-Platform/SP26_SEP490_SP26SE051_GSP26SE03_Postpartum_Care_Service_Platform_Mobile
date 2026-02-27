import '../entities/support_request.dart';
import '../repositories/chat_repository.dart';

/// Use case để staff nhận yêu cầu hỗ trợ
class AcceptSupportRequestUsecase {
  final ChatRepository repository;

  AcceptSupportRequestUsecase(this.repository);

  Future<SupportRequest> call(int id) {
    return repository.acceptSupportRequest(id);
  }
}
