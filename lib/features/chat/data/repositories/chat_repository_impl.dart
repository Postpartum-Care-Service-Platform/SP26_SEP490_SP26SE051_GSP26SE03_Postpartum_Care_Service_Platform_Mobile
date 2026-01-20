import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_send_result.dart';
import '../../domain/entities/support_request.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ChatConversation> createConversation(String name) {
    return remoteDataSource.createConversation(name);
  }

  @override
  Future<ChatConversation> getConversationDetail(int id) {
    return remoteDataSource.getConversationDetail(id);
  }

  @override
  Future<List<ChatConversation>> getConversations() {
    return remoteDataSource.getConversations();
  }

  @override
  Future<void> markMessagesRead(int conversationId) {
    return remoteDataSource.markMessagesRead(conversationId);
  }

  @override
  Future<SupportRequest> requestSupport({
    required int conversationId,
    required String reason,
  }) {
    return remoteDataSource.requestSupport(
      conversationId: conversationId,
      reason: reason,
    );
  }

  @override
  Future<ChatSendResult> sendMessage({
    required int conversationId,
    required String content,
    bool toStaffChannel = false,
  }) {
    return remoteDataSource.sendMessage(
      conversationId: conversationId,
      content: content,
      toStaffChannel: toStaffChannel,
    );
  }
}

