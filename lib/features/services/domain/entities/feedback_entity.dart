import 'package:equatable/equatable.dart';

class FeedbackFamilyScheduleInfo extends Equatable {
  final int id;
  final String? activity;
  final String? workDate;
  final String? startTime;
  final String? endTime;

  const FeedbackFamilyScheduleInfo({
    required this.id,
    this.activity,
    this.workDate,
    this.startTime,
    this.endTime,
  });

  @override
  List<Object?> get props => [id, activity, workDate, startTime, endTime];
}

class FeedbackStaffInfo extends Equatable {
  final String staffId;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? avatarUrl;

  const FeedbackStaffInfo({
    required this.staffId,
    this.fullName,
    this.email,
    this.phone,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [staffId, fullName, email, phone, avatarUrl];
}

class FeedbackAmenityTicketInfo extends Equatable {
  final int amenityTicketId;
  final String? amenityServiceName;
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? status;
  final String? amenityStaffName;

  const FeedbackAmenityTicketInfo({
    required this.amenityTicketId,
    this.amenityServiceName,
    this.date,
    this.startTime,
    this.endTime,
    this.status,
    this.amenityStaffName,
  });

  @override
  List<Object?> get props => [
        amenityTicketId,
        amenityServiceName,
        date,
        startTime,
        endTime,
        status,
        amenityStaffName
      ];
}

/// Feedback Entity - Domain layer
class FeedbackEntity extends Equatable {
  final int id;
  final String customerId;
  final String customerName;
  final int feedbackTypeId;
  final String? feedbackTypeName;
  final int? bookingId;
  final int? familyScheduleId;
  final String? staffId;
  final String? staffName;
  final int? amenityTicketId;
  final String? amenityServiceName;
  final String title;
  final String content;
  final int rating; // 1-5 stars
  final List<String> images; // URLs
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  final FeedbackFamilyScheduleInfo? familyScheduleInfo;
  final FeedbackStaffInfo? staffInfo;
  final FeedbackAmenityTicketInfo? amenityTicketInfo;

  const FeedbackEntity({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.feedbackTypeId,
    this.feedbackTypeName,
    this.bookingId,
    this.familyScheduleId,
    this.staffId,
    this.staffName,
    this.amenityTicketId,
    this.amenityServiceName,
    required this.title,
    required this.content,
    required this.rating,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.familyScheduleInfo,
    this.staffInfo,
    this.amenityTicketInfo,
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
        bookingId,
        familyScheduleId,
        staffId,
        staffName,
        amenityTicketId,
        amenityServiceName,
        title,
        content,
        rating,
        images,
        createdAt,
        updatedAt,
        isDeleted,
        familyScheduleInfo,
        staffInfo,
        amenityTicketInfo,
      ];
}
