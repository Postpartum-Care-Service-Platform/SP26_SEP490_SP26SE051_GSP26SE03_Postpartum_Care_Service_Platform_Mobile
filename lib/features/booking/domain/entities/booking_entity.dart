import 'package:equatable/equatable.dart';
import 'customer_entity.dart';
import 'package_info_entity.dart';
import 'room_info_entity.dart';
import 'contract_entity.dart';
import 'transaction_entity.dart';

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
  final CustomerEntity? customer;
  final PackageInfoEntity? package;
  final RoomInfoEntity? room;
  final ContractEntity? contract;
  final List<TransactionEntity> transactions;

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
    this.customer,
    this.package,
    this.room,
    this.contract,
    this.transactions = const [],
  });

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
        customer,
        package,
        room,
        contract,
        transactions,
      ];
}
