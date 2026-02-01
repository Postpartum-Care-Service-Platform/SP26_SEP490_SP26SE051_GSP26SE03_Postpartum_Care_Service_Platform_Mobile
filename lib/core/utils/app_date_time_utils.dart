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
}
