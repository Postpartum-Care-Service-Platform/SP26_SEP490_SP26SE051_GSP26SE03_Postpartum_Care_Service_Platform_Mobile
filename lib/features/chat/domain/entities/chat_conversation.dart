import 'package:equatable/equatable.dart';
import 'chat_message.dart';

/// Chat conversation entity
class ChatConversation extends Equatable {
  final int id;
  final String name;
  final DateTime createdAt;
  final List<ChatMessage> messages;

  const ChatConversation({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.messages,
  });

  ChatConversation copyWith({
    List<ChatMessage>? messages,
    String? name,
  }) {
    return ChatConversation(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [id, name, createdAt, messages];
}

