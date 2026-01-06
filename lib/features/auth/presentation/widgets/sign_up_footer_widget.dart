import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';

/// Sign Up footer - keep consistent with other auth screens
class SignUpFooterWidget extends StatelessWidget {
  final VoidCallback? onSignIn;

  const SignUpFooterWidget({
    super.key,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.alreadyHaveAccount,
          style: AppTextStyles.arimo(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        AppWidgets.linkText(
          text: AppStrings.signIn,
          onTap: onSignIn ?? () {},
        ),
      ],
    );
  }
}

