import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';

class BookingHistoryHelpers {
  static String formatPrice(double price) {
    final priceInt = price.toInt();
    final priceStr = priceInt.toString();
    
    // Format with thousand separators (dots) from left to right
    if (priceStr.length <= 3) {
      return priceStr + AppStrings.currencyUnit;
    }
    
    final buffer = StringBuffer();
    final length = priceStr.length;
    
    // Process from left to right
    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(priceStr[i]);
    }
    
    return buffer.toString() + AppStrings.currencyUnit;
  }

  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String getStatusLabel(String status) {
    switch (status) {
      case 'Confirmed':
        return 'Đã xác nhận';
      case 'Pending':
        return 'Đang chờ';
      case 'Cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return AppColors.verified;
      case 'Pending':
        return AppColors.primary;
      case 'Cancelled':
        return AppColors.red;
      default:
        return AppColors.textSecondary;
    }
  }
}
