import 'package:flutter/material.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';

/// Login Footer Widget - Contains sign up and forgot password links
class LoginFooterWidget extends StatelessWidget {
  final VoidCallback? onSignUp;
  final VoidCallback? onForgotPassword;

  const LoginFooterWidget({
    super.key,
    this.onSignUp,
    this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Need an account? Sign up
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.needAnAccount,
              style: AppTextStyles.arimo(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            AppWidgets.linkText(
              text: AppStrings.signUp,
              onTap: onSignUp ?? () {},
            ),
          ],
        ),
        const SizedBox(height: 7.997),
        // Forgot password? Reset it
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppWidgets.linkText(
              text: AppStrings.resetIt,
              onTap: onForgotPassword ?? () {},
            ),
          ],
        ),
      ],
    );
  }
}

