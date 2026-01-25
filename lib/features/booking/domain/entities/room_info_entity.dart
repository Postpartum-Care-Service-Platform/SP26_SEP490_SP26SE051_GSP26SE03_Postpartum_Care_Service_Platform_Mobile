import 'package:equatable/equatable.dart';

/// Room Info Entity - Domain layer (simplified room info in booking)
class RoomInfoEntity extends Equatable {
  final int id;
  final String name;
  final int? floor;
  final String roomTypeName;

  const RoomInfoEntity({
    required this.id,
    required this.name,
    this.floor,
    required this.roomTypeName,
  });

  @override
  List<Object?> get props => [id, name, floor, roomTypeName];
}
