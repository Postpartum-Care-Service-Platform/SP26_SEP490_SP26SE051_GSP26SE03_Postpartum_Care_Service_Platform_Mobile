import '../../domain/entities/chat_send_result.dart';
import 'chat_message_model.dart';

class ChatSendResultModel extends ChatSendResult {
  const ChatSendResultModel({
    required ChatMessageModel userMessage,
    ChatMessageModel? aiMessage,
  }) : super(userMessage: userMessage, aiMessage: aiMessage);

  factory ChatSendResultModel.fromJson(Map<String, dynamic> json) {
    final userMessage =
        ChatMessageModel.fromJson(json['userMessage'] as Map<String, dynamic>);
    final aiJson = json['aiMessage'];
    final aiMessage = (aiJson is Map<String, dynamic>)
        ? ChatMessageModel.fromJson(aiJson)
        : null;
    return ChatSendResultModel(
      userMessage: userMessage,
      aiMessage: aiMessage,
    );
  }
}

