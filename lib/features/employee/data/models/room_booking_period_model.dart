class RoomBookingPeriodModel {
  final int id;
  final int roomId;
  final String roomName;
  final String roomTypeName;
  final int bookingId;
  final DateTime startDate;
  final DateTime endDate;

  RoomBookingPeriodModel({
    required this.id,
    required this.roomId,
    required this.roomName,
    required this.roomTypeName,
    required this.bookingId,
    required this.startDate,
    required this.endDate,
  });

  factory RoomBookingPeriodModel.fromJson(Map<String, dynamic> json) {
    return RoomBookingPeriodModel(
      id: json['id'] as int,
      roomId: json['roomId'] as int,
      roomName: json['roomName'] as String? ?? '',
      roomTypeName: json['roomTypeName'] as String? ?? '',
      bookingId: json['bookingId'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }
}
