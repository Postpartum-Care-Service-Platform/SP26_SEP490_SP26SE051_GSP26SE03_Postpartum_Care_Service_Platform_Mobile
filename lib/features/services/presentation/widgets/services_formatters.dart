import '../../../../core/constants/app_strings.dart';

String formatDateLocal(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String formatContractStatus(String status) {
  switch (status) {
    case 'Sent':
      return AppStrings.contractStatusWaitingForSignature;
    case 'Signed':
      return AppStrings.contractStatusSigned;
    default:
      return status;
  }
}

String formatPrice(double price) {
  final priceInt = price.toInt();
  final priceStr = priceInt.toString();

  final buffer = StringBuffer();
  final length = priceStr.length;

  for (int i = 0; i < length; i++) {
    if (i > 0 && (length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(priceStr[i]);
  }

  return buffer.toString() + AppStrings.currencyUnit;
}
