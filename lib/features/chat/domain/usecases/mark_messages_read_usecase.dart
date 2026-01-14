import '../repositories/chat_repository.dart';

class MarkMessagesReadUsecase {
  final ChatRepository repository;

  MarkMessagesReadUsecase(this.repository);

  Future<void> call(int conversationId) {
    return repository.markMessagesRead(conversationId);
  }
}

