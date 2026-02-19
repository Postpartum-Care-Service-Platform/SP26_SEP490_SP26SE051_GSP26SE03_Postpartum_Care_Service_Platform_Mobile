import '../constants/app_strings.dart';

/// App Formatters - Centralized formatting utilities
class AppFormatters {
  AppFormatters._(); // Private constructor to prevent instantiation

  /// Get month name by index (1-12)
  static String getMonthName(int month) {
    switch (month) {
      case 1:
        return AppStrings.month1;
      case 2:
        return AppStrings.month2;
      case 3:
        return AppStrings.month3;
      case 4:
        return AppStrings.month4;
      case 5:
        return AppStrings.month5;
      case 6:
        return AppStrings.month6;
      case 7:
        return AppStrings.month7;
      case 8:
        return AppStrings.month8;
      case 9:
        return AppStrings.month9;
      case 10:
        return AppStrings.month10;
      case 11:
        return AppStrings.month11;
      case 12:
        return AppStrings.month12;
      default:
        return '';
    }
  }

  /// Get list of all month names
  static List<String> getMonthNames() {
    return [
      AppStrings.month1,
      AppStrings.month2,
      AppStrings.month3,
      AppStrings.month4,
      AppStrings.month5,
      AppStrings.month6,
      AppStrings.month7,
      AppStrings.month8,
      AppStrings.month9,
      AppStrings.month10,
      AppStrings.month11,
      AppStrings.month12,
    ];
  }

  /// Get week day abbreviation by index (0-6, where 0 is Monday)
  static String getWeekDayAbbreviation(int dayIndex) {
    switch (dayIndex) {
      case 0:
        return AppStrings.weekDayMonday;
      case 1:
        return AppStrings.weekDayTuesday;
      case 2:
        return AppStrings.weekDayWednesday;
      case 3:
        return AppStrings.weekDayThursday;
      case 4:
        return AppStrings.weekDayFriday;
      case 5:
        return AppStrings.weekDaySaturday;
      case 6:
        return AppStrings.weekDaySunday;
      default:
        return '';
    }
  }

  /// Get list of all week day abbreviations (Monday to Sunday)
  static List<String> getWeekDayAbbreviations() {
    return [
      AppStrings.weekDayMonday,
      AppStrings.weekDayTuesday,
      AppStrings.weekDayWednesday,
      AppStrings.weekDayThursday,
      AppStrings.weekDayFriday,
      AppStrings.weekDaySaturday,
      AppStrings.weekDaySunday,
    ];
  }

  /// Format price from string (extracts digits and formats in Vietnamese style)
  /// Examples: "1000000" -> "1 triệu", "500000" -> "500 ngàn"
  static String formatPriceFromString(String raw) {
    final matches = RegExp(r'\d+').allMatches(raw);
    final digits = matches.map((m) => m.group(0)!).join();
    if (digits.isEmpty) return raw;

    final value = int.tryParse(digits);
    if (value == null) return raw;

    final v = value;
    if (v <= 0) return '$v ${AppStrings.currencyUnit.trim()}';

    if (v >= 1000000000) {
      final billions = v ~/ 1000000000;
      final rem = v % 1000000000;
      if (rem == 0) return '$billions ${AppStrings.priceBillion}';
      final millions = rem ~/ 1000000;
      if (rem % 1000000 == 0 && millions > 0) {
        return '$billions ${AppStrings.priceBillion} $millions ${AppStrings.priceMillion}';
      }
      return '$billions ${AppStrings.priceBillion}';
    }

    if (v >= 1000000) {
      final millions = v ~/ 1000000;
      final rem = v % 1000000;
      if (rem == 0) return '$millions ${AppStrings.priceMillion}';

      if (rem % 100000 == 0) {
        final tenth = rem ~/ 100000;
        return '$millions ${AppStrings.priceMillion} $tenth';
      }
      return '$millions ${AppStrings.priceMillion}';
    }

    if (v >= 1000 && v % 1000 == 0) {
      final unit = v ~/ 1000;
      return '$unit ${AppStrings.priceThousand}';
    }

    if (v >= 100 && v % 100 == 0) {
      final unit = v ~/ 100;
      return '$unit ${AppStrings.priceHundred}';
    }

    return '$v ${AppStrings.currencyUnit.trim()}';
  }

  /// Format duration from string (extracts number of days)
  /// Examples: "30 d", "14d", "14 ngày" -> "30 ngày", "14 ngày"
  static String formatDurationFromString(String raw) {
    final match = RegExp(r'\d+').firstMatch(raw);
    if (match == null) return raw;
    final digits = match.group(0);
    if (digits == null) return raw;
    final v = int.tryParse(digits);
    if (v == null) return raw;
    return '$v ${AppStrings.durationDays}';
  }

  /// Format time from string (keeps time format like "07:00" or "09:00-10:30")
  /// Examples: "07:00" -> "07:00", "09:00-10:30" -> "09:00-10:30", "7:00" -> "07:00"
  static String formatTimeFromString(String raw) {
    final trimmed = raw.trim();
    // Nếu đã có format time (HH:mm hoặc HH:mm-HH:mm), normalize và giữ nguyên
    if (RegExp(r'^\d{1,2}:\d{2}(-\d{1,2}:\d{2})?$').hasMatch(trimmed)) {
      // Normalize single digit hours to two digits
      String result = trimmed;
      // Normalize start time
      result = result.replaceAllMapped(
        RegExp(r'^(\d{1}):(\d{2})'),
        (match) => '0${match.group(1)}:${match.group(2)}',
      );
      // Normalize end time if exists
      result = result.replaceAllMapped(
        RegExp(r'-(\d{1}):(\d{2})$'),
        (match) => '-0${match.group(1)}:${match.group(2)}',
      );
      return result;
    }
    // Nếu không phải format time, trả về nguyên bản (không format)
    return raw;
  }
}
