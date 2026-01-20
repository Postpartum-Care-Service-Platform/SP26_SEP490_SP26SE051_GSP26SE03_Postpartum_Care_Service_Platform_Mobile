import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/chat_conversation_model.dart';
import '../models/chat_send_result_model.dart';
import '../models/support_request_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatConversationModel>> getConversations();
  Future<ChatConversationModel> getConversationDetail(int id);
  Future<ChatSendResultModel> sendMessage({
    required int conversationId,
    required String content,
    bool toStaffChannel,
  });
  Future<ChatConversationModel> createConversation(String name);
  Future<void> markMessagesRead(int conversationId);
  Future<SupportRequestModel> requestSupport({
    required int conversationId,
    required String reason,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  @override
  Future<List<ChatConversationModel>> getConversations() async {
    try {
      final response = await _dio.get(ApiEndpoints.chatConversations);
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => ChatConversationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Phản hồi danh sách cuộc trò chuyện không hợp lệ');
    } on DioException catch (e) {
      throw Exception('Không thể tải cuộc trò chuyện: ${e.message}');
    }
  }

  @override
  Future<ChatConversationModel> getConversationDetail(int id) async {
    try {
      final response = await _dio.get(ApiEndpoints.chatConversationById(id));
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ChatConversationModel.fromJson(data);
      }
      throw Exception('Phản hồi cuộc trò chuyện không hợp lệ');
    } on DioException catch (e) {
      throw Exception('Không thể tải cuộc trò chuyện: ${e.message}');
    }
  }

  @override
  Future<ChatSendResultModel> sendMessage({
    required int conversationId,
    required String content,
    bool toStaffChannel = false,
  }) async {
    try {
      final endpoint = toStaffChannel
          ? ApiEndpoints.chatConversationStaffMessage(conversationId)
          : ApiEndpoints.chatConversationMessages(conversationId);

      final response = await _dio.post(
        endpoint,
        data: {'content': content},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ChatSendResultModel.fromJson(data);
      }
      throw Exception('Phản hồi gửi tin không hợp lệ');
    } on DioException catch (e) {
      throw Exception('Không thể gửi tin nhắn: ${e.message}');
    }
  }

  @override
  Future<ChatConversationModel> createConversation(String name) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.chatConversations,
        data: {'name': name},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ChatConversationModel.fromJson(data);
      }
      throw Exception('Phản hồi tạo cuộc trò chuyện không hợp lệ');
    } on DioException catch (e) {
      throw Exception('Không thể tạo cuộc trò chuyện: ${e.message}');
    }
  }

  @override
  Future<void> markMessagesRead(int conversationId) async {
    try {
      await _dio.put(ApiEndpoints.chatConversationMarkRead(conversationId));
    } on DioException catch (e) {
      throw Exception('Không thể cập nhật trạng thái đọc: ${e.message}');
    }
  }

  @override
  Future<SupportRequestModel> requestSupport({
    required int conversationId,
    required String reason,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.chatConversationRequestSupport(conversationId),
        data: {'reason': reason},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return SupportRequestModel.fromJson(data);
      }
      throw Exception('Phản hồi yêu cầu hỗ trợ không hợp lệ');
    } on DioException catch (e) {
      throw Exception('Không thể gửi yêu cầu hỗ trợ: ${e.message}');
    }
  }
}

