import '../../domain/entities/home_activity_entity.dart';

/// Home Activity Model - Data layer
class HomeActivityModel extends HomeActivityEntity {
  const HomeActivityModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.target,
    required super.activityTypeId,
    required super.activityTypeName,
    required super.duration,
    required super.status,
  });

  factory HomeActivityModel.fromJson(Map<String, dynamic> json) {
    return HomeActivityModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num?)?.toDouble(),
      target: json['target'] as String? ?? '',
      activityTypeId: json['activityTypeId'] as int,
      activityTypeName: json['activityTypeName'] as String? ?? '',
      duration: json['duration'] as int,
      status: json['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'target': target,
      'activityTypeId': activityTypeId,
      'activityTypeName': activityTypeName,
      'duration': duration,
      'status': status,
    };
  }

  HomeActivityEntity toEntity() {
    return HomeActivityEntity(
      id: id,
      name: name,
      description: description,
      price: price,
      target: target,
      activityTypeId: activityTypeId,
      activityTypeName: activityTypeName,
      duration: duration,
      status: status,
    );
  }
}
