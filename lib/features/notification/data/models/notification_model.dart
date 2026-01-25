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

@override
  NotificationModel copyWith({
    String? id,
    String? category,
    String? title,
    String? description,
    DateTime? createdAt,
    bool? isRead,
    NotificationType? type,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final status = (json['status'] as String?)?.toLowerCase();
    final typeName = json['notificationTypeName'] as String?;
    return NotificationModel(
      id: (json['id'] ?? '').toString(),
      category: typeName ?? 'Thông báo',
      title: (json['title'] ?? '').toString(),
      description: json['content'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: status == 'read',
      type: _parseType(typeName),
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

  static NotificationType _parseType(String? typeName) {
    final normalized = (typeName ?? '').toLowerCase();
    if (normalized.contains('payment')) return NotificationType.payment;
    if (normalized.contains('reminder')) return NotificationType.reminder;
    if (normalized.contains('security')) return NotificationType.security;
    if (normalized.contains('loan')) return NotificationType.loan;
    if (normalized.contains('budget')) return NotificationType.budget;
    return NotificationType.general;
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
