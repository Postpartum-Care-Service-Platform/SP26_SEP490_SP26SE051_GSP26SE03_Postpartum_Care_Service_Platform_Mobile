import 'dart:convert';
import '../../domain/entities/feedback_entity.dart';

/// Feedback Model - Data layer
class FeedbackModel extends FeedbackEntity {
  const FeedbackModel({
    required super.id,
    required super.customerId,
    required super.customerName,
    required super.feedbackTypeId,
    super.feedbackTypeName,
    super.bookingId,
    super.familyScheduleId,
    super.staffId,
    super.staffName,
    super.amenityTicketId,
    super.amenityServiceName,
    required super.title,
    required super.content,
    required super.rating,
    required super.images,
    required super.createdAt,
    required super.updatedAt,
    required super.isDeleted,
    super.familyScheduleInfo,
    super.staffInfo,
    super.amenityTicketInfo,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    // Parse images - can be JSON string or array
    List<String> images = [];
    if (json['images'] != null) {
      if (json['images'] is String) {
        try {
          final decoded = jsonDecode(json['images'] as String);
          if (decoded is List) {
            images = decoded.map((e) => e.toString()).toList();
          }
        } catch (e) {
          // If parsing fails, treat as empty
          images = [];
        }
      } else if (json['images'] is List) {
        images = (json['images'] as List).map((e) => e.toString()).toList();
      }
    }

    // Parse content and unescape \n characters
    String content = json['content'] as String;
    // Replace \\n with actual newline character
    content = content.replaceAll('\\n', '\n');

    return FeedbackModel(
      id: json['id'] as int,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      feedbackTypeId: json['feedbackTypeId'] as int,
      feedbackTypeName: json['feedbackTypeName'] as String?,
      bookingId: json['bookingId'] as int?,
      familyScheduleId: json['familyScheduleId'] as int?,
      staffId: json['staffId'] as String?,
      staffName: json['staffName'] as String?,
      amenityTicketId: json['amenityTicketId'] as int?,
      amenityServiceName: json['amenityServiceName'] as String?,
      title: json['title'] as String,
      content: content,
      rating: json['rating'] as int,
      images: images,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
      familyScheduleInfo: json['familyScheduleInfo'] != null
          ? FeedbackFamilyScheduleInfo(
              id: json['familyScheduleInfo']['id'] as int? ?? 0,
              activity: json['familyScheduleInfo']['activity'] as String?,
              workDate: json['familyScheduleInfo']['workDate'] as String?,
              startTime: json['familyScheduleInfo']['startTime'] as String?,
              endTime: json['familyScheduleInfo']['endTime'] as String?,
            )
          : null,
      staffInfo: json['staffInfo'] != null
          ? FeedbackStaffInfo(
              staffId: json['staffInfo']['staffId'] as String? ?? '',
              fullName: json['staffInfo']['fullName'] as String?,
              email: json['staffInfo']['email'] as String?,
              phone: json['staffInfo']['phone'] as String?,
              avatarUrl: json['staffInfo']['avatarUrl'] as String?,
            )
          : null,
      amenityTicketInfo: json['amenityTicketInfo'] != null
          ? FeedbackAmenityTicketInfo(
              amenityTicketId: json['amenityTicketInfo']['amenityTicketId'] as int? ?? 0,
              amenityServiceName: json['amenityTicketInfo']['amenityServiceName'] as String?,
              date: json['amenityTicketInfo']['date'] as String?,
              startTime: json['amenityTicketInfo']['startTime'] as String?,
              endTime: json['amenityTicketInfo']['endTime'] as String?,
              status: json['amenityTicketInfo']['status'] as String?,
              amenityStaffName: json['amenityTicketInfo']['amenityStaffName'] as String?,
            )
          : null,
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
      'familyScheduleId': familyScheduleId,
      'staffId': staffId,
      'staffName': staffName,
      'amenityTicketId': amenityTicketId,
      'amenityServiceName': amenityServiceName,
      'title': title,
      'content': content,
      'rating': rating,
      'images': jsonEncode(images),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  FeedbackEntity toEntity() {
    return FeedbackEntity(
      id: id,
      customerId: customerId,
      customerName: customerName,
      feedbackTypeId: feedbackTypeId,
      feedbackTypeName: feedbackTypeName,
      bookingId: bookingId,
      familyScheduleId: familyScheduleId,
      staffId: staffId,
      staffName: staffName,
      amenityTicketId: amenityTicketId,
      amenityServiceName: amenityServiceName,
      title: title,
      content: content,
      rating: rating,
      images: images,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
      familyScheduleInfo: familyScheduleInfo,
      staffInfo: staffInfo,
      amenityTicketInfo: amenityTicketInfo,
    );
  }
}
