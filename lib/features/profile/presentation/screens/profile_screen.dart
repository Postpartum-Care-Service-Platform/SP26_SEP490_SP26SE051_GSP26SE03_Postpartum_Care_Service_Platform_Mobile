import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../family_profile/presentation/screens/family_profile_screen.dart';
import '../../../booking/presentation/screens/booking_history_screen.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';
import 'account_details_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await AppWidgets.showConfirmDialog(
      context,
      title: AppStrings.logoutTitle,
      message: AppStrings.logoutConfirmation,
      confirmText: AppStrings.logout,
      cancelText: AppStrings.cancel,
      confirmColor: AppColors.logout,
      icon: Icons.logout_rounded,
    );

    if (confirmed != true) return;

    // Clear authentication data
    await AuthService.logout();

    // Reset API client
    ApiClient.reset();

    if (context.mounted) {
      AppToast.showSuccess(context, message: AppStrings.successLogout);

      // Navigate to login screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String? userId;
        String? userName;
        String? userEmail;
        String? avatarUrl;
        bool isEmailVerified = false;
        bool isLoading = true;

        if (authState is AuthCurrentAccountLoaded) {
          userId = authState.account.id;
          userName = authState.account.displayName;
          userEmail = authState.account.email;
          avatarUrl = authState.account.avatarUrl;
          isEmailVerified = authState.account.isEmailVerified;
          isLoading = false;
        } else if (authState is AuthLoading) {
          isLoading = true;
        } else {
          isLoading = false;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                ProfileHeader(
                  userName: userName,
                  userEmail: userEmail,
                  avatarUrl: avatarUrl,
                  isEmailVerified: isEmailVerified,
                  isLoading: isLoading,
                ),

                // Menu Items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 8 * scale),
                    children: [
                      AppWidgets.sectionHeader(context, title: AppStrings.account),
                      AppWidgets.sectionContainer(
                        context,
                        children: [
                          ProfileMenuItem(
                            icon: Icons.person_outline_rounded,
                            title: AppStrings.myAccount,
                            onTap: () {
                              if (userId == null) return;
                              // Get AuthBloc from context to share with AccountDetailsScreen
                              final authBloc = context.read<AuthBloc>();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: authBloc,
                                    child: AccountDetailsScreen(
                                      userId: userId!,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          ProfileMenuItem(
                            icon: Icons.people_outline,
                            title: AppStrings.familyProfile,
                            onTap: () {
                              // Get AuthBloc from context to share with FamilyProfileScreen
                              final authBloc = context.read<AuthBloc>();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => MultiBlocProvider(
                                    providers: [
                                      BlocProvider.value(value: authBloc),
                                      BlocProvider(
                                        create: (_) => InjectionContainer
                                            .familyProfileBloc,
                                      ),
                                    ],
                                    child: const FamilyProfileScreen(),
                                  ),
                                ),
                              );
                            },
                          ),
                          ProfileMenuItem(
                            icon: Icons.medical_information_outlined,
                            title: AppStrings.medicalRecords,
                            onTap: () {
       
                            },
                          ),
                          ProfileMenuItem(
                            icon: Icons.description_outlined,
                            title: AppStrings.contract,
                            onTap: () {
             
                            },
                          ),
                          ProfileMenuItem(
                            icon: Icons.history_rounded,
                            title: AppStrings.bookingHistory,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const BookingHistoryScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 12 * scale),

                      AppWidgets.sectionHeader(context, title: AppStrings.helpandPolicy),
                      AppWidgets.sectionContainer(
                        context,
                        children: [
                          ProfileMenuItem(
                            icon: Icons.help_outline_rounded,
                            title: AppStrings.help,
                            onTap: () {
                 
                            },
                          ),
                          ProfileMenuItem(
                            icon: Icons.contact_support_outlined,
                            title: AppStrings.contact,
                            onTap: () {
            
                            },
                          ),
                          ProfileMenuItem(
                            icon: Icons.info_outline_rounded,
                            title: AppStrings.about,
                            onTap: () {
            
                            },
                          ),
                          ProfileMenuItem(
                            icon: Icons.description_outlined,
                            title: AppStrings.terms,
                            onTap: () {
           
                            },
                          ),
                          ProfileMenuItem(
                            icon: Icons.lock_outline_rounded,
                            title: AppStrings.privacy,
                            onTap: () {
              
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 12 * scale),

                      AppWidgets.sectionContainer(
                        context,
                        children: [
                          ProfileMenuItem(
                            icon: Icons.logout_rounded,
                            title: AppStrings.logout,
                            onTap: () => _handleLogout(context),
                            iconColor: AppColors.logout,
                            textColor: AppColors.logout,
                          ),
                        ],
                      ),

                      SizedBox(height: 24 * scale),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
