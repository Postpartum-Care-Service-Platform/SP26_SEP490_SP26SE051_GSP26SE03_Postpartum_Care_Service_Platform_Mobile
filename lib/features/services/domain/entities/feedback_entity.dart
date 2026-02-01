import 'package:equatable/equatable.dart';

/// Feedback Entity - Domain layer
class FeedbackEntity extends Equatable {
  final int id;
  final String customerId;
  final String customerName;
  final int feedbackTypeId;
  final String? feedbackTypeName;
  final String title;
  final String content;
  final int rating; // 1-5 stars
  final List<String> images; // URLs
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const FeedbackEntity({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.feedbackTypeId,
    this.feedbackTypeName,
    required this.title,
    required this.content,
    required this.rating,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  /// Check if feedback has images
  bool get hasImages => images.isNotEmpty;

  /// Get formatted date string
  String get formattedDate {
    final day = createdAt.day.toString().padLeft(2, '0');
    final month = createdAt.month.toString().padLeft(2, '0');
    final year = createdAt.year;
    return '$day/$month/$year';
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        feedbackTypeId,
        feedbackTypeName,
        title,
        content,
        rating,
        images,
        createdAt,
        updatedAt,
        isDeleted,
      ];
}
