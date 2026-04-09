import '../../domain/entities/room_info_entity.dart';

/// Room Info Model - Data layer
class RoomInfoModel {
  final int id;
  final String name;
  final int? floor;
  final String roomTypeName;

  RoomInfoModel({
    required this.id,
    required this.name,
    this.floor,
    required this.roomTypeName,
  });

  factory RoomInfoModel.fromJson(Map<String, dynamic> json) {
    return RoomInfoModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      floor: (json['floor'] as num?)?.toInt(),
      roomTypeName: (json['roomTypeName'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'floor': floor,
      'roomTypeName': roomTypeName,
    };
  }

  RoomInfoEntity toEntity() {
    return RoomInfoEntity(
      id: id,
      name: name,
      floor: floor,
      roomTypeName: roomTypeName,
    );
  }
}
