/// App Enums - Centralized enums for the application
/// Helps avoid hardcoded strings and provides type safety

/// Booking status types
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
