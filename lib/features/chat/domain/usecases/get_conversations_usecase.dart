import '../entities/chat_conversation.dart';
import '../repositories/chat_repository.dart';

class GetConversationsUsecase {
  final ChatRepository repository;

  GetConversationsUsecase(this.repository);

  Future<List<ChatConversation>> call() {
    return repository.getConversations();
  }
}

