import '../entities/support_request.dart';
import '../repositories/chat_repository.dart';

class RequestSupportUsecase {
  final ChatRepository repository;

  RequestSupportUsecase(this.repository);

  Future<SupportRequest> call({
    required int conversationId,
    required String reason,
  }) {
    return repository.requestSupport(
      conversationId: conversationId,
      reason: reason,
    );
  }
}

