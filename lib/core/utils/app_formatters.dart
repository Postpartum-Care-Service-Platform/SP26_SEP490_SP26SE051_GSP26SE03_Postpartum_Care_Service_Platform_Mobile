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
}
