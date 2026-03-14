import '../entities/chat_conversation.dart';
import '../repositories/chat_repository.dart';

/// Use case để lấy tất cả conversations (dành cho staff)
class GetAllConversationsUsecase {
  final ChatRepository repository;

  GetAllConversationsUsecase(this.repository);

  Future<List<ChatConversation>> call() {
    return repository.getAllConversations();
  }
}
