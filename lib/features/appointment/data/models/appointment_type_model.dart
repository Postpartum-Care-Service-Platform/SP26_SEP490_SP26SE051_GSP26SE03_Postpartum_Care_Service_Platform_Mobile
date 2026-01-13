import '../../domain/entities/appointment_type_entity.dart';

/// Appointment type model - Data layer
class AppointmentTypeModel {
  final int id;
  final String name;
  final bool isActive;
  final DateTime createdAt;

  const AppointmentTypeModel({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
  });

  factory AppointmentTypeModel.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'];
    final int id;
    if (idValue is int) {
      id = idValue;
    } else if (idValue is String) {
      id = int.parse(idValue);
    } else {
      throw Exception('Invalid appointmentType.id type: ${idValue.runtimeType}');
    }

    DateTime createdAt;
    final createdAtRaw = json['createdAt'];
    if (createdAtRaw is String && createdAtRaw.isNotEmpty) {
      createdAt = DateTime.parse(createdAtRaw);
    } else {
      createdAt = DateTime.now();
    }

    return AppointmentTypeModel(
      id: id,
      name: (json['name'] ?? '').toString().trim(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  AppointmentTypeEntity toEntity() {
    return AppointmentTypeEntity(
      id: id,
      name: name,
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}

