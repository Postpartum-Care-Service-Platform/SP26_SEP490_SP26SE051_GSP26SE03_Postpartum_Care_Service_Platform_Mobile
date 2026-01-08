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
import '../../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../family_profile/presentation/screens/family_profile_screen.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthRepository _authRepository = InjectionContainer.authRepository;
  String? _userName;
  String? _userEmail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentAccount();
  }

  Future<void> _loadCurrentAccount() async {
    try {
      final user = await _authRepository.getCurrentAccount();
      if (mounted) {
        setState(() {
          _userName = user.username;
          _userEmail = user.email;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
      AppToast.showSuccess(
        context,
        message: AppStrings.successLogout,
      );

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
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            ProfileHeader(
              userName: _userName,
              userEmail: _userEmail,
              isLoading: _isLoading,
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8 * scale),
                children: [
                  AppWidgets.sectionHeader(context, title: 'Tài khoản'),
                  AppWidgets.sectionContainer(
                    context,
                    children: [
                      ProfileMenuItem(
                        icon: Icons.person_outline_rounded,
                        title: AppStrings.myAccount,
                        onTap: () {
                          // TODO: Navigate to my account
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.people_outline,
                        title: AppStrings.familyProfile,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) => InjectionContainer.familyProfileBloc,
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
                          // TODO: Navigate to medical records
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.description_outlined,
                        title: AppStrings.contract,
                        onTap: () {
                          // TODO: Navigate to contract
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.history_rounded,
                        title: AppStrings.bookingHistory,
                        onTap: () {
                          // TODO: Navigate to booking history
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 12 * scale),

                  AppWidgets.sectionHeader(context, title: 'Hỗ trợ'),
                  AppWidgets.sectionContainer(
                    context,
                    children: [
                      ProfileMenuItem(
                        icon: Icons.help_outline_rounded,
                        title: AppStrings.help,
                        onTap: () {
                          // TODO: Navigate to help
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.contact_support_outlined,
                        title: AppStrings.contact,
                        onTap: () {
                          // TODO: Navigate to contact
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.info_outline_rounded,
                        title: AppStrings.about,
                        onTap: () {
                          // TODO: Navigate to about
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 12 * scale),

                  AppWidgets.sectionHeader(context, title: 'Pháp lý'),
                  AppWidgets.sectionContainer(
                    context,
                    children: [
                      ProfileMenuItem(
                        icon: Icons.description_outlined,
                        title: AppStrings.terms,
                        onTap: () {
                          // TODO: Navigate to terms
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.lock_outline_rounded,
                        title: AppStrings.privacy,
                        onTap: () {
                          // TODO: Navigate to privacy
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
  }
}
