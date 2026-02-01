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
    required super.title,
    required super.content,
    required super.rating,
    required super.images,
    required super.createdAt,
    required super.updatedAt,
    required super.isDeleted,
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
      title: json['title'] as String,
      content: content,
      rating: json['rating'] as int,
      images: images,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'feedbackTypeId': feedbackTypeId,
      'feedbackTypeName': feedbackTypeName,
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
      title: title,
      content: content,
      rating: rating,
      images: images,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }
}
