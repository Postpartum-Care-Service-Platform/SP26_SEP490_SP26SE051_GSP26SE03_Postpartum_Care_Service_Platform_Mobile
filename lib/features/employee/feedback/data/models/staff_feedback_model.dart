import '../../domain/entities/staff_feedback_entity.dart';
import 'dart:convert';

class StaffFeedbackModel extends StaffFeedbackEntity {
  const StaffFeedbackModel({
    required super.id,
    required super.customerId,
    required super.customerName,
    required super.feedbackTypeId,
    required super.feedbackTypeName,
    super.bookingId,
    super.title,
    super.content,
    super.rating,
    required super.images,
    required super.createdAt,
    required super.updatedAt,
    required super.isDeleted,
    super.familyScheduleId,
    super.isPosted,
    required super.staffId,
    required super.staffName,
    super.amenityTicketId,
    super.amenityServiceName,
  });

  factory StaffFeedbackModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedImages = [];
    if (json['images'] != null) {
      if (json['images'] is String) {
        try {
          final decoded = jsonDecode(json['images']);
          if (decoded is List) {
            parsedImages = decoded.map((e) => e.toString()).toList();
          }
        } catch (e) {
          // Fallback if it's a plain string or invalid JSON
          parsedImages = [];
        }
      } else if (json['images'] is List) {
        parsedImages = (json['images'] as List).map((e) => e.toString()).toList();
      }
    }

    return StaffFeedbackModel(
      id: json['id'] as int,
      customerId: json['customerId'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      feedbackTypeId: json['feedbackTypeId'] as int? ?? 0,
      feedbackTypeName: json['feedbackTypeName'] as String? ?? '',
      bookingId: json['bookingId'] as int?,
      title: json['title'] as String?,
      content: json['content'] as String?,
      rating: json['rating'] as int?,
      images: parsedImages,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
      isDeleted: json['isDeleted'] as bool? ?? false,
      familyScheduleId: json['familyScheduleId'] as int?,
      isPosted: json['isPosted'] as bool?,
      staffId: json['staffId'] as String? ?? '',
      staffName: json['staffName'] as String? ?? '',
      amenityTicketId: json['amenityTicketId'] as int?,
      amenityServiceName: json['amenityServiceName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'feedbackTypeId': feedbackTypeId,
      'feedbackTypeName': feedbackTypeName,
      'bookingId': bookingId,
      'title': title,
      'content': content,
      'rating': rating,
      'images': jsonEncode(images),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'familyScheduleId': familyScheduleId,
      'isPosted': isPosted,
      'staffId': staffId,
      'staffName': staffName,
      'amenityTicketId': amenityTicketId,
      'amenityServiceName': amenityServiceName,
    };
  }
}
