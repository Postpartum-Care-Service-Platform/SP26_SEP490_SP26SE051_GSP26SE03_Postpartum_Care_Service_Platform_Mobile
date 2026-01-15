import '../entities/chat_conversation.dart';
import '../entities/chat_send_result.dart';
import '../entities/support_request.dart';

abstract class ChatRepository {
  Future<List<ChatConversation>> getConversations();
  Future<ChatConversation> getConversationDetail(int id);
  Future<ChatSendResult> sendMessage({
    required int conversationId,
    required String content,
  });
  Future<ChatConversation> createConversation(String name);
  Future<void> markMessagesRead(int conversationId);
  Future<SupportRequest> requestSupport({
    required int conversationId,
    required String reason,
  });
}

