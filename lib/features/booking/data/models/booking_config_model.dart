import '../../domain/entities/booking_config_entity.dart';

class BookingConfigModel extends BookingConfigEntity {
  const BookingConfigModel({
    required super.extraChildPricePercent,
    required super.depositPercentage,
  });

  factory BookingConfigModel.fromJson(Map<String, dynamic> json) {
    return BookingConfigModel(
      extraChildPricePercent: (json['extraChildPricePercent'] as num).toDouble(),
      depositPercentage: (json['depositPercentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'extraChildPricePercent': extraChildPricePercent,
      'depositPercentage': depositPercentage,
    };
  }
}
