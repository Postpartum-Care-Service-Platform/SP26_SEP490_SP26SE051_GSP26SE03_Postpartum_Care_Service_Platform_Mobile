import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.content,
    required super.senderType,
    super.senderId,
    super.senderName,
    required super.createdAt,
    required super.isRead,
    super.hasJson,
    super.formattedJson,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as int,
      content: (json['content'] ?? '').toString(),
      senderType: (json['senderType'] ?? '').toString(),
      senderId: json['senderId']?.toString(),
      senderName: json['senderName']?.toString(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] == true,
      hasJson: json['hasJson'] == true,
      formattedJson: json['formattedJson']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'senderType': senderType,
      'senderId': senderId,
      'senderName': senderName,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'hasJson': hasJson,
      'formattedJson': formattedJson,
    };
  }
}

