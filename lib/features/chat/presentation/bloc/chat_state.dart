import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/support_request.dart';
import '../../domain/entities/ai_structured_data.dart';

enum ChatStatus { initial, loading, success, failure }

enum ChatSendStatus { idle, sending, success, failure }

enum ChatSupportStatus { idle, submitting, success, failure }

enum ChatSupportRequestActionStatus { idle, processing, success, failure }

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
  // Staff Support Requests
  final List<SupportRequest> supportRequests; // Yêu cầu đang chờ
  final List<SupportRequest> mySupportRequests; // Yêu cầu đang xử lý
  final ChatStatus supportRequestsStatus;
  final ChatStatus mySupportRequestsStatus;
  final ChatSupportRequestActionStatus supportRequestActionStatus;

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
    this.supportRequests = const [],
    this.mySupportRequests = const [],
    this.supportRequestsStatus = ChatStatus.initial,
    this.mySupportRequestsStatus = ChatStatus.initial,
    this.supportRequestActionStatus = ChatSupportRequestActionStatus.idle,
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
    List<SupportRequest>? supportRequests,
    List<SupportRequest>? mySupportRequests,
    ChatStatus? supportRequestsStatus,
    ChatStatus? mySupportRequestsStatus,
    ChatSupportRequestActionStatus? supportRequestActionStatus,
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
      supportRequests: supportRequests ?? this.supportRequests,
      mySupportRequests: mySupportRequests ?? this.mySupportRequests,
      supportRequestsStatus: supportRequestsStatus ?? this.supportRequestsStatus,
      mySupportRequestsStatus: mySupportRequestsStatus ?? this.mySupportRequestsStatus,
      supportRequestActionStatus: supportRequestActionStatus ?? this.supportRequestActionStatus,
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
        supportRequests,
        mySupportRequests,
        supportRequestsStatus,
        mySupportRequestsStatus,
        supportRequestActionStatus,
      ];
}

