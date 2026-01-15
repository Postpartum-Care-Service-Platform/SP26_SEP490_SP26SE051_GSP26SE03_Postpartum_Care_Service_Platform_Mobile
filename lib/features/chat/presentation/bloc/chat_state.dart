import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/support_request.dart';
import '../../domain/entities/ai_structured_data.dart';

enum ChatStatus { initial, loading, success, failure }

enum ChatSendStatus { idle, sending, success, failure }

enum ChatSupportStatus { idle, submitting, success, failure }

class ChatState extends Equatable {
  final List<ChatConversation> conversations;
  final ChatConversation? selectedConversation;
  final ChatStatus conversationsStatus;
  final ChatStatus conversationDetailStatus;
  final ChatSendStatus sendStatus;
  final ChatSupportStatus supportStatus;
  final String? errorMessage;
  final SupportRequest? supportRequest;
  final bool isAiTyping;
  final Map<int, AiStructuredData> aiStructuredByMessageId;
  final String searchQuery;

  const ChatState({
    this.conversations = const [],
    this.selectedConversation,
    this.conversationsStatus = ChatStatus.initial,
    this.conversationDetailStatus = ChatStatus.initial,
    this.sendStatus = ChatSendStatus.idle,
    this.supportStatus = ChatSupportStatus.idle,
    this.errorMessage,
    this.supportRequest,
    this.isAiTyping = false,
    this.aiStructuredByMessageId = const {},
    this.searchQuery = '',
  });

  ChatState copyWith({
    List<ChatConversation>? conversations,
    ChatConversation? selectedConversation,
    ChatStatus? conversationsStatus,
    ChatStatus? conversationDetailStatus,
    ChatSendStatus? sendStatus,
    ChatSupportStatus? supportStatus,
    String? errorMessage,
    SupportRequest? supportRequest,
    bool? isAiTyping,
    Map<int, AiStructuredData>? aiStructuredByMessageId,
    String? searchQuery,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      selectedConversation: selectedConversation ?? this.selectedConversation,
      conversationsStatus: conversationsStatus ?? this.conversationsStatus,
      conversationDetailStatus:
          conversationDetailStatus ?? this.conversationDetailStatus,
      sendStatus: sendStatus ?? this.sendStatus,
      supportStatus: supportStatus ?? this.supportStatus,
      errorMessage: errorMessage,
      supportRequest: supportRequest ?? this.supportRequest,
      isAiTyping: isAiTyping ?? this.isAiTyping,
      aiStructuredByMessageId:
          aiStructuredByMessageId ?? this.aiStructuredByMessageId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        conversations,
        selectedConversation,
        conversationsStatus,
        conversationDetailStatus,
        sendStatus,
        supportStatus,
        errorMessage,
        supportRequest,
        isAiTyping,
        aiStructuredByMessageId,
        searchQuery,
      ];
}

