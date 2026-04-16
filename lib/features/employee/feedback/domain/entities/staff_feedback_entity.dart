import 'package:equatable/equatable.dart';

class StaffFeedbackEntity extends Equatable {
  final int id;
  final String customerId;
  final String customerName;
  final int feedbackTypeId;
  final String feedbackTypeName;
  final int? bookingId;
  final String? title;
  final String? content;
  final int? rating;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final int? familyScheduleId;
  final bool? isPosted;
  final String staffId;
  final String staffName;
  final int? amenityTicketId;
  final String? amenityServiceName;

  const StaffFeedbackEntity({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.feedbackTypeId,
    required this.feedbackTypeName,
    this.bookingId,
    this.title,
    this.content,
    this.rating,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.familyScheduleId,
    this.isPosted,
    required this.staffId,
    required this.staffName,
    this.amenityTicketId,
    this.amenityServiceName,
  });

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        feedbackTypeId,
        feedbackTypeName,
        bookingId,
        title,
        content,
        rating,
        images,
        createdAt,
        updatedAt,
        isDeleted,
        familyScheduleId,
        isPosted,
        staffId,
        staffName,
        amenityTicketId,
        amenityServiceName,
      ];
}
