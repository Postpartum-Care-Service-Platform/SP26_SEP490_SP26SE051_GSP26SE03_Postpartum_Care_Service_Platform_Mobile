import 'package:equatable/equatable.dart';

/// Home Service Booking Entity - Domain layer
class HomeServiceBookingEntity extends Equatable {
  final int id;
  final String staffId;
  final double totalPrice;
  final double paidAmount;
  final double remainingAmount;
  final String status;
  final DateTime createdAt;
  final List<HomeServiceBookingItemEntity> services;

  const HomeServiceBookingEntity({
    required this.id,
    required this.staffId,
    required this.totalPrice,
    required this.paidAmount,
    required this.remainingAmount,
    required this.status,
    required this.createdAt,
    required this.services,
  });

  HomeServiceBookingEntity copyWith({
    int? id,
    String? staffId,
    double? totalPrice,
    double? paidAmount,
    double? remainingAmount,
    String? status,
    DateTime? createdAt,
    List<HomeServiceBookingItemEntity>? services,
  }) {
    return HomeServiceBookingEntity(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      totalPrice: totalPrice ?? this.totalPrice,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      services: services ?? this.services,
    );
  }

  @override
  List<Object?> get props => [
        id,
        staffId,
        totalPrice,
        paidAmount,
        remainingAmount,
        status,
        createdAt,
        services,
      ];
}

/// Home Service Booking Item Entity
class HomeServiceBookingItemEntity extends Equatable {
  final int activityId;
  final List<DateTime> serviceDates;
  final DateTime startTime;
  final DateTime endTime;

  const HomeServiceBookingItemEntity({
    required this.activityId,
    required this.serviceDates,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [
        activityId,
        serviceDates,
        startTime,
        endTime,
      ];
}
