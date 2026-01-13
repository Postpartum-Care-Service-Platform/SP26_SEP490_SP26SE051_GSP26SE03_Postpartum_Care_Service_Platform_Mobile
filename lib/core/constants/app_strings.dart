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

  // Links
  static const String needAnAccount = 'Need an account?';
  static const String forgotPassword = 'Forgot your password?';
  static const String resetIt = 'Reset it';

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
  static const String errorInputPasswordMinLength = 'Password must be at least 6 characters';
  static const String errorInputConfirmPassword = 'Please confirm your password';
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
  static const String otpVerificationDescription = 'Nhập mã OTP đã được gửi đến';
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
  static const String confirmDeleteMessage = 'Bạn có chắc chắn muốn xóa {name}?';
  static const String delete = 'Xóa';
  static const String featureUnderDevelopment = 'Tính năng đang được phát triển';
  static const String addMemberFeatureUnderDevelopment = 'Tính năng thêm thành viên đang được phát triển';
  static const String deleteFeatureUnderDevelopment = 'Tính năng xóa đang được phát triển';
  static const String edit = 'Chỉnh sửa';
  static const String takePhoto = 'Chụp ảnh';
  static const String chooseFromLibrary = 'Chọn từ thư viện';
  static const String pleaseEnterFullName = 'Vui lòng nhập họ và tên';
  static const String invalidPhoneNumber = 'Số điện thoại không hợp lệ';
  static const String pleaseGrantPhotoPermission = 'Vui lòng cấp quyền truy cập ảnh trong phần Cài đặt ứng dụng.';
  static const String photoPermissionDenied = 'Quyền truy cập ảnh bị từ chối.';
  static const String pleaseGrantCameraPermission = 'Vui lòng cấp quyền sử dụng camera trong phần Cài đặt ứng dụng.';
  static const String cameraPermissionDenied = 'Quyền sử dụng camera bị từ chối.';
  static const String cannotOpenPhotoLibrary = 'Không thể mở thư viện ảnh. Vui lòng kiểm tra quyền truy cập (error: {code})';
  static const String errorSelectingPhoto = 'Đã xảy ra lỗi khi chọn ảnh: {error}';
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
  static const String noCarePlanDetails = 'Gói dịch vụ này chưa có lịch trình nghỉ dưỡng';
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
  static const String pleaseSelectAppointmentType = 'Vui lòng chọn loại lịch hẹn';
  static const String appointmentLocation = 'Địa điểm';
  static const String appointmentLocationName = 'The Joyful Nest';
  static const String appointmentLocationAddress =
      '1056A Đường Nguyễn Văn Linh, Tân Phong, Quận 7, Thành phố Hồ Chí Minh 700000, Việt Nam';
  static const String appointmentStatus = 'Trạng thái';
  static const String staff = 'Nhân viên';
  static const String noStaffAssigned = 'Chưa có nhân viên';
  static const String confirmCancel = 'Xác nhận hủy';
  static const String confirmCancelMessage = 'Bạn có chắc chắn muốn hủy lịch hẹn này?';
  static const String loadAppointmentsError = 'Không thể tải danh sách lịch hẹn';
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
}

