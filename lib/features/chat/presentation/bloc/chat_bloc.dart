import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/create_conversation_usecase.dart';
import '../../domain/usecases/get_conversation_detail_usecase.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import '../../domain/usecases/mark_messages_read_usecase.dart';
import '../../domain/usecases/request_support_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required GetConversationsUsecase getConversationsUsecase,
    required GetConversationDetailUsecase getConversationDetailUsecase,
    required SendMessageUsecase sendMessageUsecase,
    required CreateConversationUsecase createConversationUsecase,
    required MarkMessagesReadUsecase markMessagesReadUsecase,
    required RequestSupportUsecase requestSupportUsecase,
  })  : _getConversationsUsecase = getConversationsUsecase,
        _getConversationDetailUsecase = getConversationDetailUsecase,
        _sendMessageUsecase = sendMessageUsecase,
        _createConversationUsecase = createConversationUsecase,
        _markMessagesReadUsecase = markMessagesReadUsecase,
        _requestSupportUsecase = requestSupportUsecase,
        super(const ChatState()) {
    on<ChatStarted>(_onStarted);
    on<ChatRefreshRequested>(_onRefresh);
    on<ChatConversationSelected>(_onConversationSelected);
    on<ChatCreateConversationSubmitted>(_onCreateConversation);
    on<ChatSendMessageSubmitted>(_onSendMessage);
    on<ChatRequestSupportSubmitted>(_onRequestSupport);
  }

  final GetConversationsUsecase _getConversationsUsecase;
  final GetConversationDetailUsecase _getConversationDetailUsecase;
  final SendMessageUsecase _sendMessageUsecase;
  final CreateConversationUsecase _createConversationUsecase;
  final MarkMessagesReadUsecase _markMessagesReadUsecase;
  final RequestSupportUsecase _requestSupportUsecase;

  String _formatError(Object e) {
    var message = e.toString();
    message = message.replaceAll('Exception: ', '');

    if (message.contains('request took longer') ||
        message.contains('receiveTimeout') ||
        message.contains('RequestOptions.receiveTimeout')) {
      return 'Không thể gửi tin nhắn: Máy chủ phản hồi chậm. Vui lòng thử lại sau.';
    }

    return message;
  }

  Future<void> _onStarted(
    ChatStarted event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(conversationsStatus: ChatStatus.loading, errorMessage: null));
    try {
      final conversations = await _getConversationsUsecase();
      emit(state.copyWith(
        conversations: conversations,
        conversationsStatus: ChatStatus.success,
      ));

      if (event.autoSelectFirstConversation && conversations.isNotEmpty) {
        add(ChatConversationSelected(conversations.first.id));
      }
    } catch (e) {
      emit(state.copyWith(
        conversationsStatus: ChatStatus.failure,
        errorMessage: _formatError(e),
      ));
    }
  }

  Future<void> _onRefresh(
    ChatRefreshRequested event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final conversations = await _getConversationsUsecase();
      emit(state.copyWith(
        conversations: conversations,
        conversationsStatus: ChatStatus.success,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        conversationsStatus: ChatStatus.failure,
        errorMessage: _formatError(e),
      ));
    }
  }

  Future<void> _onConversationSelected(
    ChatConversationSelected event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(
      conversationDetailStatus: ChatStatus.loading,
      sendStatus: ChatSendStatus.idle,
      supportStatus: ChatSupportStatus.idle,
      isAiTyping: false,
      errorMessage: null,
    ));

    try {
      final conversation = await _getConversationDetailUsecase(event.conversationId);
      await _markMessagesReadUsecase(event.conversationId);

      final updatedList = _upsertConversation(conversation);
      emit(state.copyWith(
        selectedConversation: conversation,
        conversations: updatedList,
        conversationDetailStatus: ChatStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        conversationDetailStatus: ChatStatus.failure,
        errorMessage: _formatError(e),
      ));
    }
  }

  Future<void> _onCreateConversation(
    ChatCreateConversationSubmitted event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(errorMessage: null));
    try {
      final conversation = await _createConversationUsecase(event.name);
      final updated = [conversation, ...state.conversations];
      emit(state.copyWith(
        conversations: updated,
        conversationsStatus: ChatStatus.success,
      ));
      add(ChatConversationSelected(conversation.id));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString(),
        conversationsStatus: ChatStatus.failure,
      ));
    }
  }

  Future<void> _onSendMessage(
    ChatSendMessageSubmitted event,
    Emitter<ChatState> emit,
  ) async {
    final selected = state.selectedConversation;
    if (selected == null) return;
    // Optimistic user message
    final now = DateTime.now();
    final tempUserMessage = ChatMessage(
      id: -now.millisecondsSinceEpoch,
      content: event.content,
      senderType: 'customer',
      senderId: null,
      senderName: null,
      createdAt: now,
      isRead: true,
    );

    final optimisticMessages = List<ChatMessage>.from(selected.messages)
      ..add(tempUserMessage);
    final optimisticConversation =
        selected.copyWith(messages: optimisticMessages);
    final optimisticList = _upsertConversation(optimisticConversation);

    emit(state.copyWith(
      selectedConversation: optimisticConversation,
      conversations: optimisticList,
      sendStatus: ChatSendStatus.sending,
      isAiTyping: true,
      errorMessage: null,
    ));

    try {
      final result = await _sendMessageUsecase(
        conversationId: selected.id,
        content: event.content,
      );
      // Replace optimistic message list with server truth (user + AI responses)
      final newMessages = List<ChatMessage>.from(selected.messages)
        ..addAll(result.messagesToAppend);

      final updatedConversation = selected.copyWith(messages: newMessages);
      final updatedList = _upsertConversation(updatedConversation);

      emit(state.copyWith(
        selectedConversation: updatedConversation,
        conversations: updatedList,
        sendStatus: ChatSendStatus.success,
        isAiTyping: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        sendStatus: ChatSendStatus.failure,
        isAiTyping: false,
        errorMessage: _formatError(e),
      ));
    }
  }

  Future<void> _onRequestSupport(
    ChatRequestSupportSubmitted event,
    Emitter<ChatState> emit,
  ) async {
    final selected = state.selectedConversation;
    if (selected == null) return;

    emit(state.copyWith(
      supportStatus: ChatSupportStatus.submitting,
      errorMessage: null,
    ));

    try {
      final request = await _requestSupportUsecase(
        conversationId: selected.id,
        reason: event.reason,
      );
      emit(state.copyWith(
        supportStatus: ChatSupportStatus.success,
        supportRequest: request,
      ));
    } catch (e) {
      emit(state.copyWith(
        supportStatus: ChatSupportStatus.failure,
        errorMessage: _formatError(e),
      ));
    }
  }

  List<ChatConversation> _upsertConversation(ChatConversation conversation) {
    final existingIndex =
        state.conversations.indexWhere((c) => c.id == conversation.id);
    if (existingIndex == -1) {
      return [conversation, ...state.conversations];
    }
    final updated = List<ChatConversation>.from(state.conversations);
    updated[existingIndex] = conversation;
    return updated;
  }
}

