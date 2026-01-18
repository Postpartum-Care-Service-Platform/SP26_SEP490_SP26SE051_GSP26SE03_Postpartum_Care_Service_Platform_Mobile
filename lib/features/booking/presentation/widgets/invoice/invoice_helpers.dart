import '../../../../../core/constants/app_strings.dart';

class InvoiceHelpers {
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
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String getTransactionTypeLabel(String type) {
    switch (type) {
      case 'Deposit':
        return AppStrings.transactionTypeDeposit;
      case 'Remaining':
        return AppStrings.transactionTypeRemaining;
      default:
        return type;
    }
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

  static String getTransactionStatusLabel(String status) {
    switch (status) {
      case 'Paid':
        return 'Đã thanh toán';
      case 'Pending':
        return 'Đang chờ';
      case 'Failed':
        return 'Thất bại';
      default:
        return status;
    }
  }

  static String getContractStatusLabel(String status) {
    switch (status) {
      case 'Draft':
        return 'Bản nháp';
      case 'Signed':
        return 'Đã ký';
      case 'Sent':
        return 'Đã gửi';
      default:
        return status;
    }
  }
}
