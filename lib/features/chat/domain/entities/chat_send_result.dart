import 'package:equatable/equatable.dart';
import 'chat_message.dart';

/// Result returned after sending a message (user + optional AI reply)
class ChatSendResult extends Equatable {
  final ChatMessage userMessage;
  final ChatMessage? aiMessage;

  const ChatSendResult({
    required this.userMessage,
    this.aiMessage,
  });

  List<ChatMessage> get messagesToAppend =>
      [userMessage, if (aiMessage != null) aiMessage!];

  @override
  List<Object?> get props => [userMessage, aiMessage];
}

