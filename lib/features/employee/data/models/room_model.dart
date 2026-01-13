import '../../domain/entities/room_entity.dart';
import '../../domain/entities/room_status.dart';

/// Room Data Model
/// Maps to API response structure
class RoomModel {
  final int id;
  final int roomTypeId;
  final String roomTypeName;
  final String name;
  final int? floor;
  final String status;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoomModel({
    required this.id,
    required this.roomTypeId,
    required this.roomTypeName,
    required this.name,
    this.floor,
    required this.status,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert from JSON
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as int,
      roomTypeId: json['roomTypeId'] as int,
      roomTypeName: json['roomTypeName'] as String? ?? '',
      name: json['name'] as String,
      floor: json['floor'] as int?,
      status: json['status'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomTypeId': roomTypeId,
      'roomTypeName': roomTypeName,
      'name': name,
      'floor': floor,
      'status': status,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert to Entity
  RoomEntity toEntity() {
    return RoomEntity(
      id: id,
      roomTypeId: roomTypeId,
      roomTypeName: roomTypeName,
      name: name,
      floor: floor,
      status: RoomStatusExtension.fromApiString(status),
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from Entity
  factory RoomModel.fromEntity(RoomEntity entity) {
    return RoomModel(
      id: entity.id,
      roomTypeId: entity.roomTypeId,
      roomTypeName: entity.roomTypeName,
      name: entity.name,
      floor: entity.floor,
      status: entity.status.toApiString(),
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
