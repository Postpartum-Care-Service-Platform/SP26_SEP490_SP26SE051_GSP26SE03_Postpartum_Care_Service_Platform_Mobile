import '../entities/chat_conversation.dart';
import '../entities/chat_send_result.dart';
import '../entities/support_request.dart';

abstract class ChatRepository {
  Future<List<ChatConversation>> getConversations();
  Future<List<ChatConversation>> getAllConversations(); // Staff: Lấy tất cả conversations
  Future<ChatConversation> getConversationDetail(int id);
  Future<ChatSendResult> sendMessage({
    required int conversationId,
    required String content,
    bool toStaffChannel,
  });
  Future<ChatConversation> createConversation(String name);
  Future<void> markMessagesRead(int conversationId);
  Future<SupportRequest> requestSupport({
    required int conversationId,
    required String reason,
  });
  // Staff Support Requests APIs
  Future<List<SupportRequest>> getSupportRequests(); // Lấy yêu cầu hỗ trợ đang chờ
  Future<List<SupportRequest>> getMySupportRequests(); // Lấy yêu cầu đang xử lý
  Future<SupportRequest> acceptSupportRequest(int id); // Nhận yêu cầu hỗ trợ
  Future<SupportRequest> resolveSupportRequest(int id); // Đánh dấu đã xử lý
}

