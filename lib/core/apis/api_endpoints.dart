/// API Endpoints
/// Centralized location for all API routes
class ApiEndpoints {
  ApiEndpoints._();

  // Chat endpoints
  static const String chatConversations = '/Chat/conversations';
  static const String chatConversationsAll =
      '/Chat/conversations/all'; // Staff: Xem tất cả conversations
  static String chatConversationById(int id) => '/Chat/conversations/$id';
  static String chatConversationMessages(int id) =>
      '/Chat/conversations/$id/messages';
  static String chatConversationStaffMessage(int id) =>
      '/Chat/conversations/$id/staff-message';
  static String chatConversationMarkRead(int id) =>
      '/Chat/conversations/$id/messages/read';
  static String chatConversationRequestSupport(int id) =>
      '/Chat/conversations/$id/request-support';

  // Chat endpoints - Staff Support Requests
  static const String chatSupportRequests =
      '/Chat/support-requests'; // Staff: Lấy yêu cầu hỗ trợ đang chờ
  static const String chatSupportRequestsMy =
      '/Chat/support-requests/my'; // Staff: Lấy yêu cầu đang xử lý
  static String chatSupportRequestAccept(int id) =>
      '/Chat/support-requests/$id/accept'; // Staff: Nhận yêu cầu
  static String chatSupportRequestResolve(int id) =>
      '/Chat/support-requests/$id/resolve'; // Staff: Đánh dấu đã xử lý

  // Auth endpoints
  static const String login = '/Auth/login';
  static const String register = '/Auth/register';
  static const String verifyEmail = '/Auth/verify-email';
  static const String logout = '/Auth/logout';
  static const String changePassword = '/Auth/change-password';
  static const String refreshToken = '/Auth/refresh-token';
  static const String forgotPassword = '/Auth/forgot-password';
  static const String verifyResetOtp = '/Auth/verify-reset-otp';
  static const String resetPassword = '/Auth/reset-password';
  static const String resendOtp = '/Auth/resend-otp';
  static const String googleSignIn = '/Auth/google';
  static const String createCustomer = '/Auth/create-customer';

  // Account endpoints
  static const String getCurrentAccount = '/Account/GetCurrentAccount';
  static const String getAllAccounts = '/Account/GetAll';
  static String getAccountById(String id) => '/Account/GetById/$id';

  // User endpoints (legacy / placeholder)
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';

  // Home endpoints
  static const String home = '/home';
  static const String dashboard = '/dashboard';

  // Services endpoints
  static const String services = '/services';
  static String serviceById(String id) => '/services/$id';
  static const String serviceCategories = '/services/categories';

  // Schedule endpoints
  static const String schedules = '/schedules';
  static String scheduleById(String id) => '/schedules/$id';
  static const String mySchedules = '/schedules/my';
  static const String createSchedule = '/schedules';
  static String updateSchedule(String id) => '/schedules/$id';
  static String deleteSchedule(String id) => '/schedules/$id';

  // Appointment endpoints
  static const String appointments = '/Appointment';
  static String appointmentById(int id) => '/Appointment/$id';
  static String cancelAppointment(int id) => '/Appointment/$id/cancel';
  static const String appointmentTypes = '/AppointmentType';

  // Notification endpoints
  static const String notificationsMe = '/Notification/me';
  static String markNotificationAsRead(int id) =>
      '/Notification/mark-as-read/$id';
  static String getNotificationById(int id) => '/Notification/$id';

  // Profile endpoints
  static const String userProfile = '/profile';
  static const String updateUserProfile = '/profile';

  // Family Profile endpoints
  static const String getMyFamilyProfiles =
      '/FamilyProfile/GetMyFamilyProfiles';
  static const String createFamilyProfile = '/FamilyProfile/Create';
  static String updateFamilyProfile(int id) => '/FamilyProfile/Update/$id';
  static String getFamilyProfilesByCustomerId(String customerId) =>
      '/FamilyProfile/GetByCustomerId/$customerId';
  static const String getMemberTypes = '/member-types';

  // Package endpoints
  static const String packages = '/Packages/center';
  static const String packageTypes = '/PackageType';

  // Care Plan endpoints
  static String getCarePlanDetailsByPackage(int packageId) =>
      '/care-plan-details/by-package/$packageId';

  // Booking endpoints
  static const String createBooking = '/Booking';
  static const String createBookingForCustomer = '/Booking/create-for-customer';
  static String getBookingById(int id) => '/Booking/$id';
  static const String getBookings = '/Booking';
  static const String getAllBookings = '/Booking/all';
  static String confirmBooking(int id) => '/Booking/$id/confirm';
  static String completeBooking(int id) => '/Booking/$id/complete';
  static const String createPaymentLink = '/Transaction/create-payment-link';
  static const String createOfflinePayment = '/Transaction/payment';
  static const String getAllTransactions = '/Transaction/all';
  static String checkPaymentStatus(String orderCode) =>
      '/Transaction/check-status/$orderCode';

  // Contract endpoints
  static String getContractByBookingId(int bookingId) =>
      '/Contract/my/$bookingId';
  static String exportContractPdf(int contractId) =>
      '/Contract/$contractId/export-pdf';

  // ==========================================
  // Employee - Appointment endpoints
  // ==========================================

  /// Get appointments assigned to current staff
  static const String myAssignedAppointments = '/Appointment/my-assigned';

  /// Get all appointments (for staff/admin)
  static const String allAppointments = '/Appointment/all';

  /// Confirm appointment (staff confirms)
  static String confirmAppointment(int id) => '/Appointment/$id/confirm';

  /// Complete appointment (mark as completed)
  static String completeAppointment(int id) => '/Appointment/$id/complete';

  /// Create appointment for customer (staff creates)
  static const String createAppointmentForCustomer =
      '/Appointment/create-for-customer';

  // ==========================================
  // Employee - StaffSchedule endpoints
  // ==========================================

  static const String myStaffSchedules = '/StaffSchedule/me';
  static const String checkStaffSchedule = '/StaffSchedule/check';
  static const String swapStaffSchedule = '/StaffSchedule/swap-schedule';
  static const String mySwapRequests = '/StaffSchedule/my-swap-requests';
  static const String myIncomingSwapRequests =
      '/StaffSchedule/my-incoming-swap-requests';
  static String respondSwapRequest(int requestId, bool respond) =>
      '/StaffSchedule/respond-swap-request/$requestId/$respond';

  // ==========================================
  // Employee - Room endpoints
  // ==========================================

  /// Get all rooms
  static const String rooms = '/Room';

  /// Get room by ID
  static String roomById(int id) => '/Room/$id';

  // ==========================================
  // Employee - AmenityService endpoints
  // ==========================================

  /// Get all amenity services
  static const String amenityServices = '/AmenityService';

  // ==========================================
  // Customer - Amenity Ticket endpoints
  // ==========================================

  /// Get my amenity tickets
  static const String myAmenityTickets = '/AmenityTicket/my-tickets';

  /// Create amenity ticket
  static const String createAmenityTicket = '/AmenityTicket';

  // ==========================================
  // Employee - Service Booking endpoints (TODO: Chờ BE API)
  // ==========================================

  /// Create service booking
  static const String createServiceBooking = '/ServiceBooking';

  /// Get tickets by customer
  static String getTicketsByCustomer(String customerId) =>
      '/ServiceBooking/customer/$customerId';

  /// Get my assigned tickets
  static const String myAssignedTickets = '/ServiceBooking/my-assigned';

  /// Get all tickets
  static const String allTickets = '/ServiceBooking/all';

  /// Cancel ticket
  static String cancelTicket(int ticketId) =>
      '/ServiceBooking/$ticketId/cancel';

  /// Confirm ticket
  static String confirmTicket(int ticketId) =>
      '/ServiceBooking/$ticketId/confirm';

  /// Complete ticket
  static String completeTicket(int ticketId) =>
      '/ServiceBooking/$ticketId/complete';

  // ==========================================
  // Menu endpoints
  // ==========================================

  /// Get all menus
  static const String menus = '/Menu';

  /// Get all menu types
  static const String menuTypes = '/MenuType';

  /// Get my menu records
  static const String myMenuRecords = '/MenuRecord/my';

  /// Get my menu records by date
  static const String myMenuRecordsByDate = '/MenuRecord/my/date';

  /// Create menu records
  static const String createMenuRecord = '/MenuRecord';

  /// Update menu records
  static const String updateMenuRecord = '/MenuRecord';

  /// Delete menu record (soft delete)
  static String deleteMenuRecord(int id) => '/MenuRecord/$id';

  // ==========================================
  // Family Schedule endpoints
  // ==========================================

  /// Get my family schedules
  static const String familyScheduleMySchedules =
      '/FamilySchedule/my-schedules';

  /// Get my family schedules by date
  static String familyScheduleByDate(String date) => '/FamilySchedule/$date';

  // ==========================================
  // Feedback endpoints
  // ==========================================

  /// Get feedback types
  static const String feedbackTypes = '/FeedbackType';

  /// Get my feedbacks
  static const String myFeedbacks = '/Feedback/my-feedback';

  /// Create feedback
  static const String createFeedback = '/Feedback';
}
