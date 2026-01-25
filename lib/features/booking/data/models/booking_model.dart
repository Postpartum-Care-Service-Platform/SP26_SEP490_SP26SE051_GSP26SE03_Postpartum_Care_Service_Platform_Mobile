import '../../domain/entities/booking_entity.dart';
import 'customer_model.dart';
import 'package_info_model.dart';
import 'room_info_model.dart';
import 'contract_model.dart';
import 'transaction_model.dart';

/// Booking Model - Data layer
class BookingModel {
  final int id;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final double discountAmount;
  final double finalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String status;
  final DateTime bookingDate;
  final DateTime createdAt;
  final CustomerModel? customer;
  final PackageInfoModel? package;
  final RoomInfoModel? room;
  final ContractModel? contract;
  final List<TransactionModel> transactions;

  BookingModel({
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

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      finalAmount: (json['finalAmount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num).toDouble(),
      remainingAmount: (json['remainingAmount'] as num).toDouble(),
      status: json['status'] as String,
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      package: json['package'] != null
          ? PackageInfoModel.fromJson(json['package'] as Map<String, dynamic>)
          : null,
      room: json['room'] != null
          ? RoomInfoModel.fromJson(json['room'] as Map<String, dynamic>)
          : null,
      contract: json['contract'] != null
          ? ContractModel.fromJson(json['contract'] as Map<String, dynamic>)
          : null,
      transactions: json['transactions'] != null
          ? (json['transactions'] as List<dynamic>)
              .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0],
      'totalPrice': totalPrice,
      'discountAmount': discountAmount,
      'finalAmount': finalAmount,
      'paidAmount': paidAmount,
      'remainingAmount': remainingAmount,
      'status': status,
      'bookingDate': bookingDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'customer': customer?.toJson(),
      'package': package?.toJson(),
      'room': room?.toJson(),
      'contract': contract?.toJson(),
      'transactions': transactions.map((e) => e.toJson()).toList(),
    };
  }

  BookingEntity toEntity() {
    return BookingEntity(
      id: id,
      startDate: startDate,
      endDate: endDate,
      totalPrice: totalPrice,
      discountAmount: discountAmount,
      finalAmount: finalAmount,
      paidAmount: paidAmount,
      remainingAmount: remainingAmount,
      status: status,
      bookingDate: bookingDate,
      createdAt: createdAt,
      customer: customer?.toEntity(),
      package: package?.toEntity(),
      room: room?.toEntity(),
      contract: contract?.toEntity(),
      transactions: transactions.map((e) => e.toEntity()).toList(),
    );
  }
}
