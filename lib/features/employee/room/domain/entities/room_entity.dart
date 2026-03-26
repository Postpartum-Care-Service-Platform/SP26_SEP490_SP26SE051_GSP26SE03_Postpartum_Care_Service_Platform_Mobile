import 'room_status.dart';

/// Room Entity
/// Domain model for room data
class RoomEntity {
  /// Room ID
  final int id;

  /// Room Type ID
  final int roomTypeId;

  /// Room Type Name
  final String roomTypeName;

  /// Room name/number
  final String name;

  /// Floor number
  final int? floor;

  /// Room status
  final RoomStatus status;

  /// Is active
  final bool isActive;

  /// Created at timestamp
  final DateTime createdAt;

  /// Updated at timestamp
  final DateTime updatedAt;

  /// Booking ID (current or upcoming)
  final int? bookingId;

  /// Booking start date
  final DateTime? bookingStartDate;

  /// Booking end date
  final DateTime? bookingEndDate;

  /// Is room currently occupied
  final bool isOccupied;

  const RoomEntity({
    required this.id,
    required this.roomTypeId,
    required this.roomTypeName,
    required this.name,
    this.floor,
    required this.status,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.bookingId,
    this.bookingStartDate,
    this.bookingEndDate,
    this.isOccupied = false,
  });

  /// Create a copy with updated fields
  RoomEntity copyWith({
    int? id,
    int? roomTypeId,
    String? roomTypeName,
    String? name,
    int? floor,
    RoomStatus? status,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? bookingId,
    DateTime? bookingStartDate,
    DateTime? bookingEndDate,
    bool? isOccupied,
  }) {
    return RoomEntity(
      id: id ?? this.id,
      roomTypeId: roomTypeId ?? this.roomTypeId,
      roomTypeName: roomTypeName ?? this.roomTypeName,
      name: name ?? this.name,
      floor: floor ?? this.floor,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bookingId: bookingId ?? this.bookingId,
      bookingStartDate: bookingStartDate ?? this.bookingStartDate,
      bookingEndDate: bookingEndDate ?? this.bookingEndDate,
      isOccupied: isOccupied ?? this.isOccupied,
    );
  }
}
