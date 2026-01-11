import '../../domain/entities/notification_entity.dart';

/// Notification model - Data layer
class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.category,
    required super.title,
    super.description,
    required super.createdAt,
    super.isRead,
    required super.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      category: json['category'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      type: _parseType(json['type'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'type': _typeToString(type),
    };
  }

  static NotificationType _parseType(String? type) {
    switch (type) {
      case 'payment':
        return NotificationType.payment;
      case 'reminder':
        return NotificationType.reminder;
      case 'security':
        return NotificationType.security;
      case 'loan':
        return NotificationType.loan;
      case 'budget':
        return NotificationType.budget;
      default:
        return NotificationType.general;
    }
  }

  static String _typeToString(NotificationType type) {
    switch (type) {
      case NotificationType.payment:
        return 'payment';
      case NotificationType.reminder:
        return 'reminder';
      case NotificationType.security:
        return 'security';
      case NotificationType.loan:
        return 'loan';
      case NotificationType.budget:
        return 'budget';
      case NotificationType.general:
        return 'general';
    }
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      category: category,
      title: title,
      description: description,
      createdAt: createdAt,
      isRead: isRead,
      type: type,
    );
  }
}
