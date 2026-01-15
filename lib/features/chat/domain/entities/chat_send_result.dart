import 'package:equatable/equatable.dart';
import 'chat_message.dart';
import 'ai_structured_data.dart';

/// Result returned after sending a message (user + optional AI reply)
class ChatSendResult extends Equatable {
  final ChatMessage userMessage;
  final ChatMessage? aiMessage;
  final AiStructuredData? aiStructuredData;

  const ChatSendResult({
    required this.userMessage,
    this.aiMessage,
    this.aiStructuredData,
  });

  List<ChatMessage> get messagesToAppend =>
      [userMessage, if (aiMessage != null) aiMessage!];

  @override
  List<Object?> get props => [userMessage, aiMessage, aiStructuredData];
}

