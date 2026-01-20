import 'chat_message.dart';

/// Realtime message pushed from SignalR
class ChatRealtimeMessage {
  final int conversationId;
  final ChatMessage message;

  ChatRealtimeMessage({
    required this.conversationId,
    required this.message,
  });
}

/// Realtime read receipt
class ChatRealtimeMessagesRead {
  final int conversationId;
  final String readBy;
  final String readByName;
  final DateTime timestamp;

  ChatRealtimeMessagesRead({
    required this.conversationId,
    required this.readBy,
    required this.readByName,
    required this.timestamp,
  });
}

/// Support request created (customer side)
class ChatRealtimeSupportRequestCreated {
  final int requestId;
  final int conversationId;
  final DateTime timestamp;

  ChatRealtimeSupportRequestCreated({
    required this.requestId,
    required this.conversationId,
    required this.timestamp,
  });
}

/// Staff joined a conversation to support
class ChatRealtimeStaffJoined {
  final int conversationId;
  final String staffId;
  final String staffName;
  final int requestId;
  final DateTime timestamp;

  ChatRealtimeStaffJoined({
    required this.conversationId,
    required this.staffId,
    required this.staffName,
    required this.requestId,
    required this.timestamp,
  });
}

/// Support request resolved
class ChatRealtimeSupportResolved {
  final int requestId;
  final int conversationId;
  final String staffId;
  final String staffName;
  final DateTime timestamp;

  ChatRealtimeSupportResolved({
    required this.requestId,
    required this.conversationId,
    required this.staffId,
    required this.staffName,
    required this.timestamp,
  });
}
