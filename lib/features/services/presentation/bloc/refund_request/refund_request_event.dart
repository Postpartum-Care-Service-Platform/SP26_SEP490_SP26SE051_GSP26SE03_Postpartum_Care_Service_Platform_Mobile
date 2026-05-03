import 'package:equatable/equatable.dart';

/// Refund Request Events
abstract class RefundRequestEvent extends Equatable {
  const RefundRequestEvent();

  @override
  List<Object?> get props => [];
}

/// Event to create a refund request
class RefundRequestCreateRequested extends RefundRequestEvent {
  final int bookingId;
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final String reason;

  const RefundRequestCreateRequested({
    required this.bookingId,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
    required this.reason,
  });

  @override
  List<Object?> get props => [
        bookingId,
        bankName,
        accountNumber,
        accountHolder,
        reason,
      ];
}

/// Event to create a refund request for home staff (withdraw)
class HomeStaffWithdrawRequested extends RefundRequestEvent {
  final int requestedAmount;
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final String reason;

  const HomeStaffWithdrawRequested({
    required this.requestedAmount,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
    required this.reason,
  });

  @override
  List<Object?> get props => [
        requestedAmount,
        bankName,
        accountNumber,
        accountHolder,
        reason,
      ];
}

/// Event to load my refund requests
class RefundRequestLoadMyRequests extends RefundRequestEvent {
  const RefundRequestLoadMyRequests();
}
