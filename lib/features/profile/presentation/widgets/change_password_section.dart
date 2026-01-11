import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';
import 'change_password_form.dart';

/// Change password section with title, description, and form
class ChangePasswordSection extends StatelessWidget {
  const ChangePasswordSection({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppWidgets.sectionHeader(
          context,
          title: AppStrings.accountSecurityTitle,
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20 * scale),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 14 * scale,
                offset: Offset(0, 6 * scale),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16 * scale,
              16 * scale,
              16 * scale,
              20 * scale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.changePasswordTitle,
                  style: AppTextStyles.tinos(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  AppStrings.changePasswordDescription,
                  style: AppTextStyles.arimo(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.normal,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 16 * scale),
                const ChangePasswordForm(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
