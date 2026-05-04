/// App Enums - Centralized enums for the application.
/// Helps avoid hardcoded strings and provides type safety.
enum BookingStatus {
  draft,
  confirmed,
  inProgress,
  completed,
  pendingCustomerConfirm,
  cancelled,
  unknown;

  static BookingStatus fromString(String value) {
    switch (value.toLowerCase().trim().replaceAll('_', '').replaceAll(' ', '')) {
      case 'draft':
        return BookingStatus.draft;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'inprogress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'pendingcustomerconfirm':
        return BookingStatus.pendingCustomerConfirm;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.unknown;
    }
  }
}

/// Contract status types
enum ContractStatus {
  draft,
  sent,
  signed,
  waitingForSignature,
  scheduleCompleted,
  unknown;

  static ContractStatus fromString(String value) {
    switch (value.toLowerCase().trim().replaceAll('_', '').replaceAll(' ', '')) {
      case 'draft':
        return ContractStatus.draft;
      case 'sent':
        return ContractStatus.sent;
      case 'signed':
        return ContractStatus.signed;
      case 'waitingforsignature':
        return ContractStatus.waitingForSignature;
      case 'schedulecompleted':
        return ContractStatus.scheduleCompleted;
      default:
        return ContractStatus.unknown;
    }
  }
}

/// Service location type
enum ServiceLocationType {
  home,
  center,
  unknown;

  static ServiceLocationType fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'home':
        return ServiceLocationType.home;
      case 'center':
        return ServiceLocationType.center;
      default:
        return ServiceLocationType.unknown;
    }
  }
}

/// Meal slot types for menu management
enum MealSlot {
  snackMorning,
  snackAfternoon,
  snackNight,
  morning,
  lunch,
  dinner,
  unknown;

  /// Infers the meal slot from a given text (e.g., menu type name or record name)
  static MealSlot fromText(String text) {
    final lower = text.toLowerCase();
    
    // Check for snacks first as they are more specific
    if (lower.contains('phụ')) {
      if (lower.contains('sáng')) return MealSlot.snackMorning;
      if (lower.contains('chiều')) return MealSlot.snackAfternoon;
      if (lower.contains('tối')) return MealSlot.snackNight;
    }
    
    // Main meals
    if (lower.contains('sáng')) return MealSlot.morning;
    if (lower.contains('trưa')) return MealSlot.lunch;
    if (lower.contains('chiều') || lower.contains('tối')) return MealSlot.dinner;
    
    return MealSlot.unknown;
  }

  /// Returns the string representation used by the backend API
  String toApiValue() {
    switch (this) {
      case MealSlot.snackMorning:
        return 'snack_morning';
      case MealSlot.snackAfternoon:
        return 'snack_afternoon';
      case MealSlot.snackNight:
        return 'snack_night';
      case MealSlot.morning:
        return 'morning';
      case MealSlot.lunch:
        return 'lunch';
      case MealSlot.dinner:
        return 'dinner';
      case MealSlot.unknown:
        return 'unknown';
    }
  }
}
