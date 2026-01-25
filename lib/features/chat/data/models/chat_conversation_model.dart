import '../../domain/entities/chat_conversation.dart';
import 'chat_message_model.dart';

class ChatConversationModel extends ChatConversation {
  const ChatConversationModel({
    required super.id,
    required super.name,
    required super.createdAt,
    required super.messages,
    super.customerInfo,
    super.hasActiveSupport,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    // Backend có thể trả:
    // - messages: [ ... ]
    // - messages: { items: [ ... ], total: X }
    // - conversationMessages: [ ... ]
    Iterable<dynamic> _extractMessages(dynamic data) {
      if (data is List) return data;
      if (data is Map<String, dynamic>) {
        if (data['items'] is List) return data['items'] as List;
        if (data['data'] is List) return data['data'] as List;
      }
      return const [];
    }

    final rawMessages = _extractMessages(
      json['messages'] ?? json['conversationMessages'],
    );

    final messages = rawMessages
        .map((m) => ChatMessageModel.fromJson(m as Map<String, dynamic>))
        .toList();

    return ChatConversationModel(
      id: json['id'] as int,
      name: (json['name'] ?? '').toString(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      messages: messages,
      customerInfo: json['customerInfo'] as Map<String, dynamic>?,
      hasActiveSupport: json['hasActiveSupport'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'messages': messages,
      'customerInfo': customerInfo,
      'hasActiveSupport': hasActiveSupport,
    };
  }
}

