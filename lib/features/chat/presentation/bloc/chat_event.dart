import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_realtime_events.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatStarted extends ChatEvent {
  final bool autoSelectFirstConversation;

  const ChatStarted({this.autoSelectFirstConversation = true});

  @override
  List<Object?> get props => [autoSelectFirstConversation];
}

class ChatRefreshRequested extends ChatEvent {
  const ChatRefreshRequested();
}

class ChatConversationSelected extends ChatEvent {
  final int conversationId;

  const ChatConversationSelected(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class ChatCreateConversationSubmitted extends ChatEvent {
  final String name;

  const ChatCreateConversationSubmitted(this.name);

  @override
  List<Object?> get props => [name];
}

class ChatSendMessageSubmitted extends ChatEvent {
  final String content;
  final bool isStaff; // true nếu là staff gửi tin nhắn

  const ChatSendMessageSubmitted(this.content, {this.isStaff = false});

  @override
  List<Object?> get props => [content, isStaff];
}

class ChatRequestSupportSubmitted extends ChatEvent {
  final String reason;

  const ChatRequestSupportSubmitted(this.reason);

  @override
  List<Object?> get props => [reason];
}

class ChatSearchQueryChanged extends ChatEvent {
  final String query;

  const ChatSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ChatRealtimeMessageReceived extends ChatEvent {
  final ChatRealtimeMessage data;

  const ChatRealtimeMessageReceived(this.data);

  @override
  List<Object?> get props => [data];
}

class ChatRealtimeMessagesReadReceived extends ChatEvent {
  final ChatRealtimeMessagesRead data;

  const ChatRealtimeMessagesReadReceived(this.data);

  @override
  List<Object?> get props => [data];
}

class ChatRealtimeSupportCreatedReceived extends ChatEvent {
  final ChatRealtimeSupportRequestCreated data;

  const ChatRealtimeSupportCreatedReceived(this.data);

  @override
  List<Object?> get props => [data];
}

class ChatRealtimeStaffJoinedReceived extends ChatEvent {
  final ChatRealtimeStaffJoined data;

  const ChatRealtimeStaffJoinedReceived(this.data);

  @override
  List<Object?> get props => [data];
}

class ChatRealtimeSupportResolvedReceived extends ChatEvent {
  final ChatRealtimeSupportResolved data;

  const ChatRealtimeSupportResolvedReceived(this.data);

  @override
  List<Object?> get props => [data];
}

class ChatRealtimeErrorReceived extends ChatEvent {
  final String message;

  const ChatRealtimeErrorReceived(this.message);

  @override
  List<Object?> get props => [message];
}

// Staff Chat Events
class ChatLoadAllConversationsRequested extends ChatEvent {
  const ChatLoadAllConversationsRequested();
}

class ChatLoadSupportRequestsRequested extends ChatEvent {
  const ChatLoadSupportRequestsRequested();
}

class ChatLoadMySupportRequestsRequested extends ChatEvent {
  const ChatLoadMySupportRequestsRequested();
}

class ChatAcceptSupportRequestSubmitted extends ChatEvent {
  final int supportRequestId;

  const ChatAcceptSupportRequestSubmitted(this.supportRequestId);

  @override
  List<Object?> get props => [supportRequestId];
}

class ChatResolveSupportRequestSubmitted extends ChatEvent {
  final int supportRequestId;

  const ChatResolveSupportRequestSubmitted(this.supportRequestId);

  @override
  List<Object?> get props => [supportRequestId];
}