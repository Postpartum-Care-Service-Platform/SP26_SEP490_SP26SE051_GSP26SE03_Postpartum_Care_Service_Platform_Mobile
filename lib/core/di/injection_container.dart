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
import '../../features/auth/domain/usecases/change_password_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/family_profile/data/datasources/family_profile_remote_datasource.dart';
import '../../features/family_profile/data/repositories/family_profile_repository_impl.dart';
import '../../features/family_profile/domain/repositories/family_profile_repository.dart';
import '../../features/family_profile/domain/usecases/get_family_profiles_usecase.dart';
import '../../features/family_profile/domain/usecases/get_member_types_usecase.dart';
import '../../features/family_profile/domain/usecases/create_family_profile_usecase.dart';
import '../../features/family_profile/presentation/bloc/family_profile_bloc.dart';
import '../../features/notification/data/datasources/notification_datasource.dart';
import '../../features/notification/data/repositories/notification_repository_impl.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';
import '../../features/notification/domain/usecases/get_notifications_usecase.dart';
import '../../features/notification/domain/usecases/mark_notification_read_usecase.dart';
import '../../features/notification/domain/usecases/get_unread_count_usecase.dart';
import '../../features/notification/presentation/bloc/notification_bloc.dart';
import '../../features/package/data/datatsources/package_datasource.dart';
import '../../features/package/data/repositories/package_repository_impl.dart';
import '../../features/package/domain/repositories/package_repository.dart';
import '../../features/package/domain/usecases/get_packages_usecase.dart';
import '../../features/package/presentation/bloc/package_bloc.dart';
import '../../features/care_plan/data/datasources/care_plan_datasource.dart';
import '../../features/care_plan/data/repositories/care_plan_repository_impl.dart';
import '../../features/care_plan/domain/repositories/care_plan_repository.dart';
import '../../features/care_plan/domain/usecases/get_care_plan_details_usecase.dart';
import '../../features/care_plan/presentation/bloc/care_plan_bloc.dart';
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
import '../../features/employee/presentation/bloc/appointment/appointment_bloc.dart';
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
  
  static NotificationDataSource get _notificationDataSource =>
      NotificationDataSourceImpl();
  
  static PackageDataSource get _packageDataSource =>
      PackageDataSourceImpl();
  
  static CarePlanDataSource get _carePlanDataSource =>
      CarePlanDataSourceImpl();
  
  static AppointmentEmployeeRemoteDataSource get _appointmentEmployeeRemoteDataSource =>
      AppointmentEmployeeRemoteDataSource(dio: ApiClient.dio);
  
  static RoomRemoteDataSource get _roomRemoteDataSource =>
      RoomRemoteDataSource(dio: ApiClient.dio);
  
  static AmenityServiceRemoteDataSource get _amenityServiceRemoteDataSource =>
      AmenityServiceRemoteDataSource(dio: ApiClient.dio);
  
  static AmenityTicketRemoteDataSource get _amenityTicketRemoteDataSource =>
      AmenityTicketRemoteDataSource(dio: ApiClient.dio);

  // ==================== Repositories ====================
  
  static AuthRepository get authRepository =>
      AuthRepositoryImpl(remoteDataSource: _authRemoteDataSource);
  
  static AuthRepository get _authRepository => authRepository;
  
  static FamilyProfileRepository get familyProfileRepository =>
      FamilyProfileRepositoryImpl(remoteDataSource: _familyProfileRemoteDataSource);
  
  static NotificationRepository get notificationRepository =>
      NotificationRepositoryImpl(_notificationDataSource);
  
  static PackageRepository get packageRepository =>
      PackageRepositoryImpl(_packageDataSource);
  
  static CarePlanRepository get carePlanRepository =>
      CarePlanRepositoryImpl(_carePlanDataSource);
  
  static AppointmentEmployeeRepository get appointmentEmployeeRepository =>
      AppointmentEmployeeRepositoryImpl(remoteDataSource: _appointmentEmployeeRemoteDataSource);
  
  static RoomRepository get roomRepository =>
      RoomRepositoryImpl(remoteDataSource: _roomRemoteDataSource);
  
  static AmenityServiceRepository get amenityServiceRepository =>
      AmenityServiceRepositoryImpl(remoteDataSource: _amenityServiceRemoteDataSource);
  
  static AmenityTicketRepository get amenityTicketRepository =>
      AmenityTicketRepositoryImpl(remoteDataSource: _amenityTicketRemoteDataSource);

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
  static MarkNotificationReadUsecase get _markNotificationReadUsecase =>
      MarkNotificationReadUsecase(notificationRepository);
  static GetUnreadCountUsecase get _getUnreadCountUsecase =>
      GetUnreadCountUsecase(notificationRepository);
  
  static GetPackagesUsecase get _getPackagesUsecase =>
      GetPackagesUsecase(packageRepository);
  
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
    changePasswordUsecase: _changePasswordUsecase,
  );

  static FamilyProfileBloc get familyProfileBloc => FamilyProfileBloc(
        getFamilyProfilesUsecase: _getFamilyProfilesUsecase,
        getMemberTypesUsecase: _getMemberTypesUsecase,
        createFamilyProfileUsecase: _createFamilyProfileUsecase,
      );
  
  static NotificationBloc get notificationBloc => NotificationBloc(
        getNotificationsUsecase: _getNotificationsUsecase,
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
  static AppointmentBloc get appointmentBloc => AppointmentBloc(
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

  // ==================== Reset ====================
  
  /// Reset all dependencies (useful for testing or logout)
  static void reset() {
    ApiClient.reset();
  }
}

