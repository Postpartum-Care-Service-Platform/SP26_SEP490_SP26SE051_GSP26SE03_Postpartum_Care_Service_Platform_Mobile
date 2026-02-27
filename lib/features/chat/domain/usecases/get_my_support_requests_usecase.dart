import '../entities/support_request.dart';
import '../repositories/chat_repository.dart';

/// Use case để lấy danh sách yêu cầu hỗ trợ staff đang xử lý
class GetMySupportRequestsUsecase {
  final ChatRepository repository;

  GetMySupportRequestsUsecase(this.repository);

  Future<List<SupportRequest>> call() {
    return repository.getMySupportRequests();
  }
}
