import '../entities/support_request.dart';
import '../repositories/chat_repository.dart';

/// Use case để lấy danh sách yêu cầu hỗ trợ đang chờ (dành cho staff)
class GetSupportRequestsUsecase {
  final ChatRepository repository;

  GetSupportRequestsUsecase(this.repository);

  Future<List<SupportRequest>> call() {
    return repository.getSupportRequests();
  }
}
