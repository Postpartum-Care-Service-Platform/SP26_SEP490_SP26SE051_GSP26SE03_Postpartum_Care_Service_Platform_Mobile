import '../entities/chat_conversation.dart';
import '../repositories/chat_repository.dart';

class GetConversationDetailUsecase {
  final ChatRepository repository;

  GetConversationDetailUsecase(this.repository);

  Future<ChatConversation> call(int id) {
    return repository.getConversationDetail(id);
  }
}

