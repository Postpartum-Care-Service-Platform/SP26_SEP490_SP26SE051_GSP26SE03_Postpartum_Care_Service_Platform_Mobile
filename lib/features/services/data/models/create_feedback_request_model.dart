import 'dart:io';

/// Create Feedback Request Model
class CreateFeedbackRequestModel {
  final int feedbackTypeId;
  final String title;
  final String content;
  final int rating;
  final List<File> images;
  final int? familyScheduleId;
  final String? staffId;
  final int? amenityTicketId;

  CreateFeedbackRequestModel({
    required this.feedbackTypeId,
    required this.title,
    required this.content,
    required this.rating,
    required this.images,
    this.familyScheduleId,
    this.staffId,
    this.amenityTicketId,
  });

  Map<String, dynamic> toFormData() {
    final Map<String, dynamic> data = {
      'FeedbackTypeId': feedbackTypeId.toString(),
      'Title': title,
      'Content': content,
      'Rating': rating.toString(),
    };

    if (familyScheduleId != null) {
      data['FamilyScheduleId'] = familyScheduleId.toString();
    }
    if (staffId != null && staffId!.isNotEmpty) {
      data['StaffId'] = staffId;
    }
    if (amenityTicketId != null) {
      data['AmenityTicketId'] = amenityTicketId.toString();
    }

    // Images will be handled separately in datasource
    return data;
  }
}
