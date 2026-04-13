import 'dart:convert';

/// A utility class for parsing VietQR (EMVCo) strings.
class VietQrParser {
  VietQrParser._();

  static Map<String, dynamic> parse(String qrData) {
    Map<String, dynamic> result = {};
    int index = 0;
    try {
      while (index < qrData.length) {
        if (index + 4 > qrData.length) break;
        String tag = qrData.substring(index, index + 2);
        int length = int.parse(qrData.substring(index + 2, index + 4));
        index += 4;
        if (index + length > qrData.length) break;
        String value = qrData.substring(index, index + length);
        index += length;
        if (tag == '38' || tag == '26' || tag == '62') {
          result[tag] = _parseNested(value);
        } else {
          result[tag] = value;
        }
      }
    } catch (e) {}
    return result;
  }

  static Map<String, dynamic> _parseNested(String nestedData) {
    Map<String, dynamic> result = {};
    int index = 0;
    try {
      while (index < nestedData.length) {
        if (index + 4 > nestedData.length) break;
        String tag = nestedData.substring(index, index + 2);
        int length = int.parse(nestedData.substring(index + 2, index + 4));
        index += 4;
        if (index + length > nestedData.length) break;
        String value = nestedData.substring(index, index + length);
        index += length;
        result[tag] = value;
      }
    } catch (e) {}
    return result;
  }

  static Map<String, String>? getRecipientInfo(Map<String, dynamic> parsedData) {
    final merchantInfo = parsedData['38'];
    if (merchantInfo is Map<String, dynamic>) {
      final paymentNetwork = merchantInfo['01'];
      if (paymentNetwork is String) {
        final details = _parseNested(paymentNetwork);
        return {'bin': details['00'] ?? '', 'account': details['01'] ?? ''};
      }
    }
    return null;
  }

  static String? getBeneficiaryName(Map<String, dynamic> parsedData) {
    return parsedData['59'];
  }

  static String? getDescription(Map<String, dynamic> parsedData) {
    final additionalData = parsedData['62'];
    if (additionalData is Map<String, dynamic>) {
      return additionalData['08'];
    }
    return null;
  }
}
