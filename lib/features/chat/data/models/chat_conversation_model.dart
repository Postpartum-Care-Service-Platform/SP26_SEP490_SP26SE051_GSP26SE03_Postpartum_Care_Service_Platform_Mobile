import '../../domain/entities/chat_conversation.dart';
import 'chat_message_model.dart';

class ChatConversationModel extends ChatConversation {
  const ChatConversationModel({
    required super.id,
    required super.name,
    required super.createdAt,
    required super.messages,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    final messagesJson = json['messages'];
    final messages = messagesJson is List
        ? messagesJson
            .map((m) => ChatMessageModel.fromJson(m as Map<String, dynamic>))
            .toList()
        : <ChatMessageModel>[];

    return ChatConversationModel(
      id: json['id'] as int,
      name: (json['name'] ?? '').toString(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      messages: messages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'messages': messages,
    };
  }
}

