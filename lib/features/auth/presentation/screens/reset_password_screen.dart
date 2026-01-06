import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/auth_scaffold.dart';
import '../widgets/reset_password_form_widget.dart';
import '../widgets/reset_password_footer_widget.dart';
import '../widgets/login_logo_widget.dart';
import 'sign_up_screen.dart';
import 'login_screen.dart';

/// Reset Password Screen - UI based on Figma
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      footer: ResetPasswordFooterWidget(
        onSignIn: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
          );
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
      children: [
        const LoginLogoWidget(),
        const SizedBox(height: 48),
        Text(
          AppStrings.resetYourPassword,
          textAlign: TextAlign.center,
          style: AppTextStyles.tinos(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.resetPasswordDescription,
          textAlign: TextAlign.center,
          style: AppTextStyles.arimo(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ).copyWith(height: 1.5),
        ),
        const SizedBox(height: 32),
        const ResetPasswordFormWidget(),
        const SizedBox(height: 32),
      ],
    );
  }
}

