import '../../../../../core/constants/app_strings.dart';

class PaymentHelpers {
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
}
