/// Room Status Enum
/// Maps to Backend RoomStatus enum
enum RoomStatus {
  /// Available - Phòng trống
  available,
  
  /// Occupied - Đang sử dụng
  occupied,
  
  /// Maintenance - Đang bảo trì
  maintenance,
  
  /// Inactive - Không hoạt động
  inactive,
}

/// Extension for RoomStatus
extension RoomStatusExtension on RoomStatus {
  /// Convert to string for API
  String toApiString() {
    switch (this) {
      case RoomStatus.available:
        return 'Available';
      case RoomStatus.occupied:
        return 'Occupied';
      case RoomStatus.maintenance:
        return 'Maintenance';
      case RoomStatus.inactive:
        return 'Inactive';
    }
  }

  /// Get display text in Vietnamese
  String get displayText {
    switch (this) {
      case RoomStatus.available:
        return 'Trống';
      case RoomStatus.occupied:
        return 'Đang sử dụng';
      case RoomStatus.maintenance:
        return 'Bảo trì';
      case RoomStatus.inactive:
        return 'Không hoạt động';
    }
  }

  /// Parse from API string
  static RoomStatus fromApiString(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return RoomStatus.available;
      case 'occupied':
        return RoomStatus.occupied;
      case 'maintenance':
        return RoomStatus.maintenance;
      case 'inactive':
        return RoomStatus.inactive;
      default:
        return RoomStatus.available;
    }
  }
}
