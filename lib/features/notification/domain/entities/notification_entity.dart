import 'package:equatable/equatable.dart';

/// Notification entity - Domain layer
class NotificationEntity extends Equatable {
  final String id;
  final String category;
  final String title;
  final String? description;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType type;

  const NotificationEntity({
    required this.id,
    required this.category,
    required this.title,
    this.description,
    required this.createdAt,
    this.isRead = false,
    required this.type,
  });

  @override
  List<Object?> get props => [
        id,
        category,
        title,
        description,
        createdAt,
        isRead,
        type,
      ];

  NotificationEntity copyWith({
    String? id,
    String? category,
    String? title,
    String? description,
    DateTime? createdAt,
    bool? isRead,
    NotificationType? type,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}

enum NotificationType {
  payment,
  reminder,
  security,
  loan,
  budget,
  general,
}
