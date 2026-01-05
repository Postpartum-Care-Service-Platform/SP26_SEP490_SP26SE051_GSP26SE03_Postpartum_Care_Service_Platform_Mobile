import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';

/// Footer for Reset Password screen
class ResetPasswordFooterWidget extends StatelessWidget {
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  const ResetPasswordFooterWidget({
    super.key,
    required this.onSignIn,
    required this.onSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.rememberYourPassword,
              style: AppTextStyles.arimo(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            AppWidgets.linkText(
              text: AppStrings.signIn,
              onTap: onSignIn,
            ),
          ],
        ),
        const SizedBox(height: 7.997),
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
              onTap: onSignUp,
            ),
          ],
        ),
      ],
    );
  }
}

