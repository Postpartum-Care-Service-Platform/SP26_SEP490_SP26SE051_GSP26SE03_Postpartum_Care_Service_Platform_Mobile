import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/config/app_config.dart';
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
      _log('[Hub] start() skipped: already starting');
      return;
    }
    _starting = true;

    // Clean URL: Remove /api if present and ensure it leads to /hubs/chat
    String cleanBaseUrl = AppConfig.baseUrl;
    if (cleanBaseUrl.endsWith('/api')) {
      cleanBaseUrl = cleanBaseUrl.substring(0, cleanBaseUrl.length - 4);
    }
    if (cleanBaseUrl.endsWith('/')) {
      cleanBaseUrl = cleanBaseUrl.substring(0, cleanBaseUrl.length - 1);
    }
    final hubUrl = '$cleanBaseUrl/hubs/chat';

    _log('[Hub] targetUrl: $hubUrl');

    _connection ??= HubConnectionBuilder()
        .withAutomaticReconnect()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async {
              final token = await SecureStorageService.getAccessToken() ?? '';
              _log('[Hub] Token requested. Length: ${token.length}');
              return token;
            },
            transport: HttpTransportType.WebSockets, // Cố gắng ép dùng WebSockets
            skipNegotiation: false,
            logMessageContent: true, // Log cả nội dung tin nhắn thô
          ),
        )
        .build();

    _connection?.onclose(({error}) => _log('[Hub] Connection closed. Error: $error'));
    _connection?.onreconnecting(({error}) => _log('[Hub] Connection reconnecting. Error: $error'));
    _connection?.onreconnected(({connectionId}) => _log('[Hub] Connection reconnected. ID: $connectionId'));

    if (!_handlersRegistered) {
      _registerHandlers();
      _handlersRegistered = true;
    }

    if (_connection?.state == HubConnectionState.Disconnected) {
      _log('[Hub] Initiating connection.start()...');
      try {
        await _connection!.start();
        _log('[Hub] connection.start() success. ID: ${_connection?.connectionId} State=${_connection?.state}');
      } catch (e) {
        _log('[Hub] connection.start() EXCEPTION: $e');
        rethrow;
      } finally {
        _starting = false;
      }
    } else {
      _log('[Hub] Current state is ${_connection?.state}, ID: ${_connection?.connectionId}');
      _starting = false;
    }
  }

  Future<void> stop() async {
    _log('[Hub] stop() requested');
    await _connection?.stop();
    _log('[Hub] connection.stop() done.');
  }

  Future<void> joinConversation(int conversationId) async {
    _log('[Hub] Requesting to JoinConversation($conversationId)');
    await _ensureConnected();
    try {
      await _connection?.invoke('JoinConversation', args: [conversationId]);
      _log('[Hub] Successfully invoked JoinConversation($conversationId)');
    } catch (e) {
      _log('[Hub] Error invoking JoinConversation: $e');
    }
  }

  Future<void> leaveConversation(int conversationId) async {
    _log('[Hub] Requesting to LeaveConversation($conversationId)');
    await _ensureConnected();
    try {
      await _connection?.invoke('LeaveConversation', args: [conversationId]);
      _log('[Hub] Successfully invoked LeaveConversation($conversationId)');
    } catch (e) {
      _log('[Hub] Error invoking LeaveConversation: $e');
    }
  }

  Future<void> sendTyping(int conversationId, bool isTyping) async {
    await _ensureConnected();
    try {
      await _connection?.send('NotifyTyping', args: [conversationId, isTyping]);
    } catch (e) {
      _log('[Hub] Error sending typing notification: $e');
    }
  }

  Future<void> markAsRead(int conversationId) async {
    await _ensureConnected();
    try {
      await _connection?.invoke('MarkAsRead', args: [conversationId]);
    } catch (e) {
      _log('[Hub] Error invoking MarkAsRead: $e');
    }
  }

  Future<void> requestSupport(int conversationId, String reason) async {
    await _ensureConnected();
    try {
      await _connection?.invoke('RequestSupport', args: [conversationId, reason]);
      _log('[Hub] Support request sent for conv $conversationId');
    } catch (e) {
      _log('[Hub] Error invoking RequestSupport: $e');
    }
  }

  Future<void> _ensureConnected() async {
    if (!isConnected) {
      _log('[Hub] ensureConnected: state=${_connection?.state}, re-starting...');
      await start();
    }
  }

  void _registerHandlers() {
    _log('[Hub] Registering handlers...');

    // Listen to both cases of the event name for maximum compatibility
    _connection?.on('ReceiveMessage', _handleIncomingMessage);
    _connection?.on('receiveMessage', _handleIncomingMessage);

    _connection?.on('UserJoined', (args) {
      _log('[Hub] UserJoined event: $args');
    });

    _connection?.on('MessagesRead', (args) {
      _log('[Hub] MessagesRead raw=$args');
      final payload = _mapFromArgs(args);
      final conversationId = _intOrNull(payload['conversationId']) ??
          _intOrNull(payload['conversationid']) ??
          _intOrNull(payload['ConversationId']) ??
          (args != null && args.isNotEmpty && args[0] is int ? args[0] as int : null);
      
      final readBy = (payload['readBy'] ?? payload['readby'] ?? payload['ReadBy'])?.toString() ?? '';
      final readByName = (payload['readByName'] ?? payload['readbyname'] ?? payload['ReadByName'])?.toString() ?? '';
      final tsRaw = (payload['timestamp'] ?? payload['Timestamp'])?.toString();
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
      final requestId = _intOrNull(payload['requestId']) ??
          _intOrNull(payload['requestid']) ??
          _intOrNull(payload['RequestId']);
      final conversationId = _intOrNull(payload['conversationId']) ??
          _intOrNull(payload['conversationid']) ??
          _intOrNull(payload['ConversationId']);
      final tsRaw = (payload['timestamp'] ?? payload['Timestamp'])?.toString();
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
      final conversationId = _intOrNull(payload['conversationId']) ??
          _intOrNull(payload['conversationid']) ??
          _intOrNull(payload['ConversationId']);
      final requestId = _intOrNull(payload['requestId']) ??
          _intOrNull(payload['requestid']) ??
          _intOrNull(payload['RequestId']);
      final staffId = (payload['staffId'] ?? payload['staffid'] ?? payload['StaffId'])?.toString() ?? '';
      final staffName = (payload['staffName'] ?? payload['staffname'] ?? payload['StaffName'])?.toString() ?? '';
      final tsRaw = (payload['timestamp'] ?? payload['Timestamp'])?.toString();
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
      final requestId = _intOrNull(payload['requestId']) ??
          _intOrNull(payload['requestid']) ??
          _intOrNull(payload['RequestId']);
      final conversationId = _intOrNull(payload['conversationId']) ??
          _intOrNull(payload['conversationid']) ??
          _intOrNull(payload['ConversationId']);
      final staffId = (payload['staffId'] ?? payload['staffid'] ?? payload['StaffId'])?.toString() ?? '';
      final staffName = (payload['staffName'] ?? payload['staffname'] ?? payload['StaffName'])?.toString() ?? '';
      final tsRaw = (payload['timestamp'] ?? payload['Timestamp'])?.toString();
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
      final message = payload['message']?.toString() ?? 'Có lỗi xảy ra';
      _errorController.add(message);
    });
  }

  void _handleIncomingMessage(List<Object?>? args) {
    _log('[Hub] ReceiveMessage raw=$args');

    // Handle potential (id, message) pattern or (message) pattern
    Map<String, dynamic> payload = {};
    int? extraConversationId;

    if (args != null && args.isNotEmpty) {
      if (args.length >= 2) {
        // Pattern: [int conversationId, Map message]
        extraConversationId = _intOrNull(args[0]);
        if (args[1] is Map) {
          payload = _mapFromMap(args[1] as Map);
        }
      } else if (args[0] is Map) {
        // Pattern: [Map message]
        payload = _mapFromMap(args[0] as Map);
      }
    }

    final parsed = _parseMessage(payload);
    if (parsed != null) {
      // If conversationId was missing in payload, use the one from args
      if (parsed.conversationId == 0 && extraConversationId != null) {
        final updated = ChatRealtimeMessage(
          conversationId: extraConversationId,
          message: parsed.message,
        );
        _messageController.add(updated);
      } else {
        _messageController.add(parsed);
      }
    } else if (payload.isNotEmpty) {
      _log('[Hub] ReceiveMessage: Failed to parse payload');
    }
  }

  ChatRealtimeMessage? _parseMessage(Map<String, dynamic> payload) {
    if (payload.isEmpty) return null;
    
    _log('[Hub] Parsing payload keys: ${payload.keys.toList()}');

    final conversationId = _intOrNull(payload['conversationId']) ??
        _intOrNull(payload['conversationid']) ?? 
        _intOrNull(payload['ConversationId']) ?? 0;
    
    final id = _intOrNull(payload['id']) ?? _intOrNull(payload['Id']);
    final content = (payload['content'] ?? payload['Content'])?.toString();
    
    final senderType =
        (payload['senderType'] ?? payload['sendertype'] ?? payload['SenderType'] ?? '').toString();
    
    final senderId = (payload['senderId'] ?? payload['senderid'] ?? payload['SenderId'])?.toString();
    final senderName = (payload['senderName'] ?? payload['sendername'] ?? payload['SenderName'])?.toString();
    
    final isRead = payload['isRead'] == true ||
        payload['isread'] == true ||
        payload['IsRead'] == true ||
        payload['isRead'] == 'true' ||
        payload['isread'] == 'true' ||
        payload['IsRead'] == 'true';
        
    final createdAtRaw = (payload['createdAt'] ?? payload['createdat'] ?? payload['CreatedAt'])?.toString();

    if (id == null || content == null) {
      _log('[Hub] Parse failed: id=$id, content=${content != null ? "ok" : "null"}');
      return null;
    }

    final createdAt = DateTime.tryParse(createdAtRaw ?? '') ?? DateTime.now();

    final message = ChatMessage(
      id: id,
      content: content,
      senderType: senderType,
      senderId: senderId,
      senderName: senderName,
      createdAt: createdAt,
      isRead: isRead,
      hasJson: payload['hasJson'] == true || payload['HasJson'] == true,
      formattedJson: (payload['formattedJson'] ?? payload['FormattedJson'])?.toString(),
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
      return _mapFromMap(first);
    }
    return {};
  }

  Map<String, dynamic> _mapFromMap(Map map) {
    return map.map(
      (key, value) => MapEntry(key.toString(), value),
    );
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
