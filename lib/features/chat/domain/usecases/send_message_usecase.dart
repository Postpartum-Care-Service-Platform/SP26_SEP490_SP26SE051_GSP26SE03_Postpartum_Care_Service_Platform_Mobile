import '../entities/chat_send_result.dart';
import '../repositories/chat_repository.dart';

class SendMessageUsecase {
  final ChatRepository repository;

  SendMessageUsecase(this.repository);

  Future<ChatSendResult> call({
    required int conversationId,
    required String content,
    bool toStaffChannel = false,
    bool isStaff = false,
  }) {
    return repository.sendMessage(
      conversationId: conversationId,
      content: content,
      toStaffChannel: toStaffChannel,
      isStaff: isStaff,
    );
  }
}

