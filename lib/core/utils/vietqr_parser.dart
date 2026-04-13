import 'dart:convert';

/// A utility class for parsing VietQR (EMVCo) strings.
/// Supports extracting bank information, account number, beneficiary name, and description.
class VietQrParser {
  VietQrParser._();

  /// Parses a VietQR (EMVCo) string and returns a map of extracted tags.
  /// Nested tags (like Tag 38) are also parsed into maps.
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

        // Recursive parsing for composite tags (e.g., Tag 38, Tag 62)
        if (tag == '38' || tag == '26' || tag == '62') {
          result[tag] = _parseNested(value);
        } else {
          result[tag] = value;
        }
      }
    } catch (e) {
      // Return partial result if parsing fails
    }

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
    } catch (e) {
      // Return partial result if parsing fails
    }

    return result;
  }

  /// Extracts the Bank BIN (6 digits) and Account Number from the parsed QR data.
  static Map<String, String>? getRecipientInfo(Map<String, dynamic> parsedData) {
    // Tag 38 is the standard for Napas247 (VietQR)
    final merchantInfo = parsedData['38'];
    if (merchantInfo is Map<String, dynamic>) {
      final paymentNetwork = merchantInfo['01'];
      if (paymentNetwork is String) {
        // Tag 01 is composite for Napas
        final details = _parseNested(paymentNetwork);
        return {
          'bin': details['00'] ?? '',
          'account': details['01'] ?? '',
        };
      }
    }
    return null;
  }

  /// Extracts the beneficiary name (Tag 59).
  static String? getBeneficiaryName(Map<String, dynamic> parsedData) {
    return parsedData['59'];
  }

  /// Extracts the transaction description (Tag 62 -> Subtag 08).
  static String? getDescription(Map<String, dynamic> parsedData) {
    final additionalData = parsedData['62'];
    if (additionalData is Map<String, dynamic>) {
      return additionalData['08'];
    }
    // Fallback to Tag 62 direct value if it's not a template (rare in VietQR but possible in EMVCo)
    if (additionalData is String) return additionalData;
    return null;
  }

  /// Extracts the amount (Tag 54) if present in the QR code.
  static double? getAmount(Map<String, dynamic> parsedData) {
    final amountStr = parsedData['54'];
    if (amountStr is String) {
      return double.tryParse(amountStr);
    }
    return null;
  }
}
