import 'package:equatable/equatable.dart';
import 'customer_entity.dart';
import 'package_info_entity.dart';
import 'room_info_entity.dart';
import 'contract_entity.dart';
import 'transaction_entity.dart';
import 'target_booking_entity.dart';

/// Booking Entity - Domain layer
class BookingEntity extends Equatable {
  final int id;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final double discountAmount;
  final double finalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String status; // Pending, Confirmed, Cancelled
  final DateTime bookingDate;
  final DateTime createdAt;
  final String? homeStaffId;
  final CustomerEntity? customer;
  final PackageInfoEntity? package;
  final RoomInfoEntity? room;
  final ContractEntity? contract;
  final List<TransactionEntity> transactions;
  final List<TargetBookingEntity> targetBookings;

  const BookingEntity({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.discountAmount,
    required this.finalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.status,
    required this.bookingDate,
    required this.createdAt,
    this.homeStaffId,
    this.customer,
    this.package,
    this.room,
    this.contract,
    this.transactions = const [],
    this.targetBookings = const [],
  });

  BookingEntity copyWith({
    int? id,
    DateTime? startDate,
    DateTime? endDate,
    double? totalPrice,
    double? discountAmount,
    double? finalAmount,
    double? paidAmount,
    double? remainingAmount,
    String? status,
    DateTime? bookingDate,
    DateTime? createdAt,
    String? homeStaffId,
    CustomerEntity? customer,
    PackageInfoEntity? package,
    RoomInfoEntity? room,
    ContractEntity? contract,
    List<TransactionEntity>? transactions,
    List<TargetBookingEntity>? targetBookings,
  }) {
    return BookingEntity(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalPrice: totalPrice ?? this.totalPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      status: status ?? this.status,
      bookingDate: bookingDate ?? this.bookingDate,
      createdAt: createdAt ?? this.createdAt,
      homeStaffId: homeStaffId ?? this.homeStaffId,
      customer: customer ?? this.customer,
      package: package ?? this.package,
      room: room ?? this.room,
      contract: contract ?? this.contract,
      transactions: transactions ?? this.transactions,
      targetBookings: targetBookings ?? this.targetBookings,
    );
  }

  @override
  List<Object?> get props => [
        id,
        startDate,
        endDate,
        totalPrice,
        discountAmount,
        finalAmount,
        paidAmount,
        remainingAmount,
        status,
        bookingDate,
        createdAt,
        homeStaffId,
        customer,
        package,
        room,
        contract,
        transactions,
        targetBookings,
      ];
}
