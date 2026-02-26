import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/ai_structured_data.dart';
import '../../domain/entities/chat_realtime_events.dart';
import '../../domain/usecases/create_conversation_usecase.dart';
import '../../domain/usecases/get_conversation_detail_usecase.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import '../../domain/usecases/mark_messages_read_usecase.dart';
import '../../domain/usecases/request_support_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/entities/support_request.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import '../services/chat_hub_service.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required GetConversationsUsecase getConversationsUsecase,
    required GetConversationDetailUsecase getConversationDetailUsecase,
    required SendMessageUsecase sendMessageUsecase,
    required CreateConversationUsecase createConversationUsecase,
    required MarkMessagesReadUsecase markMessagesReadUsecase,
    required RequestSupportUsecase requestSupportUsecase,
    required ChatHubService chatHubService,
  })  : _getConversationsUsecase = getConversationsUsecase,
        _getConversationDetailUsecase = getConversationDetailUsecase,
        _sendMessageUsecase = sendMessageUsecase,
        _createConversationUsecase = createConversationUsecase,
        _markMessagesReadUsecase = markMessagesReadUsecase,
        _requestSupportUsecase = requestSupportUsecase,
        _chatHubService = chatHubService,
        super(const ChatState()) {
    on<ChatStarted>(_onStarted);
    on<ChatRefreshRequested>(_onRefresh);
    on<ChatConversationSelected>(_onConversationSelected);
    on<ChatCreateConversationSubmitted>(_onCreateConversation);
    on<ChatSendMessageSubmitted>(_onSendMessage);
    on<ChatRequestSupportSubmitted>(_onRequestSupport);
    on<ChatSearchQueryChanged>(_onSearchQueryChanged);
    on<ChatRealtimeMessageReceived>(_onRealtimeMessageReceived);
    on<ChatRealtimeMessagesReadReceived>(_onRealtimeMessagesReadReceived);
    on<ChatRealtimeSupportCreatedReceived>(_onRealtimeSupportCreatedReceived);
    on<ChatRealtimeStaffJoinedReceived>(_onRealtimeStaffJoinedReceived);
    on<ChatRealtimeSupportResolvedReceived>(_onRealtimeSupportResolvedReceived);
    on<ChatRealtimeErrorReceived>(_onRealtimeErrorReceived);
  }

  final GetConversationsUsecase _getConversationsUsecase;
  final GetConversationDetailUsecase _getConversationDetailUsecase;
  final SendMessageUsecase _sendMessageUsecase;
  final CreateConversationUsecase _createConversationUsecase;
  final MarkMessagesReadUsecase _markMessagesReadUsecase;
  final RequestSupportUsecase _requestSupportUsecase;
   final ChatHubService _chatHubService;

  bool _hubStarted = false;
  String? _lastSupportReason;
  StreamSubscription<ChatRealtimeMessage>? _messageSub;
  StreamSubscription<ChatRealtimeMessagesRead>? _messagesReadSub;
  StreamSubscription<ChatRealtimeSupportRequestCreated>? _supportCreatedSub;
  StreamSubscription<ChatRealtimeStaffJoined>? _staffJoinedSub;
  StreamSubscription<ChatRealtimeSupportResolved>? _supportResolvedSub;
  StreamSubscription<String>? _errorSub;

  DateTime _conversationLastActivity(ChatConversation conversation) {
    if (conversation.messages.isEmpty) return conversation.createdAt;
    return conversation.messages
        .map((m) => m.createdAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  List<ChatConversation> _normalizeAndSortConversations(
    List<ChatConversation> input,
  ) {
    final normalized = input
        .map((c) {
          if (c.messages.length <= 1) return c;
          final sortedMessages = List<ChatMessage>.from(c.messages)
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return c.copyWith(messages: sortedMessages);
        })
        .toList();

    normalized.sort(
      (a, b) => _conversationLastActivity(b).compareTo(
        _conversationLastActivity(a),
      ),
    );
    return normalized;
  }

  String _formatError(Object e) {
    var message = e.toString();
    message = message.replaceAll('Exception: ', '');

    // Remove technical error details that are not user-friendly
    if (message.contains('status code 500') ||
        message.contains('validateStatus') ||
        message.contains('RequestOptions')) {
      return 'Không thể gửi tin nhắn: Lỗi máy chủ. Vui lòng thử lại sau.';
    }

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
      final conversations =
          _normalizeAndSortConversations(await _getConversationsUsecase());
      emit(state.copyWith(
        conversations: conversations,
        conversationsStatus: ChatStatus.success,
      ));

      await _ensureHubStarted(emit);

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
      final conversations =
          _normalizeAndSortConversations(await _getConversationsUsecase());
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
    final existing = state.conversations.firstWhere(
      (c) => c.id == event.conversationId,
      orElse: () => ChatConversation(
        id: -1,
        name: '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        messages: const [],
        hasActiveSupport: false,
        customerInfo: null,
      ),
    );
    final hasExisting = existing.id != -1;

    emit(state.copyWith(
      conversationDetailStatus: ChatStatus.loading,
      sendStatus: ChatSendStatus.idle,
      supportStatus: ChatSupportStatus.idle,
      isAiTyping: false,
      errorMessage: null,
      selectedConversation: hasExisting ? existing : state.selectedConversation,
    ));

    try {
      await _ensureHubStarted(emit);
      final conversation =
          await _getConversationDetailUsecase(event.conversationId);

      // Update UI immediately with full conversation detail
      final updatedList = _upsertConversation(conversation);
      emit(state.copyWith(
        selectedConversation: conversation,
        conversations: updatedList,
        conversationDetailStatus: ChatStatus.success,
      ));

      // Best-effort mark read & join; don't block UI or fail the detail view
      try {
        await _markMessagesReadUsecase(event.conversationId);
      } catch (_) {}

      try {
        await _chatHubService.markAsRead(event.conversationId);
      } catch (_) {}

      try {
        await _chatHubService.joinConversation(event.conversationId);
      } catch (_) {}
    } catch (e) {
      emit(state.copyWith(
        conversationDetailStatus: ChatStatus.failure,
        errorMessage: _formatError(e),
        selectedConversation:
            hasExisting ? existing : state.selectedConversation,
      ));
    }
  }

  Future<void> _onCreateConversation(
    ChatCreateConversationSubmitted event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(errorMessage: null));
    try {
      await _ensureHubStarted(emit);
      final conversation = await _createConversationUsecase(event.name);
      final updated = [conversation, ...state.conversations];
      emit(state.copyWith(
        conversations: updated,
        conversationsStatus: ChatStatus.success,
      ));
      await _chatHubService.joinConversation(conversation.id);
      add(ChatConversationSelected(conversation.id));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: _formatError(e),
        conversationsStatus: state.conversations.isEmpty
            ? ChatStatus.failure
            : state.conversationsStatus,
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
      senderType: selected.hasActiveSupport ? 'customer' : 'customer',
      senderId: null,
      senderName: null,
      createdAt: now,
      isRead: true,
      hasJson: false,
      formattedJson: null,
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
        toStaffChannel: selected.hasActiveSupport,
      );
      
      // Use current state to get the latest conversation (may have been updated by Hub)
      final currentConversation = state.selectedConversation ?? selected;
      
      // Remove optimistic messages (negative IDs) and replace with server truth
      final messagesWithoutOptimistic = currentConversation.messages
          .where((m) => m.id >= 0) // Remove optimistic messages (negative IDs)
          .toList();
      
      // Add server messages, avoiding duplicates
      final existingIds = messagesWithoutOptimistic.map((m) => m.id).toSet();
      final newMessages = List<ChatMessage>.from(messagesWithoutOptimistic);
      for (final msg in result.messagesToAppend) {
        if (!existingIds.contains(msg.id)) {
          newMessages.add(msg);
          existingIds.add(msg.id);
        }
      }

      final updatedConversation = currentConversation.copyWith(messages: newMessages);
      final updatedList = _upsertConversation(updatedConversation);

      final updatedStructured =
          Map<int, AiStructuredData>.from(state.aiStructuredByMessageId);
      if (result.aiMessage != null && result.aiStructuredData != null) {
        updatedStructured[result.aiMessage!.id] = result.aiStructuredData!;
      }

      // Only set isAiTyping to false if:
      // 1. Has human support (toStaffChannel = true) - no AI reply expected
      // 2. Or AI message is already in the result (AI replied immediately)
      // Otherwise, keep isAiTyping true until AI message arrives via Hub
      final shouldStopTyping = selected.hasActiveSupport || result.aiMessage != null;

      emit(state.copyWith(
        selectedConversation: updatedConversation,
        conversations: updatedList,
        sendStatus: ChatSendStatus.success,
        isAiTyping: !shouldStopTyping,
        aiStructuredByMessageId: updatedStructured,
      ));
    } catch (e, stackTrace) {
      // Log chi tiết lỗi để debug khi gửi tin nhắn thất bại
      // ignore: avoid_print
      print('[ChatBloc] Send message error: $e');
      // ignore: avoid_print
      print('[ChatBloc] Send message stackTrace: $stackTrace');

      // Remove optimistic message on failure - restore original conversation
      final originalList = _upsertConversation(selected);
      emit(state.copyWith(
        selectedConversation: selected,
        conversations: originalList,
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

    _lastSupportReason = event.reason;

    try {
      await _ensureHubStarted(emit);
      await _chatHubService.requestSupport(selected.id, event.reason);
      _setConversationActiveSupport(selected.id, true, emit);
      emit(state.copyWith(
        supportStatus: ChatSupportStatus.success,
        supportRequest: SupportRequest(
          id: -1,
          conversationId: selected.id,
          reason: event.reason,
          status: 'pending',
          createdAt: DateTime.now(),
        ),
      ));
    } catch (e) {
      try {
        final request = await _requestSupportUsecase(
          conversationId: selected.id,
          reason: event.reason,
        );
        _setConversationActiveSupport(selected.id, true, emit);
        emit(state.copyWith(
          supportStatus: ChatSupportStatus.success,
          supportRequest: request,
        ));
      } catch (err) {
        emit(state.copyWith(
          supportStatus: ChatSupportStatus.failure,
          errorMessage: _formatError(err),
        ));
      }
    }
  }

  List<ChatConversation> _upsertConversation(ChatConversation conversation) {
    final existingIndex =
        state.conversations.indexWhere((c) => c.id == conversation.id);
    if (existingIndex == -1) {
      return _normalizeAndSortConversations([conversation, ...state.conversations]);
    }
    final updated = List<ChatConversation>.from(state.conversations);
    updated[existingIndex] = conversation;
    return _normalizeAndSortConversations(updated);
  }

  void _onSearchQueryChanged(
    ChatSearchQueryChanged event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  Future<void> _ensureHubStarted(Emitter<ChatState> emit) async {
    if (_hubStarted) return;
    try {
      await _chatHubService.start();
      _hubStarted = true;
      _subscribeHubStreams();
    } catch (e) {
      emit(state.copyWith(
        errorMessage: _formatError(e),
      ));
    }
  }

  void _subscribeHubStreams() {
    _messageSub ??= _chatHubService.messages.listen(
      (data) {
        if (isClosed) return;
        add(ChatRealtimeMessageReceived(data));
      },
    );
    _messagesReadSub ??= _chatHubService.messagesRead.listen(
      (data) {
        if (isClosed) return;
        add(ChatRealtimeMessagesReadReceived(data));
      },
    );
    _supportCreatedSub ??= _chatHubService.supportCreated.listen(
      (data) {
        if (isClosed) return;
        add(ChatRealtimeSupportCreatedReceived(data));
      },
    );
    _staffJoinedSub ??= _chatHubService.staffJoined.listen(
      (data) {
        if (isClosed) return;
        add(ChatRealtimeStaffJoinedReceived(data));
      },
    );
    _supportResolvedSub ??= _chatHubService.supportResolved.listen(
      (data) {
        if (isClosed) return;
        add(ChatRealtimeSupportResolvedReceived(data));
      },
    );
    _errorSub ??= _chatHubService.errors.listen(
      (message) {
        if (isClosed) return;
        add(ChatRealtimeErrorReceived(message));
      },
    );
  }

  Future<void> _onRealtimeMessageReceived(
    ChatRealtimeMessageReceived event,
    Emitter<ChatState> emit,
  ) async {
    final index = state.conversations.indexWhere(
      (c) => c.id == event.data.conversationId,
    );
    if (index == -1) return;

    final conversation = state.conversations[index];
    
    // Check if message already exists to avoid duplicates
    final messageExists = conversation.messages
        .any((m) => m.id == event.data.message.id);
    
    if (messageExists) {
      // Message already exists, just update isAiTyping if needed
      if (event.data.message.senderType.toLowerCase() == 'ai') {
        emit(state.copyWith(isAiTyping: false));
      }
      return;
    }

    // Remove optimistic messages (negative IDs) when receiving real message from Hub
    // This prevents duplicate messages when Hub sends the same message that was already added via API
    final messagesWithoutOptimistic = conversation.messages
        .where((m) => m.id >= 0) // Keep only real messages (non-negative IDs)
        .toList();
    
    final messages = List<ChatMessage>.from(messagesWithoutOptimistic)
      ..add(event.data.message);
    final updatedConversation = conversation.copyWith(messages: messages);
    final updatedList = _upsertConversation(updatedConversation);

    // Only set isAiTyping to false when receiving AI message
    // For customer messages, keep the current isAiTyping state
    final isAiMessage = event.data.message.senderType.toLowerCase() == 'ai';
    final shouldStopTyping = isAiMessage;

    emit(state.copyWith(
      conversations: updatedList,
      selectedConversation: state.selectedConversation?.id == updatedConversation.id
          ? updatedConversation
          : state.selectedConversation,
      isAiTyping: shouldStopTyping ? false : state.isAiTyping,
    ));
  }

  Future<void> _onRealtimeMessagesReadReceived(
    ChatRealtimeMessagesReadReceived event,
    Emitter<ChatState> emit,
  ) async {
    final index = state.conversations.indexWhere(
      (c) => c.id == event.data.conversationId,
    );
    if (index == -1) return;

    final conversation = state.conversations[index];
    final updatedMessages = conversation.messages
        .map(
          (m) => ChatMessage(
            id: m.id,
            content: m.content,
            senderType: m.senderType,
            senderId: m.senderId,
            senderName: m.senderName,
            createdAt: m.createdAt,
            isRead: true,
            hasJson: m.hasJson,
            formattedJson: m.formattedJson,
          ),
        )
        .toList();

    final updatedConversation = conversation.copyWith(messages: updatedMessages);
    final updatedList = _upsertConversation(updatedConversation);

    emit(state.copyWith(
      conversations: updatedList,
      selectedConversation: state.selectedConversation?.id == updatedConversation.id
          ? updatedConversation
          : state.selectedConversation,
    ));
  }

  Future<void> _onRealtimeSupportCreatedReceived(
    ChatRealtimeSupportCreatedReceived event,
    Emitter<ChatState> emit,
  ) async {
    _setConversationActiveSupport(event.data.conversationId, true, emit);
    emit(state.copyWith(
      supportStatus: ChatSupportStatus.success,
      supportRequest: SupportRequest(
        id: event.data.requestId,
        conversationId: event.data.conversationId,
        reason: _lastSupportReason ?? '',
        status: 'pending',
        createdAt: event.data.timestamp,
      ),
    ));
  }

  Future<void> _onRealtimeStaffJoinedReceived(
    ChatRealtimeStaffJoinedReceived event,
    Emitter<ChatState> emit,
  ) async {
    final currentRequest = state.supportRequest;
    _setConversationActiveSupport(event.data.conversationId, true, emit);
    emit(state.copyWith(
      supportStatus: ChatSupportStatus.success,
      supportRequest: currentRequest == null
          ? SupportRequest(
              id: event.data.requestId,
              conversationId: event.data.conversationId,
              reason: _lastSupportReason ?? '',
              status: 'assigned',
              createdAt: event.data.timestamp,
              assignedAt: event.data.timestamp,
              staff: event.data.staffName,
            )
          : SupportRequest(
              id: currentRequest.id == -1
                  ? event.data.requestId
                  : currentRequest.id,
              conversationId: currentRequest.conversationId,
              reason: currentRequest.reason,
              status: 'assigned',
              createdAt: currentRequest.createdAt,
              assignedAt: event.data.timestamp,
              staff: event.data.staffName,
              customer: currentRequest.customer,
            ),
    ));
  }

  Future<void> _onRealtimeSupportResolvedReceived(
    ChatRealtimeSupportResolvedReceived event,
    Emitter<ChatState> emit,
  ) async {
    final currentRequest = state.supportRequest;
    _setConversationActiveSupport(event.data.conversationId, false, emit);
    emit(state.copyWith(
      supportStatus: ChatSupportStatus.success,
      supportRequest: currentRequest == null
          ? SupportRequest(
              id: event.data.requestId,
              conversationId: event.data.conversationId,
              reason: _lastSupportReason ?? '',
              status: 'resolved',
              createdAt: event.data.timestamp,
              resolvedAt: event.data.timestamp,
              staff: event.data.staffName,
            )
          : SupportRequest(
              id: currentRequest.id == -1
                  ? event.data.requestId
                  : currentRequest.id,
              conversationId: currentRequest.conversationId,
              reason: currentRequest.reason,
              status: 'resolved',
              createdAt: currentRequest.createdAt,
              assignedAt: currentRequest.assignedAt,
              resolvedAt: event.data.timestamp,
              staff: event.data.staffName,
              customer: currentRequest.customer,
            ),
    ));
  }

  Future<void> _onRealtimeErrorReceived(
    ChatRealtimeErrorReceived event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(errorMessage: event.message));
  }

  void _setConversationActiveSupport(
    int conversationId,
    bool isActive,
    Emitter<ChatState> emit,
  ) {
    final index = state.conversations.indexWhere(
      (conversation) => conversation.id == conversationId,
    );
    if (index == -1) return;

    final updatedList = List<ChatConversation>.from(state.conversations);
    final updatedConversation =
        updatedList[index].copyWith(hasActiveSupport: isActive);
    updatedList[index] = updatedConversation;

    emit(state.copyWith(
      conversations: _normalizeAndSortConversations(updatedList),
      selectedConversation: state.selectedConversation?.id == conversationId
          ? updatedConversation
          : state.selectedConversation,
    ));
  }

  @override
  Future<void> close() async {
    await _messageSub?.cancel();
    await _messagesReadSub?.cancel();
    await _supportCreatedSub?.cancel();
    await _staffJoinedSub?.cancel();
    await _supportResolvedSub?.cancel();
    await _errorSub?.cancel();
    await _chatHubService.stop();
    return super.close();
  }
}

