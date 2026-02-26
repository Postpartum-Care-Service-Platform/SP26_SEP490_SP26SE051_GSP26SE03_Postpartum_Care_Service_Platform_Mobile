import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/verify_email_usecase.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/verify_reset_otp_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/domain/usecases/resend_otp_usecase.dart';
import '../../features/auth/domain/usecases/google_sign_in_usecase.dart';
import '../../features/auth/domain/usecases/get_account_by_id_usecase.dart';
import '../../features/auth/domain/usecases/get_current_account_usecase.dart';
import '../../features/auth/domain/usecases/change_password_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/family_profile/data/datasources/family_profile_remote_datasource.dart';
import '../../features/family_profile/data/repositories/family_profile_repository_impl.dart';
import '../../features/family_profile/domain/repositories/family_profile_repository.dart';
import '../../features/family_profile/domain/usecases/get_family_profiles_usecase.dart';
import '../../features/family_profile/domain/usecases/get_member_types_usecase.dart';
import '../../features/family_profile/domain/usecases/create_family_profile_usecase.dart';
import '../../features/family_profile/presentation/bloc/family_profile_bloc.dart';
import '../../features/notification/data/datasources/notification_remote_datasource.dart';
import '../../features/notification/data/repositories/notification_repository_impl.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';
import '../../features/notification/domain/usecases/get_notifications_usecase.dart';
import '../../features/notification/domain/usecases/get_notification_by_id_usecase.dart';
import '../../features/notification/domain/usecases/mark_notification_read_usecase.dart';
import '../../features/notification/domain/usecases/get_unread_count_usecase.dart';
import '../../features/notification/presentation/bloc/notification_bloc.dart';
import '../../features/package/data/datatsources/package_remote_datasource.dart';
import '../../features/package/data/datatsources/package_type_remote_datasource.dart';
import '../../features/package/data/repositories/package_repository_impl.dart';
import '../../features/package/data/repositories/package_type_repository_impl.dart';
import '../../features/package/domain/repositories/package_repository.dart';
import '../../features/package/domain/repositories/package_type_repository.dart';
import '../../features/package/domain/usecases/get_packages_usecase.dart';
import '../../features/package/domain/usecases/get_package_types_usecase.dart';
import '../../features/package/presentation/bloc/package_bloc.dart';
import '../../features/care_plan/data/datasources/care_plan_remote_datasource.dart';
import '../../features/care_plan/data/repositories/care_plan_repository_impl.dart';
import '../../features/care_plan/domain/repositories/care_plan_repository.dart';
import '../../features/care_plan/domain/usecases/get_care_plan_details_usecase.dart';
import '../../features/care_plan/presentation/bloc/care_plan_bloc.dart';
import '../../features/appointment/data/datasources/appointment_remote_datasource.dart';
import '../../features/appointment/data/repositories/appointment_repository_impl.dart';
import '../../features/appointment/domain/repositories/appointment_repository.dart';
import '../../features/appointment/domain/usecases/get_appointments_usecase.dart';
import '../../features/appointment/domain/usecases/create_appointment_usecase.dart';
import '../../features/appointment/domain/usecases/update_appointment_usecase.dart';
import '../../features/appointment/domain/usecases/cancel_appointment_usecase.dart';
import '../../features/appointment/domain/usecases/get_appointment_types_usecase.dart';
import '../../features/appointment/presentation/bloc/appointment_bloc.dart';
import '../../features/employee/data/datasources/appointment_employee_remote_datasource.dart';
import '../../features/employee/data/repositories/appointment_employee_repository_impl.dart';
import '../../features/employee/domain/repositories/appointment_employee_repository.dart';
import '../../features/employee/domain/usecases/get_my_assigned_appointments.dart';
import '../../features/employee/domain/usecases/get_all_appointments.dart';
import '../../features/employee/domain/usecases/get_appointment_by_id.dart';
import '../../features/employee/domain/usecases/confirm_appointment.dart';
import '../../features/employee/domain/usecases/complete_appointment.dart';
import '../../features/employee/domain/usecases/cancel_appointment.dart';
import '../../features/employee/domain/usecases/create_appointment_for_customer.dart';
import '../../features/employee/presentation/bloc/appointment/appointment_bloc.dart' as employee_appointment;
import '../../features/employee/data/datasources/room_remote_datasource.dart';
import '../../features/employee/data/repositories/room_repository_impl.dart';
import '../../features/employee/domain/repositories/room_repository.dart';
import '../../features/employee/domain/usecases/get_all_rooms.dart';
import '../../features/employee/domain/usecases/get_room_by_id.dart';
import '../../features/employee/domain/usecases/get_available_rooms.dart';
import '../../features/employee/presentation/bloc/room/room_bloc.dart';
import '../../features/employee/data/datasources/amenity_service_remote_datasource.dart';
import '../../features/employee/data/repositories/amenity_service_repository_impl.dart';
import '../../features/employee/domain/repositories/amenity_service_repository.dart';
import '../../features/employee/domain/usecases/get_all_amenity_services.dart';
import '../../features/employee/domain/usecases/get_amenity_service_by_id.dart';
import '../../features/employee/domain/usecases/get_active_amenity_services.dart';
import '../../features/employee/presentation/bloc/amenity_service/amenity_service_bloc.dart';
import '../../features/employee/data/datasources/amenity_ticket_remote_datasource.dart';
import '../../features/employee/data/repositories/amenity_ticket_repository_impl.dart';
import '../../features/employee/domain/repositories/amenity_ticket_repository.dart';
import '../../features/employee/domain/usecases/create_service_booking.dart';
import '../../features/employee/presentation/bloc/amenity_ticket/amenity_ticket_bloc.dart';
import '../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/get_conversations_usecase.dart';
import '../../features/chat/domain/usecases/get_conversation_detail_usecase.dart';
import '../../features/chat/domain/usecases/send_message_usecase.dart';
import '../../features/chat/domain/usecases/create_conversation_usecase.dart';
import '../../features/chat/domain/usecases/mark_messages_read_usecase.dart';
import '../../features/chat/domain/usecases/request_support_usecase.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../features/chat/presentation/services/chat_hub_service.dart';
import '../../features/booking/data/datasources/booking_remote_datasource.dart';
import '../../features/booking/data/repositories/booking_repository_impl.dart';
import '../../features/booking/domain/repositories/booking_repository.dart';
import '../../features/booking/domain/usecases/create_booking_usecase.dart';
import '../../features/booking/domain/usecases/get_booking_by_id_usecase.dart';
import '../../features/booking/domain/usecases/get_bookings_usecase.dart';
import '../../features/booking/domain/usecases/create_payment_link_usecase.dart';
import '../../features/booking/domain/usecases/check_payment_status_usecase.dart';
import '../../features/booking/presentation/bloc/booking_bloc.dart';
import '../../features/contract/data/datasources/contract_remote_datasource.dart';
import '../../features/contract/data/repositories/contract_repository_impl.dart';
import '../../features/contract/domain/repositories/contract_repository.dart';
import '../../features/contract/domain/usecases/get_contract_by_booking_id_usecase.dart';
import '../../features/contract/domain/usecases/export_contract_pdf_usecase.dart';
import '../../features/contract/presentation/bloc/contract_bloc.dart';
import '../../features/services/data/datasources/menu_remote_datasource.dart';
import '../../features/services/data/repositories/menu_repository_impl.dart';
import '../../features/services/domain/repositories/menu_repository.dart';
import '../../features/services/domain/usecases/get_menus_usecase.dart';
import '../../features/services/domain/usecases/get_menu_types_usecase.dart';
import '../../features/services/domain/usecases/get_my_menu_records_usecase.dart';
import '../../features/services/domain/usecases/get_my_menu_records_by_date_usecase.dart';
import '../../features/services/domain/usecases/create_menu_records_usecase.dart';
import '../../features/services/domain/usecases/update_menu_records_usecase.dart';
import '../../features/services/domain/usecases/delete_menu_record_usecase.dart';
import '../../features/services/presentation/bloc/menu_bloc.dart';
import '../../features/services/data/datasources/family_schedule_remote_datasource.dart';
import '../../features/services/data/repositories/family_schedule_repository_impl.dart';
import '../../features/services/domain/repositories/family_schedule_repository.dart';
import '../../features/services/domain/usecases/get_my_schedules_usecase.dart';
import '../../features/services/domain/usecases/get_my_schedules_by_date_usecase.dart';
import '../../features/services/presentation/bloc/family_schedule_bloc.dart';
import '../../features/services/data/datasources/feedback_remote_datasource.dart';
import '../../features/services/data/repositories/feedback_repository_impl.dart';
import '../../features/services/domain/repositories/feedback_repository.dart';
import '../../features/services/domain/usecases/get_feedback_types_usecase.dart';
import '../../features/services/domain/usecases/get_my_feedbacks_usecase.dart';
import '../../features/services/domain/usecases/create_feedback_usecase.dart';
import '../../features/services/presentation/bloc/feedback_bloc.dart';
import '../../features/services/data/datasources/amenity_remote_datasource.dart';
import '../../features/services/data/repositories/amenity_repository_impl.dart';
import '../../features/services/domain/repositories/amenity_repository.dart';
import '../../features/services/domain/usecases/get_amenity_services_usecase.dart';
import '../../features/services/domain/usecases/get_my_amenity_tickets_usecase.dart';
import '../../features/services/domain/usecases/create_amenity_ticket_usecase.dart';
import '../../features/services/presentation/bloc/amenity_bloc.dart';
import '../apis/api_client.dart';

/// Centralized dependency injection container
/// Contains all dependency injections for the entire app
class InjectionContainer {
  InjectionContainer._();

  // ==================== Data Sources ====================
  
  static AuthRemoteDataSource get _authRemoteDataSource =>
      AuthRemoteDataSourceImpl(dio: ApiClient.dio);
  
  static FamilyProfileRemoteDataSource get _familyProfileRemoteDataSource =>
      FamilyProfileRemoteDataSourceImpl(dio: ApiClient.dio);
  
  static NotificationRemoteDataSource get _notificationRemoteDataSource =>
      NotificationRemoteDataSourceImpl(dio: ApiClient.dio);
  
  static PackageRemoteDataSource get _packageRemoteDataSource =>
      PackageRemoteDataSourceImpl();
  
  static PackageTypeRemoteDataSource get _packageTypeRemoteDataSource =>
      PackageTypeRemoteDataSourceImpl();
  
  static CarePlanRemoteDataSource get _carePlanRemoteDataSource =>
      CarePlanRemoteDataSourceImpl();

  static AppointmentRemoteDataSource get _appointmentRemoteDataSource =>
      AppointmentRemoteDataSourceImpl();
  
  static AppointmentEmployeeRemoteDataSource get _appointmentEmployeeRemoteDataSource =>
      AppointmentEmployeeRemoteDataSource(dio: ApiClient.dio);
  
  static RoomRemoteDataSource get _roomRemoteDataSource =>
      RoomRemoteDataSource(dio: ApiClient.dio);
  
  static AmenityServiceRemoteDataSource get _amenityServiceRemoteDataSource =>
      AmenityServiceRemoteDataSource(dio: ApiClient.dio);
  
  static AmenityTicketRemoteDataSource get _amenityTicketRemoteDataSource =>
      AmenityTicketRemoteDataSource(dio: ApiClient.dio);

  static ChatRemoteDataSource get _chatRemoteDataSource =>
      ChatRemoteDataSourceImpl(dio: ApiClient.dio);
  static ChatHubService? _chatHubService;
  static ChatHubService get chatHubService =>
      _chatHubService ??= ChatHubService();

  static BookingRemoteDataSource get _bookingRemoteDataSource =>
      BookingRemoteDataSourceImpl(dio: ApiClient.dio);

  static ContractRemoteDataSource get _contractRemoteDataSource =>
      ContractRemoteDataSourceImpl(dio: ApiClient.dio);

  static MenuRemoteDataSource get _menuRemoteDataSource =>
      MenuRemoteDataSourceImpl(dio: ApiClient.dio);

  static FamilyScheduleRemoteDataSource get _familyScheduleRemoteDataSource =>
      FamilyScheduleRemoteDataSourceImpl(dio: ApiClient.dio);

  static FeedbackRemoteDataSource get _feedbackRemoteDataSource =>
      FeedbackRemoteDataSourceImpl(dio: ApiClient.dio);

  // ==================== Repositories ====================
  
  static AuthRepository get authRepository =>
      AuthRepositoryImpl(remoteDataSource: _authRemoteDataSource);
  
  static AuthRepository get _authRepository => authRepository;
  
  static FamilyProfileRepository get familyProfileRepository =>
      FamilyProfileRepositoryImpl(remoteDataSource: _familyProfileRemoteDataSource);
  
  static NotificationRepository get notificationRepository =>
      NotificationRepositoryImpl(_notificationRemoteDataSource);
  
  static PackageRepository get packageRepository =>
      PackageRepositoryImpl(_packageRemoteDataSource);
  
  static PackageTypeRepository get packageTypeRepository =>
      PackageTypeRepositoryImpl(_packageTypeRemoteDataSource);
  
  static CarePlanRepository get carePlanRepository =>
      CarePlanRepositoryImpl(_carePlanRemoteDataSource);

  static AppointmentRepository get appointmentRepository =>
      AppointmentRepositoryImpl(dataSource: _appointmentRemoteDataSource) as AppointmentRepository;
  
  static AppointmentEmployeeRepository get appointmentEmployeeRepository =>
      AppointmentEmployeeRepositoryImpl(remoteDataSource: _appointmentEmployeeRemoteDataSource);
  
  static RoomRepository get roomRepository =>
      RoomRepositoryImpl(remoteDataSource: _roomRemoteDataSource);
  
  static AmenityServiceRepository get amenityServiceRepository =>
      AmenityServiceRepositoryImpl(remoteDataSource: _amenityServiceRemoteDataSource);
  
  static AmenityTicketRepository get amenityTicketRepository =>
      AmenityTicketRepositoryImpl(remoteDataSource: _amenityTicketRemoteDataSource);

  static ChatRepository get chatRepository =>
      ChatRepositoryImpl(remoteDataSource: _chatRemoteDataSource);

  static BookingRepository get bookingRepository =>
      BookingRepositoryImpl(remoteDataSource: _bookingRemoteDataSource);

  static ContractRepository get contractRepository =>
      ContractRepositoryImpl(remoteDataSource: _contractRemoteDataSource);

  static MenuRepository get menuRepository =>
      MenuRepositoryImpl(_menuRemoteDataSource);

  static FamilyScheduleRepository get familyScheduleRepository =>
      FamilyScheduleRepositoryImpl(remoteDataSource: _familyScheduleRemoteDataSource);

  static FeedbackRepository get feedbackRepository =>
      FeedbackRepositoryImpl(_feedbackRemoteDataSource);

  static AmenityRemoteDataSource get _amenityRemoteDataSource =>
      AmenityRemoteDataSourceImpl(dio: ApiClient.dio);

  static AmenityRepository get amenityRepository =>
      AmenityRepositoryImpl(dataSource: _amenityRemoteDataSource);

  // ==================== Use Cases ====================
  
  static LoginUsecase get _loginUsecase => LoginUsecase(_authRepository);
  static RegisterUsecase get _registerUsecase => RegisterUsecase(_authRepository);
  static VerifyEmailUsecase get _verifyEmailUsecase => VerifyEmailUsecase(_authRepository);
  static ForgotPasswordUsecase get _forgotPasswordUsecase =>
      ForgotPasswordUsecase(_authRepository);
  static VerifyResetOtpUsecase get _verifyResetOtpUsecase =>
      VerifyResetOtpUsecase(_authRepository);
  static ResetPasswordUsecase get _resetPasswordUsecase =>
      ResetPasswordUsecase(_authRepository);
  static ResendOtpUsecase get _resendOtpUsecase =>
      ResendOtpUsecase(_authRepository);
  static GoogleSignInUsecase get _googleSignInUsecase =>
      GoogleSignInUsecase(_authRepository);
  static GetAccountByIdUsecase get _getAccountByIdUsecase =>
      GetAccountByIdUsecase(_authRepository);
  static GetCurrentAccountUsecase get _getCurrentAccountUsecase =>
      GetCurrentAccountUsecase(_authRepository);
  static ChangePasswordUsecase get _changePasswordUsecase =>
      ChangePasswordUsecase(_authRepository);

  static GetFamilyProfilesUsecase get _getFamilyProfilesUsecase =>
      GetFamilyProfilesUsecase(familyProfileRepository);
  static GetMemberTypesUsecase get _getMemberTypesUsecase =>
      GetMemberTypesUsecase(familyProfileRepository);
  static CreateFamilyProfileUsecase get _createFamilyProfileUsecase =>
      CreateFamilyProfileUsecase(familyProfileRepository);
  
  static GetNotificationsUsecase get _getNotificationsUsecase =>
      GetNotificationsUsecase(notificationRepository);
  static GetNotificationByIdUsecase get _getNotificationByIdUsecase =>
      GetNotificationByIdUsecase(notificationRepository);
  static MarkNotificationReadUsecase get _markNotificationReadUsecase =>
      MarkNotificationReadUsecase(notificationRepository);
  static GetUnreadCountUsecase get _getUnreadCountUsecase =>
      GetUnreadCountUsecase(notificationRepository);
  
  static GetPackagesUsecase get _getPackagesUsecase =>
      GetPackagesUsecase(packageRepository);
  
  static GetPackageTypesUsecase get _getPackageTypesUsecase =>
      GetPackageTypesUsecase(packageTypeRepository);
  
  static GetCarePlanDetailsUsecase get _getCarePlanDetailsUsecase =>
      GetCarePlanDetailsUsecase(carePlanRepository);
  
  // Employee - Appointment UseCases
  static GetMyAssignedAppointments get _getMyAssignedAppointments =>
      GetMyAssignedAppointments(appointmentEmployeeRepository);
  static GetAllAppointments get _getAllAppointments =>
      GetAllAppointments(appointmentEmployeeRepository);
  static GetAppointmentById get _getAppointmentById =>
      GetAppointmentById(appointmentEmployeeRepository);
  static ConfirmAppointment get _confirmAppointment =>
      ConfirmAppointment(appointmentEmployeeRepository);
  static CompleteAppointment get _completeAppointment =>
      CompleteAppointment(appointmentEmployeeRepository);
  static CancelAppointment get _cancelAppointment =>
      CancelAppointment(appointmentEmployeeRepository);
  static CreateAppointmentForCustomer get _createAppointmentForCustomer =>
      CreateAppointmentForCustomer(appointmentEmployeeRepository);
  
  // Employee - Room UseCases
  static GetAllRooms get _getAllRooms =>
      GetAllRooms(roomRepository);
  static GetRoomById get _getRoomById =>
      GetRoomById(roomRepository);
  static GetAvailableRooms get _getAvailableRooms =>
      GetAvailableRooms(roomRepository);
  
  // Employee - AmenityService UseCases
  static GetAllAmenityServices get _getAllAmenityServices =>
      GetAllAmenityServices(amenityServiceRepository);
  static GetAmenityServiceById get _getAmenityServiceById =>
      GetAmenityServiceById(amenityServiceRepository);
  static GetActiveAmenityServices get _getActiveAmenityServices =>
      GetActiveAmenityServices(amenityServiceRepository);
  
  // Employee - AmenityTicket UseCases
  static CreateServiceBooking get _createServiceBooking =>
      CreateServiceBooking(amenityTicketRepository);

  static GetAppointmentsUsecase get _getAppointmentsUsecase =>
      GetAppointmentsUsecase(appointmentRepository);
  static CreateAppointmentUsecase get _createAppointmentUsecase =>
      CreateAppointmentUsecase(appointmentRepository);
  static UpdateAppointmentUsecase get _updateAppointmentUsecase =>
      UpdateAppointmentUsecase(appointmentRepository);
  static CancelAppointmentUsecase get _cancelAppointmentUsecase =>
      CancelAppointmentUsecase(appointmentRepository);
  static GetAppointmentTypesUsecase get appointmentTypesUsecase =>
      GetAppointmentTypesUsecase(appointmentRepository);

  static GetConversationsUsecase get _getConversationsUsecase =>
      GetConversationsUsecase(chatRepository);
  static GetConversationDetailUsecase get _getConversationDetailUsecase =>
      GetConversationDetailUsecase(chatRepository);
  static SendMessageUsecase get _sendMessageUsecase =>
      SendMessageUsecase(chatRepository);
  static CreateConversationUsecase get _createConversationUsecase =>
      CreateConversationUsecase(chatRepository);
  static MarkMessagesReadUsecase get _markMessagesReadUsecase =>
      MarkMessagesReadUsecase(chatRepository);
  static RequestSupportUsecase get _requestSupportUsecase =>
      RequestSupportUsecase(chatRepository);

  static CreateBookingUsecase get _createBookingUsecase =>
      CreateBookingUsecase(bookingRepository);
  static GetBookingByIdUsecase get _getBookingByIdUsecase =>
      GetBookingByIdUsecase(bookingRepository);
  static GetBookingsUsecase get _getBookingsUsecase =>
      GetBookingsUsecase(bookingRepository);
  static CreatePaymentLinkUsecase get _createPaymentLinkUsecase =>
      CreatePaymentLinkUsecase(bookingRepository);
  static CheckPaymentStatusUsecase get _checkPaymentStatusUsecase =>
      CheckPaymentStatusUsecase(bookingRepository);

  static GetContractByBookingIdUsecase get _getContractByBookingIdUsecase =>
      GetContractByBookingIdUsecase(contractRepository);
  static ExportContractPdfUsecase get _exportContractPdfUsecase =>
      ExportContractPdfUsecase(contractRepository);

  static GetMenusUsecase get _getMenusUsecase =>
      GetMenusUsecase(menuRepository);
  static GetMenuTypesUsecase get _getMenuTypesUsecase =>
      GetMenuTypesUsecase(menuRepository);
  static GetMyMenuRecordsUsecase get _getMyMenuRecordsUsecase =>
      GetMyMenuRecordsUsecase(menuRepository);
  static GetMyMenuRecordsByDateUsecase get _getMyMenuRecordsByDateUsecase =>
      GetMyMenuRecordsByDateUsecase(menuRepository);
  static CreateMenuRecordsUsecase get _createMenuRecordsUsecase =>
      CreateMenuRecordsUsecase(menuRepository);
  static UpdateMenuRecordsUsecase get _updateMenuRecordsUsecase =>
      UpdateMenuRecordsUsecase(menuRepository);
  static DeleteMenuRecordUsecase get _deleteMenuRecordUsecase =>
      DeleteMenuRecordUsecase(menuRepository);

  static GetMySchedulesUsecase get _getMySchedulesUsecase =>
      GetMySchedulesUsecase(familyScheduleRepository);
  static GetMySchedulesByDateUsecase get _getMySchedulesByDateUsecase =>
      GetMySchedulesByDateUsecase(familyScheduleRepository);

  static GetFeedbackTypesUsecase get _getFeedbackTypesUsecase =>
      GetFeedbackTypesUsecase(feedbackRepository);

  static GetMyFeedbacksUsecase get _getMyFeedbacksUsecase =>
      GetMyFeedbacksUsecase(feedbackRepository);

  static CreateFeedbackUsecase get _createFeedbackUsecase =>
      CreateFeedbackUsecase(feedbackRepository);

  static GetAmenityServicesUsecase get _getAmenityServicesUsecase =>
      GetAmenityServicesUsecase(amenityRepository);
  static GetMyAmenityTicketsUsecase get _getMyAmenityTicketsUsecase =>
      GetMyAmenityTicketsUsecase(amenityRepository);
  static CreateAmenityTicketUsecase get _createAmenityTicketUsecase =>
      CreateAmenityTicketUsecase(amenityRepository);

  // ==================== Blocs ====================
  
  static AuthBloc get authBloc => AuthBloc(
    loginUsecase: _loginUsecase,
    registerUsecase: _registerUsecase,
    verifyEmailUsecase: _verifyEmailUsecase,
    forgotPasswordUsecase: _forgotPasswordUsecase,
    verifyResetOtpUsecase: _verifyResetOtpUsecase,
    resetPasswordUsecase: _resetPasswordUsecase,
    resendOtpUsecase: _resendOtpUsecase,
    googleSignInUsecase: _googleSignInUsecase,
    getAccountByIdUsecase: _getAccountByIdUsecase,
    getCurrentAccountUsecase: _getCurrentAccountUsecase,
    changePasswordUsecase: _changePasswordUsecase,
  );

  static FamilyProfileBloc get familyProfileBloc => FamilyProfileBloc(
        getFamilyProfilesUsecase: _getFamilyProfilesUsecase,
        getMemberTypesUsecase: _getMemberTypesUsecase,
        createFamilyProfileUsecase: _createFamilyProfileUsecase,
      );
  
  static NotificationBloc get notificationBloc => NotificationBloc(
        getNotificationsUsecase: _getNotificationsUsecase,
        getNotificationByIdUsecase: _getNotificationByIdUsecase,
        markNotificationReadUsecase: _markNotificationReadUsecase,
        getUnreadCountUsecase: _getUnreadCountUsecase,
      );
  
  static PackageBloc get packageBloc => PackageBloc(
        getPackagesUsecase: _getPackagesUsecase,
      );
  
  static CarePlanBloc get carePlanBloc => CarePlanBloc(
        getCarePlanDetailsUsecase: _getCarePlanDetailsUsecase,
      );
  
  // Employee Blocs
  static employee_appointment.AppointmentBloc get employeeAppointmentBloc => employee_appointment.AppointmentBloc(
        getMyAssignedAppointments: _getMyAssignedAppointments,
        getAllAppointments: _getAllAppointments,
        getAppointmentById: _getAppointmentById,
        confirmAppointment: _confirmAppointment,
        completeAppointment: _completeAppointment,
        cancelAppointment: _cancelAppointment,
        createAppointmentForCustomer: _createAppointmentForCustomer,
      );
  
  static RoomBloc get roomBloc => RoomBloc(
        getAllRooms: _getAllRooms,
        getRoomById: _getRoomById,
        getAvailableRooms: _getAvailableRooms,
      );
  
  static AmenityServiceBloc get amenityServiceBloc => AmenityServiceBloc(
        getAllAmenityServices: _getAllAmenityServices,
        getAmenityServiceById: _getAmenityServiceById,
        getActiveAmenityServices: _getActiveAmenityServices,
      );
  
  static AmenityTicketBloc get amenityTicketBloc => AmenityTicketBloc(
        createServiceBooking: _createServiceBooking,
        repository: amenityTicketRepository,
      );

  static AppointmentBloc get appointmentBloc => AppointmentBloc(
        getAppointmentsUsecase: _getAppointmentsUsecase,
        createAppointmentUsecase: _createAppointmentUsecase,
        updateAppointmentUsecase: _updateAppointmentUsecase,
        cancelAppointmentUsecase: _cancelAppointmentUsecase,
      );

  static ChatBloc get chatBloc => ChatBloc(
        getConversationsUsecase: _getConversationsUsecase,
        getConversationDetailUsecase: _getConversationDetailUsecase,
        sendMessageUsecase: _sendMessageUsecase,
        createConversationUsecase: _createConversationUsecase,
        markMessagesReadUsecase: _markMessagesReadUsecase,
        requestSupportUsecase: _requestSupportUsecase,
        chatHubService: chatHubService,
      );

  static BookingBloc get bookingBloc => BookingBloc(
        createBookingUsecase: _createBookingUsecase,
        getBookingByIdUsecase: _getBookingByIdUsecase,
        getBookingsUsecase: _getBookingsUsecase,
        createPaymentLinkUsecase: _createPaymentLinkUsecase,
        checkPaymentStatusUsecase: _checkPaymentStatusUsecase,
        getPackagesUsecase: _getPackagesUsecase,
        getAllRooms: _getAllRooms,
      );

  static ContractBloc get contractBloc => ContractBloc(
        getContractByBookingIdUsecase: _getContractByBookingIdUsecase,
        exportContractPdfUsecase: _exportContractPdfUsecase,
      );

  static MenuBloc get menuBloc => MenuBloc(
        getMenusUsecase: _getMenusUsecase,
        getMenuTypesUsecase: _getMenuTypesUsecase,
        getMyMenuRecordsUsecase: _getMyMenuRecordsUsecase,
        getMyMenuRecordsByDateUsecase: _getMyMenuRecordsByDateUsecase,
        createMenuRecordsUsecase: _createMenuRecordsUsecase,
        updateMenuRecordsUsecase: _updateMenuRecordsUsecase,
        deleteMenuRecordUsecase: _deleteMenuRecordUsecase,
      );

  static FamilyScheduleBloc get familyScheduleBloc => FamilyScheduleBloc(
        getMySchedulesUsecase: _getMySchedulesUsecase,
        getMySchedulesByDateUsecase: _getMySchedulesByDateUsecase,
      );

  static FeedbackBloc get feedbackBloc => FeedbackBloc(
        getFeedbackTypesUsecase: _getFeedbackTypesUsecase,
        getMyFeedbacksUsecase: _getMyFeedbacksUsecase,
        createFeedbackUsecase: _createFeedbackUsecase,
      );

  static AmenityBloc get amenityBloc => AmenityBloc(
        getAmenityServicesUsecase: _getAmenityServicesUsecase,
        getMyAmenityTicketsUsecase: _getMyAmenityTicketsUsecase,
        createAmenityTicketUsecase: _createAmenityTicketUsecase,
      );

  // ==================== Reset ====================
  
  /// Reset all dependencies (useful for testing or logout)
  static void reset() {
    ApiClient.reset();
  }
}

