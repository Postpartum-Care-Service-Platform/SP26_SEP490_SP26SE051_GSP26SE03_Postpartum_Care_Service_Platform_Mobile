import 'package:equatable/equatable.dart';

class BookingConfigEntity extends Equatable {
  final double extraChildPricePercent;
  final double depositPercentage;

  const BookingConfigEntity({
    required this.extraChildPricePercent,
    required this.depositPercentage,
  });

  @override
  List<Object?> get props => [extraChildPricePercent, depositPercentage];
}
