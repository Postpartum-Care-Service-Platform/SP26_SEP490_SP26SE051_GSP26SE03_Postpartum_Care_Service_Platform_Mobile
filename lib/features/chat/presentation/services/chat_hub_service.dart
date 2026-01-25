import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_realtime_events.dart';

/// SignalR client for customer-side realtime chat
class ChatHubService {
  HubConnection? _connection;
  bool _handlersRegistered = false;
  final bool _loggingEnabled = true;
  bool _starting = false;

  final _messageController = StreamController<ChatRealtimeMessage>.broadcast();
  final _messagesReadController =
      StreamController<ChatRealtimeMessagesRead>.broadcast();
  final _supportCreatedController =
      StreamController<ChatRealtimeSupportRequestCreated>.broadcast();
  final _staffJoinedController =
      StreamController<ChatRealtimeStaffJoined>.broadcast();
  final _supportResolvedController =
      StreamController<ChatRealtimeSupportResolved>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Stream<ChatRealtimeMessage> get messages => _messageController.stream;
  Stream<ChatRealtimeMessagesRead> get messagesRead =>
      _messagesReadController.stream;
  Stream<ChatRealtimeSupportRequestCreated> get supportCreated =>
      _supportCreatedController.stream;
  Stream<ChatRealtimeStaffJoined> get staffJoined =>
      _staffJoinedController.stream;
  Stream<ChatRealtimeSupportResolved> get supportResolved =>
      _supportResolvedController.stream;
  Stream<String> get errors => _errorController.stream;

  bool get isConnected => _connection?.state == HubConnectionState.Connected;

  Future<void> start() async {
    if (isConnected) return;
    if (_starting) {
      _log('[Hub] start() skipped because already starting');
      return;
    }
    _starting = true;

    _connection ??= HubConnectionBuilder()
        .withAutomaticReconnect()
        .withUrl(
          'https://10.0.2.2:7267/hubs/chat',
          options: HttpConnectionOptions(
            accessTokenFactory: () async =>
                await SecureStorageService.getAccessToken() ?? '',
            transport: HttpTransportType.WebSockets,
            skipNegotiation: false,
          ),
        )
        .build();

    if (!_handlersRegistered) {
      _registerHandlers();
      _handlersRegistered = true;
    }

    if (_connection?.state == HubConnectionState.Disconnected) {
      _log('[Hub] Starting connection...');
      try {
        await _connection!.start();
        _log('[Hub] Connection started. State=${_connection?.state}');
      } catch (e) {
        _log('[Hub] Connection start failed: $e');
        rethrow;
      } finally {
        _starting = false;
      }
    } else {
      _starting = false;
    }
  }

  Future<void> stop() async {
    _log('[Hub] Stopping connection...');
    await _connection?.stop();
    _log('[Hub] Connection stopped.');
  }

  Future<void> joinConversation(int conversationId) async {
    await _ensureConnected();
    await _connection?.invoke('JoinConversation', args: [conversationId]);
  }

  Future<void> leaveConversation(int conversationId) async {
    await _ensureConnected();
    await _connection?.invoke('LeaveConversation', args: [conversationId]);
  }

  Future<void> sendTyping(int conversationId, bool isTyping) async {
    await _ensureConnected();
    await _connection?.invoke('NotifyTyping', args: [conversationId, isTyping]);
  }

  Future<void> markAsRead(int conversationId) async {
    await _ensureConnected();
    await _connection?.invoke('MarkAsRead', args: [conversationId]);
  }

  Future<void> requestSupport(int conversationId, String reason) async {
    await _ensureConnected();
    await _connection
        ?.invoke('RequestSupport', args: [conversationId, reason]);
  }

  Future<void> _ensureConnected() async {
    if (!isConnected) {
      _log('[Hub] ensureConnected -> not connected, start()');
      await start();
    }
  }

  void _registerHandlers() {
    _log('[Hub] Registering handlers...');

    _connection?.on('ReceiveMessage', (args) {
      _log('[Hub] ReceiveMessage raw=$args');
      final payload = _mapFromArgs(args);
      _log('[Hub] ReceiveMessage mapped=$payload');
      final parsed = _parseMessage(payload);
      _log('[Hub] ReceiveMessage parsed=$parsed');
      if (parsed != null) {
        _messageController.add(parsed);
      }
    });

    _connection?.on('MessagesRead', (args) {
      _log('[Hub] MessagesRead raw=$args');
      final payload = _mapFromArgs(args);
      _log('[Hub] MessagesRead mapped=$payload');
      final conversationId = _intOrNull(payload['conversationid']) ??
          _intOrNull(payload['conversationId']);
      final readBy = payload['readby']?.toString() ?? '';
      final readByName = payload['readbyname']?.toString() ?? '';
      final tsRaw = payload['timestamp']?.toString();
      if (conversationId == null) return;

      final timestamp = DateTime.tryParse(tsRaw ?? '') ?? DateTime.now();
      _messagesReadController.add(
        ChatRealtimeMessagesRead(
          conversationId: conversationId,
          readBy: readBy,
          readByName: readByName,
          timestamp: timestamp,
        ),
      );
    });

    _connection?.on('SupportRequestCreated', (args) {
      _log('[Hub] SupportRequestCreated raw=$args');
      final payload = _mapFromArgs(args);
      _log('[Hub] SupportRequestCreated mapped=$payload');
      final requestId = _intOrNull(payload['requestid']) ??
          _intOrNull(payload['requestId']);
      final conversationId = _intOrNull(payload['conversationid']) ??
          _intOrNull(payload['conversationId']);
      final tsRaw = payload['timestamp']?.toString();
      if (requestId == null || conversationId == null) return;

      _supportCreatedController.add(
        ChatRealtimeSupportRequestCreated(
          requestId: requestId,
          conversationId: conversationId,
          timestamp: DateTime.tryParse(tsRaw ?? '') ?? DateTime.now(),
        ),
      );
    });

    _connection?.on('StaffJoined', (args) {
      _log('[Hub] StaffJoined raw=$args');
      final payload = _mapFromArgs(args);
      _log('[Hub] StaffJoined mapped=$payload');
      final conversationId = _intOrNull(payload['conversationid']) ??
          _intOrNull(payload['conversationId']);
      final requestId = _intOrNull(payload['requestid']) ??
          _intOrNull(payload['requestId']);
      final staffId = payload['staffid']?.toString() ?? '';
      final staffName = payload['staffname']?.toString() ?? '';
      final tsRaw = payload['timestamp']?.toString();
      if (conversationId == null || requestId == null) return;

      _staffJoinedController.add(
        ChatRealtimeStaffJoined(
          conversationId: conversationId,
          staffId: staffId,
          staffName: staffName,
          requestId: requestId,
          timestamp: DateTime.tryParse(tsRaw ?? '') ?? DateTime.now(),
        ),
      );
    });

    _connection?.on('SupportResolved', (args) {
      _log('[Hub] SupportResolved raw=$args');
      final payload = _mapFromArgs(args);
      _log('[Hub] SupportResolved mapped=$payload');
      final requestId = _intOrNull(payload['requestid']) ??
          _intOrNull(payload['requestId']);
      final conversationId = _intOrNull(payload['conversationid']) ??
          _intOrNull(payload['conversationId']);
      final staffId = payload['staffid']?.toString() ?? '';
      final staffName = payload['staffname']?.toString() ?? '';
      final tsRaw = payload['timestamp']?.toString();
      if (requestId == null || conversationId == null) return;

      _supportResolvedController.add(
        ChatRealtimeSupportResolved(
          requestId: requestId,
          conversationId: conversationId,
          staffId: staffId,
          staffName: staffName,
          timestamp: DateTime.tryParse(tsRaw ?? '') ?? DateTime.now(),
        ),
      );
    });

    _connection?.on('Error', (args) {
      _log('[Hub] Error raw=$args');
      final payload = _mapFromArgs(args);
      _log('[Hub] Error mapped=$payload');
      final message = payload['message']?.toString() ?? 'Có lỗi xảy ra';
      _log('[Hub] Error message=$message');
      _errorController.add(message);
    });
  }

  ChatRealtimeMessage? _parseMessage(Map<String, dynamic> payload) {
    final conversationId = _intOrNull(payload['conversationid']) ??
        _intOrNull(payload['conversationId']);
    final id = _intOrNull(payload['id']);
    final content = payload['content']?.toString();
    final senderType =
        (payload['sendertype'] ?? payload['senderType'] ?? '').toString();
    final senderId = payload['senderid']?.toString();
    final senderName = payload['sendername']?.toString();
    final isRead = payload['isread'] == true ||
        payload['isRead'] == true ||
        payload['isread'] == 'true' ||
        payload['isRead'] == 'true';
    final createdAtRaw = payload['createdat']?.toString() ??
        payload['createdAt']?.toString();

    if (conversationId == null || id == null || content == null) return null;

    final createdAt = DateTime.tryParse(createdAtRaw ?? '') ?? DateTime.now();

    final message = ChatMessage(
      id: id,
      content: content,
      senderType: senderType,
      senderId: senderId,
      senderName: senderName,
      createdAt: createdAt,
      isRead: isRead,
      hasJson: payload['hasJson'] == true,
      formattedJson: payload['formattedJson']?.toString(),
    );

    return ChatRealtimeMessage(
      conversationId: conversationId,
      message: message,
    );
  }

  Map<String, dynamic> _mapFromArgs(List<Object?>? args) {
    if (args == null || args.isEmpty) return {};
    final first = args.first;
    if (first is Map) {
      return first.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    return {};
  }

  int? _intOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  void dispose() {
    _messageController.close();
    _messagesReadController.close();
    _supportCreatedController.close();
    _staffJoinedController.close();
    _supportResolvedController.close();
    _errorController.close();
  }

  void _log(String message) {
    if (!_loggingEnabled) return;
    // ignore: avoid_print
    print(message);
  }

}
