import '../../domain/entities/chat_send_result.dart';
import 'chat_message_model.dart';
import 'ai_structured_data_model.dart';

class ChatSendResultModel extends ChatSendResult {
  const ChatSendResultModel({
    required ChatMessageModel userMessage,
    ChatMessageModel? aiMessage,
    AiStructuredDataModel? aiStructuredData,
  }) : super(
          userMessage: userMessage,
          aiMessage: aiMessage,
          aiStructuredData: aiStructuredData,
        );

  factory ChatSendResultModel.fromJson(Map<String, dynamic> json) {
    final userMessage =
        ChatMessageModel.fromJson(json['userMessage'] as Map<String, dynamic>);
    final aiJson = json['aiMessage'];
    final aiMessage = (aiJson is Map<String, dynamic>)
        ? ChatMessageModel.fromJson(aiJson)
        : null;
    final structuredJson = json['aiStructuredData'];
    final structured = (structuredJson is Map<String, dynamic>)
        ? AiStructuredDataModel.fromJson(structuredJson)
        : null;
    return ChatSendResultModel(
      userMessage: userMessage,
      aiMessage: aiMessage,
      aiStructuredData: structured,
    );
  }
}

