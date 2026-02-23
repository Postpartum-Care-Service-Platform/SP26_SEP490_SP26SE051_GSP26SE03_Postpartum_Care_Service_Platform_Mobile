/// Date Time Utilities
/// Helper functions for date and time operations
class AppDateTimeUtils {
  AppDateTimeUtils._();

  /// Vietnam timezone offset: UTC+7
  static const Duration vietnamTimeOffset = Duration(hours: 7);

  /// Parse ISO 8601 string and convert to Vietnam timezone (UTC+7)
  /// The input string should be in UTC format (ending with Z)
  static DateTime? parseToVietnamTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    try {
      // Parse as UTC DateTime
      final utcDateTime = DateTime.parse(isoString);
      
      // If it's already UTC (ends with Z or isUtc is true), convert to Vietnam time
      if (isoString.endsWith('Z') || utcDateTime.isUtc) {
        // Convert UTC to Vietnam timezone (UTC+7)
        return utcDateTime.add(vietnamTimeOffset);
      }
      
      // If it's not UTC, assume it's already in Vietnam time and return as is
      return utcDateTime;
    } catch (e) {
      return null;
    }
  }

  /// Format DateTime to Vietnamese format: "dd/MM/yyyy HH:mm"
  static String formatVietnamDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  /// Convert local DateTime (assumed to be UTC+7) to UTC
  /// This ensures that when we send time to server, it's correctly converted
  /// 
  /// Example: 
  /// - Input: DateTime(2026, 2, 21, 17, 0) represents 17:00 UTC+7 (user selection)
  /// - Output: DateTime.utc(2026, 2, 21, 10, 0) represents 10:00 UTC (sent to server)
  /// 
  /// Formula: UTC = UTC+7 - 7 hours
  static DateTime convertVietnamTimeToUtc(DateTime vietnamTime) {
    // Treat the input DateTime as UTC+7 time
    // Create a UTC DateTime with the same date/time components
    // Then subtract 7 hours to get the equivalent UTC time
    final utcDateTime = DateTime.utc(
      vietnamTime.year,
      vietnamTime.month,
      vietnamTime.day,
      vietnamTime.hour,
      vietnamTime.minute,
      vietnamTime.second,
      vietnamTime.millisecond,
      vietnamTime.microsecond,
    ).subtract(vietnamTimeOffset);
    
    return utcDateTime;
  }

  /// Format DateTime to ISO 8601 string with UTC timezone
  /// This is used when sending to API
  static String formatToUtcIso8601(DateTime vietnamTime) {
    return convertVietnamTimeToUtc(vietnamTime).toIso8601String();
  }
}
