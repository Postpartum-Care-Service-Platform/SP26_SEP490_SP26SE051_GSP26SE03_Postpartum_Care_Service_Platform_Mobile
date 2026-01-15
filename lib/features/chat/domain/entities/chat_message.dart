import 'package:equatable/equatable.dart';

/// Chat message entity
class ChatMessage extends Equatable {
  final int id;
  final String content;
  final String senderType;
  final String? senderId;
  final String? senderName;
  final DateTime createdAt;
  final bool isRead;
  final bool hasJson;
  final String? formattedJson;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.senderType,
    this.senderId,
    this.senderName,
    required this.createdAt,
    required this.isRead,
    this.hasJson = false,
    this.formattedJson,
  });

  @override
  List<Object?> get props => [
        id,
        content,
        senderType,
        senderId,
        senderName,
        createdAt,
        isRead,
        hasJson,
        formattedJson,
      ];
}

