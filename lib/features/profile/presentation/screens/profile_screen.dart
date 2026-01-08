import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/apis/api_client.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.logoutTitle),
        content: const Text(AppStrings.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.profileTitle),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                AppStrings.profileScreen,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              AppWidgets.primaryButton(
                text: AppStrings.logout,
                onPressed: () => _handleLogout(context),
                isEnabled: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

