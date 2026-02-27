import '../entities/support_request.dart';
import '../repositories/chat_repository.dart';

/// Use case để staff đánh dấu yêu cầu hỗ trợ đã xử lý
class ResolveSupportRequestUsecase {
  final ChatRepository repository;

  ResolveSupportRequestUsecase(this.repository);

  Future<SupportRequest> call(int id) {
    return repository.resolveSupportRequest(id);
  }
}
