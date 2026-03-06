import '../../domain/entities/home_service_booking_entity.dart';

/// Home Service Booking Model - Data layer
class HomeServiceBookingModel extends HomeServiceBookingEntity {
  const HomeServiceBookingModel({
    required super.id,
    required super.staffId,
    required super.totalPrice,
    required super.paidAmount,
    required super.remainingAmount,
    required super.status,
    required super.createdAt,
    required super.services,
  });

  factory HomeServiceBookingModel.fromJson(Map<String, dynamic> json) {
    return HomeServiceBookingModel(
      id: json['id'] as int,
      staffId: json['staffId'] as String,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num).toDouble(),
      remainingAmount: (json['remainingAmount'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      services: (json['services'] as List<dynamic>?)
              ?.map((item) => HomeServiceBookingItemModel.fromJson(
                    item as Map<String, dynamic>,
                  ))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffId': staffId,
      'totalPrice': totalPrice,
      'paidAmount': paidAmount,
      'remainingAmount': remainingAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'services': services.map((item) => (item as HomeServiceBookingItemModel).toJson()).toList(),
    };
  }

  HomeServiceBookingEntity toEntity() {
    return HomeServiceBookingEntity(
      id: id,
      staffId: staffId,
      totalPrice: totalPrice,
      paidAmount: paidAmount,
      remainingAmount: remainingAmount,
      status: status,
      createdAt: createdAt,
      services: services,
    );
  }
}

/// Home Service Booking Item Model
class HomeServiceBookingItemModel extends HomeServiceBookingItemEntity {
  const HomeServiceBookingItemModel({
    required super.activityId,
    required super.serviceDates,
    required super.startTime,
    required super.endTime,
  });

  factory HomeServiceBookingItemModel.fromJson(Map<String, dynamic> json) {
    return HomeServiceBookingItemModel(
      activityId: json['activityId'] as int,
      serviceDates: (json['serviceDates'] as List<dynamic>)
          .map((date) => DateTime.parse(date as String))
          .toList(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activityId': activityId,
      'serviceDates': serviceDates
          .map((date) => date.toIso8601String().split('T')[0])
          .toList(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }
}
