import '../constants/app_strings.dart';

/// Time utilities for getting greetings based on Vietnam timezone (UTC+7)
class TimeUtils {
  TimeUtils._();

  /// Get current time in Vietnam timezone (UTC+7)
  static DateTime getVietnamTime() {
    final now = DateTime.now().toUtc();
    return now.add(const Duration(hours: 7));
  }

  /// Get greeting based on current time in Vietnam
  /// Returns appropriate greeting: morning, afternoon, evening, or night
  static String getGreeting() {
    final vietnamTime = getVietnamTime();
    final hour = vietnamTime.hour;

    // Morning: 5:00 - 11:59
    if (hour >= 0 && hour < 12) {
      return AppStrings.goodMorning;
    }
    // Afternoon: 12:00 - 17:59
    else if (hour >= 12 && hour < 18) {
      return AppStrings.goodAfternoon;
    }
    // Evening: 18:00 - 21:59
    else {
      return AppStrings.goodNight;
    }
  }
}
