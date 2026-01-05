import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import '../widgets/reset_password_form_widget.dart';
import '../widgets/reset_password_footer_widget.dart';
import '../widgets/login_logo_widget.dart';
import 'sign_up_screen.dart';

/// Reset Password Screen - UI based on Figma
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 600;
    final contentWidth = AppResponsive.maxContentWidth(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppResponsive.pagePadding(context),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: AppResponsive.topSpacing(context)),
                const LoginLogoWidget(),
                const SizedBox(height: 48),
                
                // Title and description in a centered container
                Container(
                  width: contentWidth,
                  padding: isWide ? const EdgeInsets.symmetric(horizontal: 24) : null,
                  child: Column(
                    children: [
                      Text(
                        AppStrings.resetYourPassword,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.tinos(
                          fontSize: isWide ? 20 : 16,
                          fontWeight: FontWeight.normal,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.resetPasswordDescription,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.arimo(
                          fontSize: isWide ? 16 : 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.textPrimary,
                        ).copyWith(height: 1.5), // Better line height for readability
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Form with max width
                Center(
                  child: Container(
                    width: contentWidth,
                    padding: isWide ? const EdgeInsets.symmetric(horizontal: 24) : null,
                    child: const ResetPasswordFormWidget(),
                  ),
                ),
                
                const SizedBox(height: 32),

                // Footer with max width
                Container(
                  width: contentWidth,
                  padding: isWide ? const EdgeInsets.symmetric(horizontal: 24) : null,
                  child: ResetPasswordFooterWidget(
                    onSignIn: () {
                      Navigator.pop(context);
                    },
                    onSignUp: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignUpScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

