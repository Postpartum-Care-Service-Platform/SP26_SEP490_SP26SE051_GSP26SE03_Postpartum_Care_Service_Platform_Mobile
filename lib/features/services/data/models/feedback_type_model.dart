import '../../domain/entities/feedback_type_entity.dart';

/// Feedback Type Model - Data layer
class FeedbackTypeModel extends FeedbackTypeEntity {
  const FeedbackTypeModel({
    required super.id,
    required super.name,
    required super.isActive,
  });

  factory FeedbackTypeModel.fromJson(Map<String, dynamic> json) {
    return FeedbackTypeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
    };
  }

  FeedbackTypeEntity toEntity() {
    return FeedbackTypeEntity(
      id: id,
      name: name,
      isActive: isActive,
    );
  }
}
