import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/auth_scaffold.dart';
import '../widgets/login_logo_widget.dart';
import '../widgets/sign_up_form_widget.dart';
import '../widgets/sign_up_footer_widget.dart';

/// Sign Up Screen - built based on existing auth screens
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = AppResponsive.isTablet(context);

    return AuthScaffold(
      footer: SignUpFooterWidget(
        onSignIn: () => Navigator.pop(context),
      ),
      children: [
        const LoginLogoWidget(),
        const SizedBox(height: 48),
        Text(
          AppStrings.signUpTitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.tinos(
            fontSize: isWide ? 20 : 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.signUpDescription,
          textAlign: TextAlign.center,
          style: AppTextStyles.arimo(
            fontSize: isWide ? 16 : 14,
            fontWeight: FontWeight.normal,
          ).copyWith(height: 1.5),
        ),
        const SizedBox(height: 32),
        const SignUpFormWidget(),
      ],
    );
  }
}

