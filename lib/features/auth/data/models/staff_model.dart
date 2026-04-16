import '../../domain/entities/staff_entity.dart';

/// Staff Model - Data layer
class StaffModel extends StaffEntity {
  const StaffModel({
    required super.id,
    required super.fullName,
    super.phone,
    super.avatarUrl,
    super.email,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'email': email,
    };
  }

  static List<StaffModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => StaffModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
