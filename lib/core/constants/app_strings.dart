/// App Strings - Centralized string constants for the application
/// Following clean architecture principles for code reusability
class AppStrings {
  AppStrings._(); // Private constructor to prevent instantiation

  // App Name
  static const String appName = 'The Joyful Nest';

  // Login Screen
  static const String signInTitle = 'Sign In to The Joyful Nest';
  static const String signIn = 'Sign in';
  static const String signUp = 'Sign up';
  static const String google = 'Google';
  static const String or = 'or';

  // Form Labels
  static const String email = 'Email';
  static const String password = 'Password';
  static const String username = 'Username';
  static const String phone = 'Phone';

  // Placeholders
  static const String emailPlaceholder = 'your@email.com';
  static const String passwordPlaceholder = 'password';
  static const String usernamePlaceholder = 'Enter your username';
  static const String phonePlaceholder = 'Enter your phone number';

  // Reset Password Screen
  static const String resetYourPassword = 'Reset Your Password';
  static const String resetPasswordDescription =
      "Enter your email address and we'll send you a password reset link.";
  static const String resetPassword = 'Reset Password';
  static const String rememberYourPassword = 'Remember your password?';

  // Sign Up Screen
  static const String signUpTitle = 'Create your account';
  static const String signUpDescription =
      'Enter your details below to create a new account.';
  static const String fullName = 'Full name';
  static const String confirmPassword = 'Confirm password';
  static const String fullNamePlaceholder = 'Your name';
  static const String confirmPasswordPlaceholder = 'Re-enter your password';
  static const String alreadyHaveAccount = 'Already have an account?';

  // Splash Screen
  static const String tagline = 'Tổ ấm hạnh phúc của bạn.';
  static const String loading = 'Loading...';
  static const String processing = 'Đang xử lý...';
  static const String deleting = 'Đang xóa...';

  // Links
  static const String needAnAccount = 'Need an account?';
  static const String forgotPassword = 'Forgot your password?';
  static const String resetIt = 'Reset it';
  static const String send = 'Gửi';

  // Home Screen
  static const String goodMorning = 'Chào buổi sáng';
  static const String goodAfternoon = 'Chào buổi trưa';
  static const String goodEvening = 'Chào buổi chiều';
  static const String goodNight = 'Chào buổi tối';
  static const String quickActions = 'Lối tắt';
  static const String upcomingSchedule = 'Lịch trình sắp tới';
  static const String promotions = 'Ưu đãi & Gói dịch vụ';
  static const String viewAll = 'Xem tất cả';

  // Quick Actions
  static const String spaAndCare = 'Spa & Chăm sóc';
  static const String babyActivities = 'Hoạt động cho bé';
  static const String nutritionMenu = 'Thực đơn & Dinh dưỡng';
  static const String resortMap = 'Bản đồ Resort';

  //Error Input
  static const String errorInputEmail = 'Please enter your email or username';
  static const String errorInputPassword = 'Please enter your password';
  static const String errorInputUsername = 'Please enter your username';
  static const String errorInputPhone = 'Please enter your phone number';
  static const String errorInputEmailRequired = 'Please enter your email';
  static const String errorInputEmailInvalid = 'Please enter a valid email';
  static const String errorInputPasswordRequired = 'Please enter your password';
  static const String errorInputPasswordMinLength =
      'Password must be at least 6 characters';
  static const String errorInputConfirmPassword =
      'Please confirm your password';
  static const String errorInputPasswordsNotMatch = 'Passwords do not match';
  static const String errorFillAllFields = 'Please fill in all fields';
  static const String errorOtpInvalid = 'Please enter a valid 6-digit OTP';

  //Toast Message
  static const String successLogin = 'Đăng nhập thành công';
  static const String errorLogin = 'Đăng nhập thất bại';
  static const String successRegister = 'Đăng ký thành công';
  static const String errorRegister = 'Đăng ký thất bại';
  static const String successLogout = 'Đăng xuất thành công';
  static const String errorLogout = 'Đăng xuất thất bại';
  static const String successUpdateProfile = 'Cập nhật thông tin thành công';
  static const String errorUpdateProfile = 'Cập nhật thông tin thất bại';
  static const String successVerifyEmail = 'Xác thực email thành công';
  static const String errorVerifyEmail = 'Xác thực email thất bại';
  static const String successResetPassword = 'Reset link sent!';

  // OTP Verification Screen
  static const String otpVerificationTitle = 'Xác thực Email';
  static const String otpVerificationDescription =
      'Nhập mã OTP đã được gửi đến';
  static const String otpVerificationButton = 'Xác thực';
  static const String resendOtp = 'Gửi lại OTP';
  static const String resendOtpCountdown = 'Gửi lại OTP sau {seconds}s';

  // Profile Screen
  static const String profileTitle = 'Profile';
  static const String profileScreen = 'Profile Screen';
  static const String welcomeBack = 'Welcome Back';
  static const String logoutTitle = 'Đăng xuất';
  static const String logoutConfirmation = 'Bạn có chắc chắn muốn đăng xuất?';
  static const String cancel = 'Hủy';
  static const String logout = 'Đăng xuất';

  // Profile Menu Items
  static const String myAccount = 'Tài khoản của tôi';
  static const String familyProfile = 'Hồ sơ gia đình';
  static const String notifications = 'Thông báo';
  static const String medicalRecords = 'Hồ sơ y tế';

  // Family Profile Screen
  static const String familyProfileTitle = 'Hồ sơ gia đình';
  static const String addFamilyMember = 'Thêm thành viên';
  static const String editFamilyMember = 'Chỉnh sửa';
  static const String deleteFamilyMember = 'Xóa';
  static const String owner = 'Chủ tài khoản';
  static const String account = 'Tài khoản';
  static const String member = 'Thành viên';
  static const String noFamilyMembers = 'Chưa có thành viên nào';
  static const String addFirstMember = 'Thêm thành viên đầu tiên';
  static const String add = 'Thêm';
  static const String save = 'Lưu';
  static const String profileFullName = 'Họ và tên';
  static const String profileFullNamePlaceholder = 'Nhập họ và tên';
  static const String memberType = 'Mối quan hệ';
  static const String selectMemberType = 'Chọn mối quan hệ';
  static const String dateOfBirth = 'Ngày sinh';
  static const String selectDate = 'Chọn ngày sinh';
  static const String gender = 'Giới tính';
  static const String selectGender = 'Chọn giới tính';
  static const String male = 'Nam';
  static const String female = 'Nữ';
  static const String address = 'Địa chỉ';
  static const String addressPlaceholder = 'Nhập địa chỉ';
  static const String phoneNumber = 'Số điện thoại';
  static const String phoneNumberPlaceholder = 'Nhập số điện thoại';
  static const String avatar = 'Ảnh đại diện';
  static const String selectAvatar = 'Chọn ảnh';
  static const String changeAvatar = 'Đổi ảnh';
  static const String updateSuccess = 'Cập nhật thành công';
  static const String updateFailed = 'Cập nhật thất bại';
  static const String updating = 'Đang cập nhật...';
  static const String confirmDelete = 'Xác nhận xóa';
  static const String confirmDeleteMessage =
      'Bạn có chắc chắn muốn xóa {name}?';
  static const String delete = 'Xóa';
  static const String featureUnderDevelopment =
      'Tính năng đang được phát triển';
  static const String addMemberFeatureUnderDevelopment =
      'Tính năng thêm thành viên đang được phát triển';
  static const String deleteFeatureUnderDevelopment =
      'Tính năng xóa đang được phát triển';
  static const String edit = 'Chỉnh sửa';
  static const String takePhoto = 'Chụp ảnh';
  static const String chooseFromLibrary = 'Chọn từ thư viện';
  static const String pleaseEnterFullName = 'Vui lòng nhập họ và tên';
  static const String invalidPhoneNumber = 'Số điện thoại không hợp lệ';
  static const String pleaseGrantPhotoPermission =
      'Vui lòng cấp quyền truy cập ảnh trong phần Cài đặt ứng dụng.';
  static const String photoPermissionDenied = 'Quyền truy cập ảnh bị từ chối.';
  static const String pleaseGrantCameraPermission =
      'Vui lòng cấp quyền sử dụng camera trong phần Cài đặt ứng dụng.';
  static const String cameraPermissionDenied =
      'Quyền sử dụng camera bị từ chối.';
  static const String cannotOpenPhotoLibrary =
      'Không thể mở thư viện ảnh. Vui lòng kiểm tra quyền truy cập (error: {code})';
  static const String errorSelectingPhoto =
      'Đã xảy ra lỗi khi chọn ảnh: {error}';
  static const String viewMode = 'Đang xem';
  static const String editMode = 'Đang chỉnh sửa';
  static const String contract = 'Hợp đồng';
  static const String bookingHistory = 'Lịch sử đặt lịch';
  static const String paymentMethods = 'Phương thức thanh toán';
  static const String help = 'Trợ giúp';
  static const String contact = 'Liên hệ';
  static const String about = 'Về chúng tôi';
  static const String terms = 'Điều khoản';
  static const String privacy = 'Chính sách bảo mật';

  // Other Screens
  static const String servicesScreen = 'Services Screen';
  static const String scheduleScreen = 'Schedule Screen';
  static const String chatScreen = 'Chat Screen';
  static const String chatTitle = 'Tư vấn & Chat AI';
  static const String chatSubtitle =
      'Trao đổi nhanh với trợ lý AI hoặc yêu cầu nhân viên hỗ trợ';
  static const String chatNewConversation = 'Cuộc trò chuyện mới';
  static const String chatNewConversationPlaceholder = 'Nhập tên chủ đề...';
  static const String chatSendPlaceholder = 'Nhập tin nhắn...';
  static const String chatRequestSupport = 'Yêu cầu nhân viên hỗ trợ';
  static const String chatRequestSupportReason = 'Bạn cần nhân viên hỗ trợ gì?';
  static const String chatRequestSupportSuccess =
      'Đã gửi yêu cầu hỗ trợ tới nhân viên';
  static const String chatEmptyMessage =
      'Bắt đầu trò chuyện để nhận tư vấn từ AI';
  static const String chatNoConversation = 'Chưa có cuộc trò chuyện';
  static const String chatLoadError =
      'Không thể tải cuộc trò chuyện. Vui lòng thử lại.';
  static const String chatTypingHint =
      'AI đang sẵn sàng hỗ trợ mẹ và bé sau sinh';
  static const String chatSearchHint = 'Tìm kiếm cuộc trò chuyện...';
  static const String chatAiTypingStatus = 'AI đang trả lời';
  static const String chatAiAssistantTitle = 'Trợ lý AI';
  static const String chatAiIntroLine1 =
      'Dùng mô hình AI để tư vấn chăm sóc mẹ & bé.';
  static const String chatAiIntroLine2 =
      'Một số câu trả lời có thể chưa hoàn hảo. Vui lòng kiểm tra lại thông tin quan trọng.';
  static const String chatInputHintShort = 'Aa';
  static const String chatMessengerLabel = 'Messenger';

  // Bottom Navigation Bar
  static const String bottomNavHome = 'Home';
  static const String bottomNavServices = 'Dịch vụ';
  static const String bottomNavSchedule = 'Lịch hẹn';
  static const String bottomNavChat = 'Tư vấn';
  static const String bottomNavProfile = 'Tôi';

  // Error Messages
  static const String errorLoginFailed = 'Login failed';

  // Account Details Screen
  static const String accountDetailsTitle = 'Thông tin chi tiết';
  static const String accountPhoneNumber = 'Số điện thoại';
  static const String accountStatus = 'Trạng thái';
  static const String accountStatusActive = 'Đang hoạt động';
  static const String accountStatusLocked = 'Bị khóa';
  static const String accountCreatedAt = 'Ngày tạo';
  static const String accountUpdatedAt = 'Cập nhật lần cuối';
  static const String accountSecurityTitle = 'Bảo mật & mật khẩu';
  static const String changePasswordTitle = 'Đổi mật khẩu';
  static const String changePasswordDescription =
      'Để bảo mật tài khoản, vui lòng sử dụng mật khẩu đủ mạnh và không chia sẻ cho người khác.';
  static const String currentPassword = 'Mật khẩu hiện tại';
  static const String currentPasswordPlaceholder = 'Nhập mật khẩu hiện tại';
  static const String saveNewPassword = 'Lưu mật khẩu mới';
  static const String retry = 'Thử lại';
  static const String noAccountData = 'Không có dữ liệu tài khoản.';

  // Notification Screen
  static const String notificationTitle = 'Notification';
  static const String latestNotification = 'Latest notification';
  static const String sortBy = 'Sort By';
  static const String noNotifications = 'Không có thông báo nào';
  static const String minutesAgo = '{minutes} phút trước';
  static const String hoursAgo = '{hours} giờ trước';
  static const String daysAgo = '{days} ngày trước';
  static const String justNow = 'Vừa xong';
  static const String notificationDetail = 'Chi tiết thông báo';
  static const String notificationContent = 'Nội dung';
  static const String notificationCreatedAt = 'Ngày tạo';
  static const String notificationUpdatedAt = 'Cập nhật lần cuối';
  static const String notificationStatus = 'Trạng thái';
  static const String notificationStatusRead = 'Đã đọc';
  static const String notificationStatusUnread = 'Chưa đọc';

  // Package Screen
  static const String noPackages = 'Chưa có gói dịch vụ nào';
  static const String loadPackagesError = 'Không thể tải gói dịch vụ';
  static const String days = 'ngày';
  static const String currencyUnit = ' đ';

  // Care Plan Screen
  static const String carePlanTitle = 'Lịch trình nghỉ dưỡng';
  static const String noCarePlanDetails =
      'Gói dịch vụ này chưa có lịch trình nghỉ dưỡng';
  static const String day = 'Ngày';
  static const String activity = 'Hoạt động';
  static const String time = 'Thời gian';
  static const String instruction = 'Hướng dẫn';
  static const String loadCarePlanError = 'Không thể tải lịch trình nghỉ dưỡng';

  // Appointment Screen
  static const String appointmentTitle = 'Lịch hẹn';
  static const String noAppointments = 'Chưa có lịch hẹn nào';
  static const String createAppointment = 'Đặt lịch hẹn';
  static const String bookAppointment = 'Đặt lịch';
  static const String editAppointment = 'Chỉnh sửa lịch hẹn';
  static const String cancelAppointment = 'Hủy lịch hẹn';
  static const String appointmentName = 'Tên lịch hẹn';
  static const String appointmentNamePlaceholder = 'Nhập tên lịch hẹn';
  static const String appointmentDate = 'Ngày hẹn';
  static const String selectAppointmentDate = 'Chọn ngày';
  static const String appointmentTime = 'Giờ hẹn';
  static const String selectAppointmentTime = 'Chọn giờ';
  static const String appointmentType = 'Loại lịch hẹn';
  static const String selectAppointmentType = 'Chọn loại lịch hẹn';
  static const String pleaseSelectAppointmentType =
      'Vui lòng chọn loại lịch hẹn';
  static const String appointmentLocation = 'Địa điểm';
  static const String appointmentLocationName = 'The Joyful Nest';
  static const String appointmentLocationAddress =
      '1056A Đường Nguyễn Văn Linh, Tân Phong, Quận 7, Thành phố Hồ Chí Minh 700000, Việt Nam';
  static const String appointmentStatus = 'Trạng thái';
  static const String staff = 'Nhân viên';
  static const String noStaffAssigned = 'Chưa có nhân viên';
  static const String confirmCancel = 'Xác nhận hủy';
  static const String confirmCancelMessage =
      'Bạn có chắc chắn muốn hủy lịch hẹn này?';
  static const String loadAppointmentsError =
      'Không thể tải danh sách lịch hẹn';
  static const String createAppointmentError = 'Không thể tạo lịch hẹn';
  static const String updateAppointmentError = 'Không thể cập nhật lịch hẹn';
  static const String cancelAppointmentError = 'Không thể hủy lịch hẹn';
  static const String createAppointmentSuccess = 'Tạo lịch hẹn thành công';
  static const String updateAppointmentSuccess = 'Cập nhật lịch hẹn thành công';
  static const String cancelAppointmentSuccess = 'Hủy lịch hẹn thành công';
  static const String pleaseEnterAppointmentName = 'Vui lòng nhập tên lịch hẹn';
  static const String pleaseSelectDate = 'Vui lòng chọn ngày';
  static const String pleaseSelectTime = 'Vui lòng chọn giờ';

  // Appointment Status
  static const String statusScheduled = 'Đã lên lịch';
  static const String statusRescheduled = 'Đã đổi lịch';
  static const String statusCompleted = 'Hoàn thành';
  static const String statusPending = 'Đang chờ';
  static const String statusCancelled = 'Đã hủy';

  // Appointment Filter
  static const String filterAll = 'Tất cả';
  static const String filterUpcoming = 'Lịch sắp tới';
  static const String filterCompleted = 'Đã hoàn thành';
  static const String filterCancelled = 'Đã hủy';

  // Booking Screen
  static const String bookingTitle = 'Đặt gói dịch vụ';
  static const String bookingStep1 = 'Gói';
  static const String bookingStep2 = 'Phòng';
  static const String bookingStep3 = 'Ngày';
  static const String bookingStep4 = 'Xác nhận';
  static const String bookingNext = 'Tiếp theo';
  static const String bookingPrevious = 'Quay lại';
  static const String bookingConfirm = 'Xác nhận đặt phòng';
  static const String bookingSelectPackage = 'Gói';
  static const String bookingSelectRoom = 'Phòng';
  static const String bookingSelectDate = 'Ngày';
  static const String bookingSummary = 'Tóm tắt đặt phòng';
  static const String bookingPackage = 'Gói dịch vụ';
  static const String bookingRoom = 'Phòng';
  static const String bookingCheckIn = 'Ngày check-in';
  static const String bookingCheckOut = 'Ngày check-out';
  static const String bookingDuration = 'Thời gian';
  static const String bookingTotalPrice = 'Tổng tiền';
  static const String bookingDiscount = 'Giảm giá';
  static const String bookingFinalAmount = 'Thành tiền';
  static const String bookingDeposit = 'Đặt cọc';
  static const String bookingRemaining = 'Còn lại';
  static const String bookingCreateSuccess = 'Đặt phòng thành công';
  static const String bookingCreateError = 'Đặt phòng thất bại';
  static const String bookingNoPackages = 'Không có gói dịch vụ nào';
  static const String bookingNoRooms = 'Không có phòng trống';
  static const String bookingPleaseSelectPackage = 'Vui lòng chọn gói dịch vụ';
  static const String bookingPleaseSelectRoom = 'Vui lòng chọn phòng';
  static const String bookingPleaseSelectDate = 'Vui lòng chọn ngày check-in';
  static const String bookingDays = 'ngày';
  static const String bookingFloor = 'Tầng';
  static const String bookingRoomType = 'Loại';
  static const String bookingStatus = 'Trạng thái';
  static const String bookingEstimatedPrice = 'Giá tạm tính';
  static const String bookingAvailable = 'Trống';
  static const String bookingOccupied = 'Đang sử dụng';
  static const String bookingMaintenance = 'Bảo trì';
  static const String bookingPriceNotAvailable = '--';

  // Payment Screen
  static const String paymentTitle = 'Thanh toán đặt cọc';
  static const String paymentDeposit = 'Đặt cọc';
  static const String paymentRemaining = 'Thanh toán còn lại';
  static const String paymentAmount = 'Số tiền';
  static const String paymentMethod = 'Phương thức thanh toán';
  static const String paymentPayOS = 'PayOS';
  static const String paymentQRCode = 'Mã QR thanh toán';
  static const String paymentScanQR = 'Quét mã QR để thanh toán';
  static const String paymentOr = 'Hoặc';
  static const String paymentOpenLink = 'Mở link thanh toán';
  static const String paymentChecking =
      'Đang kiểm tra trạng thái thanh toán...';
  static const String paymentSuccess = 'Thanh toán thành công';
  static const String paymentFailed = 'Thanh toán thất bại';
  static const String paymentPending = 'Đang chờ thanh toán';
  static const String paymentCheckStatus = 'Kiểm tra trạng thái';
  static const String paymentCreateError = 'Không thể tạo link thanh toán';

  // Invoice Screen
  static const String invoiceTitle = 'Hóa đơn';
  static const String invoiceCode = 'Mã hóa đơn';
  static const String invoiceDate = 'Ngày tạo';
  static const String invoiceCustomer = 'Khách hàng';
  static const String invoiceEmail = 'Email';
  static const String invoicePhone = 'Số điện thoại';
  static const String invoiceBookingDetails = 'Chi tiết đặt phòng';
  static const String invoicePackage = 'Gói dịch vụ';
  static const String invoiceRoom = 'Phòng';
  static const String invoiceCheckIn = 'Check-in';
  static const String invoiceCheckOut = 'Check-out';
  static const String invoiceDuration = 'Thời gian';
  static const String invoicePriceDetails = 'Chi tiết giá';
  static const String invoiceTotalPrice = 'Tổng tiền';
  static const String invoiceDiscount = 'Giảm giá';
  static const String invoiceFinalAmount = 'Thành tiền';
  static const String invoicePaidAmount = 'Đã thanh toán';
  static const String invoiceRemainingAmount = 'Còn lại';
  static const String invoiceTransactions = 'Lịch sử giao dịch';
  static const String invoiceTransactionDate = 'Ngày giao dịch';
  static const String invoiceTransactionAmount = 'Số tiền';
  static const String invoiceTransactionType = 'Loại';
  static const String invoiceTransactionStatus = 'Trạng thái';
  static const String transactionTypeDeposit = 'Đặt cọc';
  static const String transactionTypeRemaining = 'Còn lại';
  static const String invoiceContract = 'Hợp đồng';
  static const String invoiceContractCode = 'Mã hợp đồng';
  static const String invoiceContractStatus = 'Trạng thái hợp đồng';
  static const String invoiceDownloadContract = 'Tải hợp đồng';
  static const String invoiceNoContract = 'Chưa có hợp đồng';
  static const String invoiceLoadError = 'Không thể tải hóa đơn';

  // Contract strings
  static const String contractTitle = 'Hợp đồng';
  static const String contractCode = 'Mã hợp đồng';
  static const String contractDate = 'Ngày tạo hợp đồng';
  static const String contractEffectiveFrom = 'Có hiệu lực từ';
  static const String contractEffectiveTo = 'Đến ngày';
  static const String contractSignedDate = 'Ngày ký';
  static const String contractStatus = 'Trạng thái';
  static const String contractCheckinDate = 'Ngày check-in';
  static const String contractCheckoutDate = 'Ngày check-out';
  static const String contractCustomer = 'Khách hàng';
  static const String contractDownloadPdf = 'Tải hợp đồng PDF';
  static const String contractLoading = 'Đang tải hợp đồng...';
  static const String contractLoadError = 'Không thể tải hợp đồng';
  static const String contractStatusDraft = 'Bản nháp';
  static const String contractStatusSigned = 'Đã ký';
  static const String contractNotSigned = 'Chưa ký';
  static const String contractStatusSent = 'Đã gửi';
  static const String contractStatusWaitingForSignature = 'Đợi ký';
  static const String contractStatusScheduleCompleted = 'Đã hoàn thành lịch trình';

  // Booking Status
  static const String bookingStatusDraft = 'Bản nháp';
  static const String bookingStatusConfirmed = 'Đã xác nhận';
  static const String bookingStatusCompleted = 'Đã hoàn thành';

  // Transaction Status
  static const String transactionStatusPaid = 'Đã thanh toán';
  static const String transactionStatusFailed = 'Thất bại';
  static const String transactionStatusRefunded = 'Đã hoàn tiền';

  // Services Screen
  static const String servicesCurrentPackage = 'Gói hiện tại: ';
  static const String servicesBookingInfo = 'Thông tin đặt phòng';
  static const String servicesRoomNumber = 'Số phòng';
  static const String servicesTapToFlipCard = 'Chạm để lật thẻ';
  static const String servicesFloor = 'Tầng';
  static const String servicesRemainingDays = 'Ngày còn lại';
  static const String servicesPendingPaymentMessage =
      'Bạn đang có một đặt phòng đang chờ hoàn tất thanh toán.';
  static const String servicesDepositPaid = 'Đã thanh toán đặt cọc';
  static const String servicesRemainingPaymentMessage =
      'Phần thanh toán còn lại sẽ được mở sau khi hợp đồng được ký.';
  static const String servicesAwaitingActivationMessage =
      'Bạn đã thanh toán đủ. Dịch vụ sẽ kích hoạt khi đến ngày check-in.';
  static const String servicesPayRemaining = 'Thanh toán phần còn lại';
  static const String servicesResortExperience = 'Trải nghiệm nghỉ dưỡng của bạn';
  static const String servicesResortExperienceDescription =
      'Theo dõi lịch trình và các tiện ích của bạn.';
  static const String servicesResortAmenities = 'Dịch vụ trong kỳ nghỉ';
  static const String servicesDailySchedule = 'Lịch trình';
  static const String servicesDailyScheduleDescription =
      'Xem hoạt động chăm sóc mẹ & bé theo từng ngày.';
  static const String servicesTodayMenu = 'Thực đơn';
  static const String servicesTodayMenuDescription =
      'Xem các bữa ăn được chuẩn bị cho mẹ và bé.';
  static const String feedBackForService = 'Đánh giá dịch vụ';
  static const String servicesSpaRegistrationDescription =
      'Thư giãn và chăm sóc chuyên sâu cho mẹ.';
  static const String servicesAmenityRequest = 'Tiện ích';
  static const String servicesAmenityRequestDescription =
      'Gọi nước, đồ dùng em bé, dọn phòng,...';
  static const String servicesExploreAmenities = 'Khám phá các dịch vụ tiện ích';

  // Feedback Screen
  static const String feedbackTitle = 'Đánh giá dịch vụ';
  static const String feedbackWrite = 'Viết feedback';
  static const String feedbackWriteFirst = 'Viết feedback đầu tiên';
  static const String feedbackNoFeedback = 'Chưa có feedback nào';
  static const String feedbackShareExperience = 'Hãy chia sẻ trải nghiệm của bạn';
  static const String feedbackType = 'Loại feedback';
  static const String feedbackSelectType = 'Chọn loại feedback';
  static const String feedbackTitleLabel = 'Tiêu đề';
  static const String feedbackTitlePlaceholder = 'Nhập tiêu đề feedback';
  static const String feedbackContentLabel = 'Nội dung';
  static const String feedbackContentPlaceholder = 'Nhập nội dung feedback';
  static const String feedbackRating = 'Đánh giá';
  static const String feedbackImages = 'Ảnh đính kèm (tùy chọn)';
  static const String feedbackSubmit = 'Gửi feedback';
  static const String feedbackSubmitSuccess = 'Gửi feedback thành công';
  static const String feedbackPleaseSelectType = 'Vui lòng chọn loại feedback';
  static const String feedbackPleaseRate = 'Vui lòng đánh giá sao';
  static const String feedbackMaxImages = 'Bạn chỉ có thể thêm tối đa {max} ảnh';
  static const String feedbackAddImage = 'Thêm ảnh';

  // Schedule Screen
  static const String scheduleNoScheduleForDay = 'Không có lịch trình cho ngày này';
  static const String scheduleDay = 'Ngày';
  static const String scheduleMissed = 'Đã bỏ lỡ';
  static const String scheduleCancelled = 'Đã hủy';
  static const String scheduleStaffAssigned = 'Điều dưỡng tiếp quản';
  static const String scheduleNoStaffAssigned = 'Chưa có điều dưỡng được phân công';
  static const String scheduleNote = 'Ghi chú';
  static const String scheduleNoNote = 'Chưa có ghi chú';
  static const String scheduleStaff = 'Điều dưỡng';
  static const String scheduleCompleted = 'Đã hoàn thành';
  static const String scheduleNotCompleted = 'Chưa hoàn thành';
  static const String scheduleManager = 'Quản lý';
  static const String scheduleCompletedAt = 'Hoàn thành lúc';

  // Menu Screen
  static const String menuNoMenuToDelete = 'Không có menu nào để xóa';
  static const String menuSelectMealToDelete = 'Chọn bữa ăn muốn xóa';
  static const String menuSelectMeal = 'Chọn bữa ăn';
  static const String menuDelete = 'Xóa';
  static const String menuDeleteCount = 'Xóa ({count})';
  static const String menuDeletedCount = 'Đã xóa {count} menu';
  static const String menuPleaseSelectAtLeastOne = 'Vui lòng chọn ít nhất một menu';
  static const String menuSaveSuccess = 'Lưu menu thành công';
  static const String menuSaveCount = 'Lưu menu ({count})';
  static const String menuSelect = 'Chọn menu';
  static const String menuNotSelected = 'Chưa chọn menu';
  static const String menuNotSelectedForDate = 'Chưa chọn menu cho ngày {date}';
  static const String menuSelectThis = 'Chọn menu này';
  static const String menuSelectForType = 'Chọn menu {type}';
  static const String menuForType = 'Menu {type}';
  static const String menuNoMenuForType = 'Không có menu {type}';
  static const String menuNoFoods = 'Menu này chưa có món ăn';
  static const String menuFoodsList = 'Danh sách món ăn';
  static const String menuFoodsListCount = 'Danh sách món ăn ({count})';
  static const String menuSelecting = 'Menu đang chọn - {date}';
  static const String menuSelected = 'Menu đã chọn - {date}';
  static const String menuNotSaved = 'Chưa lưu';
  static const String menuWaitingCheckIn = 'Chờ check-in';

  // Months
  static const String month1 = 'Tháng 1';
  static const String month2 = 'Tháng 2';
  static const String month3 = 'Tháng 3';
  static const String month4 = 'Tháng 4';
  static const String month5 = 'Tháng 5';
  static const String month6 = 'Tháng 6';
  static const String month7 = 'Tháng 7';
  static const String month8 = 'Tháng 8';
  static const String month9 = 'Tháng 9';
  static const String month10 = 'Tháng 10';
  static const String month11 = 'Tháng 11';
  static const String month12 = 'Tháng 12';

  // Week Days
  static const String weekDayMonday = 'T2';
  static const String weekDayTuesday = 'T3';
  static const String weekDayWednesday = 'T4';
  static const String weekDayThursday = 'T5';
  static const String weekDayFriday = 'T6';
  static const String weekDaySaturday = 'T7';
  static const String weekDaySunday = 'CN';

  // Support and Policy
      static const String helpandPolicy = 'Hỗ trợ và pháp lý';
  static const String supportAndPolicyTitle = 'Hỗ trợ và pháp lý';
  
  // Help Screen
  static const String helpTitle = 'Trợ giúp';
  static const String helpFaq = 'Câu hỏi thường gặp';
  static const String helpHowToUse = 'Hướng dẫn sử dụng';
  static const String helpTroubleshooting = 'Khắc phục sự cố';
  static const String helpContactSupport = 'Liên hệ hỗ trợ';
  
  // Contact Screen
  static const String contactTitle = 'Liên hệ';
  static const String contactPhone = 'Hotline';
  static const String contactEmail = 'Email';
  static const String contactAddress = 'Địa chỉ';
  static const String contactWorkingHours = 'Giờ làm việc';
  static const String contactPhoneNumber = '1900 1234';
  static const String contactEmailAddress = 'support@thejoyfulnest.com';
  static const String contactFullAddress = '1056A Đường Nguyễn Văn Linh, Tân Phong, Quận 7, Thành phố Hồ Chí Minh 700000, Việt Nam';
  static const String contactHours = 'Thứ 2 - Chủ nhật: 8:00 - 20:00';
  static const String contactCallNow = 'Gọi ngay';
  static const String contactSendEmail = 'Gửi email';
  
  // About Screen
  static const String aboutTitle = 'Về chúng tôi';
  static const String aboutDescription = 'The Joyful Nest là dịch vụ nghỉ dưỡng chuyên nghiệp dành cho mẹ và bé sau sinh. Chúng tôi cung cấp các gói dịch vụ chăm sóc toàn diện với đội ngũ nhân viên giàu kinh nghiệm và cơ sở vật chất hiện đại.';
  static const String aboutMission = 'Sứ mệnh';
  static const String aboutMissionContent = 'Mang đến trải nghiệm nghỉ dưỡng tuyệt vời nhất cho mẹ và bé, giúp các gia đình có những khoảnh khắc hạnh phúc và đáng nhớ trong giai đoạn quan trọng này.';
  static const String aboutVision = 'Tầm nhìn';
  static const String aboutVisionContent = 'Trở thành địa điểm nghỉ dưỡng hàng đầu tại Việt Nam, được tin tưởng và lựa chọn bởi các gia đình trong việc chăm sóc sức khỏe mẹ và bé sau sinh.';
  static const String aboutValues = 'Giá trị cốt lõi';
  static const String aboutValue1 = 'Chăm sóc tận tâm';
  static const String aboutValue2 = 'Chuyên nghiệp';
  static const String aboutValue3 = 'An toàn và tin cậy';
  static const String aboutValue4 = 'Đổi mới và phát triển';
  
  // Terms Screen
  static const String termsTitle = 'Điều khoản sử dụng';
  static const String termsLastUpdated = 'Cập nhật lần cuối: {date}';
  static const String termsSection1 = '1. Chấp nhận điều khoản';
  static const String termsSection1Content = 'Bằng việc sử dụng ứng dụng The Joyful Nest, bạn đồng ý tuân thủ và bị ràng buộc bởi các điều khoản và điều kiện này. Nếu bạn không đồng ý với bất kỳ phần nào của các điều khoản này, bạn không được sử dụng dịch vụ của chúng tôi.';
  static const String termsSection2 = '2. Sử dụng dịch vụ';
  static const String termsSection2Content = 'Bạn đồng ý sử dụng ứng dụng một cách hợp pháp và phù hợp với các quy định hiện hành. Bạn không được sử dụng dịch vụ cho bất kỳ mục đích bất hợp pháp hoặc trái phép nào.';
  static const String termsSection3 = '3. Tài khoản người dùng';
  static const String termsSection3Content = 'Bạn chịu trách nhiệm duy trì tính bảo mật của tài khoản và mật khẩu của mình. Bạn đồng ý thông báo ngay lập tức cho chúng tôi về bất kỳ vi phạm bảo mật nào.';
  static const String termsSection4 = '4. Thanh toán';
  static const String termsSection4Content = 'Tất cả các khoản thanh toán phải được thực hiện đúng hạn theo quy định. Chúng tôi có quyền từ chối hoặc hủy bỏ bất kỳ giao dịch nào mà chúng tôi cho là đáng ngờ hoặc vi phạm các điều khoản này.';
  static const String termsSection5 = '5. Hủy bỏ và hoàn tiền';
  static const String termsSection5Content = 'Chính sách hủy bỏ và hoàn tiền được quy định chi tiết trong hợp đồng dịch vụ. Vui lòng tham khảo hợp đồng của bạn để biết thêm thông tin.';
  
  // Privacy Screen
  static const String privacyTitle = 'Chính sách bảo mật';
  static const String privacyLastUpdated = 'Cập nhật lần cuối: {date}';
  static const String privacyIntroduction = 'Chúng tôi cam kết bảo vệ quyền riêng tư của bạn. Chính sách bảo mật này mô tả cách chúng tôi thu thập, sử dụng và bảo vệ thông tin cá nhân của bạn.';
  static const String privacySection1 = '1. Thông tin chúng tôi thu thập';
  static const String privacySection1Content = 'Chúng tôi thu thập thông tin bạn cung cấp trực tiếp khi đăng ký tài khoản, đặt dịch vụ, hoặc liên hệ với chúng tôi. Thông tin này bao gồm tên, email, số điện thoại, địa chỉ và thông tin y tế liên quan.';
  static const String privacySection2 = '2. Cách chúng tôi sử dụng thông tin';
  static const String privacySection2Content = 'Chúng tôi sử dụng thông tin của bạn để cung cấp và cải thiện dịch vụ, xử lý thanh toán, gửi thông báo quan trọng, và tuân thủ các nghĩa vụ pháp lý.';
  static const String privacySection3 = '3. Bảo mật thông tin';
  static const String privacySection3Content = 'Chúng tôi sử dụng các biện pháp bảo mật kỹ thuật và tổ chức phù hợp để bảo vệ thông tin cá nhân của bạn khỏi truy cập trái phép, mất mát hoặc phá hủy.';
  static const String privacySection4 = '4. Chia sẻ thông tin';
  static const String privacySection4Content = 'Chúng tôi không bán, cho thuê hoặc chia sẻ thông tin cá nhân của bạn với bên thứ ba, trừ khi được yêu cầu bởi pháp luật hoặc với sự đồng ý của bạn.';
  static const String privacySection5 = '5. Quyền của bạn';
  static const String privacySection5Content = 'Bạn có quyền truy cập, chỉnh sửa, xóa hoặc yêu cầu ngừng xử lý thông tin cá nhân của mình. Để thực hiện các quyền này, vui lòng liên hệ với chúng tôi.';
}
