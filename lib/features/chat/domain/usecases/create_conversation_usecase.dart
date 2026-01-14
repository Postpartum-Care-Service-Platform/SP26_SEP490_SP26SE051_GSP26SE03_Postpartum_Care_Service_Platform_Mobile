import '../entities/chat_conversation.dart';
import '../repositories/chat_repository.dart';

class CreateConversationUsecase {
  final ChatRepository repository;

  CreateConversationUsecase(this.repository);

  Future<ChatConversation> call(String name) {
    return repository.createConversation(name);
  }
}

