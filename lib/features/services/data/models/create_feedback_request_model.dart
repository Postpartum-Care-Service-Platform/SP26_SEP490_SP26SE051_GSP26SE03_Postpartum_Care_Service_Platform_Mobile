import 'dart:io';

/// Create Feedback Request Model
class CreateFeedbackRequestModel {
  final int feedbackTypeId;
  final String title;
  final String content;
  final int rating;
  final List<File> images;

  CreateFeedbackRequestModel({
    required this.feedbackTypeId,
    required this.title,
    required this.content,
    required this.rating,
    required this.images,
  });

  Map<String, dynamic> toFormData() {
    final Map<String, dynamic> data = {
      'FeedbackTypeId': feedbackTypeId.toString(),
      'Title': title,
      'Content': content,
      'Rating': rating.toString(),
    };

    // Images will be handled separately in datasource
    return data;
  }
}
