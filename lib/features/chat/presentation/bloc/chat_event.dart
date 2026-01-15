import 'package:equatable/equatable.dart';

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

  const ChatSendMessageSubmitted(this.content);

  @override
  List<Object?> get props => [content];
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
