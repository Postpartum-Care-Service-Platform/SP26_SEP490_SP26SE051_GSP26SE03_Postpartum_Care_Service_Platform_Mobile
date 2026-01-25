import 'package:equatable/equatable.dart';
import 'chat_message.dart';

/// Chat conversation entity
class ChatConversation extends Equatable {
  final int id;
  final String name;
  final DateTime createdAt;
  final List<ChatMessage> messages;
  final Map<String, dynamic>? customerInfo;
  final bool hasActiveSupport;

  const ChatConversation({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.messages,
    this.customerInfo,
    this.hasActiveSupport = false,
  });

  ChatConversation copyWith({
    List<ChatMessage>? messages,
    String? name,
    Map<String, dynamic>? customerInfo,
    bool? hasActiveSupport,
  }) {
    return ChatConversation(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      messages: messages ?? this.messages,
      customerInfo: customerInfo ?? this.customerInfo,
      hasActiveSupport: hasActiveSupport ?? this.hasActiveSupport,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        createdAt,
        messages,
        customerInfo,
        hasActiveSupport,
      ];
}

