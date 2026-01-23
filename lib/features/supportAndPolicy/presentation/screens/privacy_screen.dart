import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/app_app_bar.dart';

/// Privacy Screen - Privacy policy
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final currentDate = DateTime.now();
    final formattedDate =
        '${currentDate.day}/${currentDate.month}/${currentDate.year}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: AppStrings.privacyTitle,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16 * scale),
          children: [
            // Last Updated
            Center(
              child: Text(
                AppStrings.privacyLastUpdated.replaceAll('{date}', formattedDate),
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            SizedBox(height: 24 * scale),

            // Introduction
            AppWidgets.sectionContainer(
              context,
              padding: EdgeInsets.all(20 * scale),
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 24 * scale,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 12 * scale),
                    Expanded(
                      child: Text(
                        AppStrings.privacyIntroduction,
                        style:                         AppTextStyles.arimo(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.normal,
                          color: AppColors.textPrimary,
                        ).copyWith(height: 1.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16 * scale),

            // Section 1
            _buildSection(
              context,
              icon: Icons.info_outlined,
              title: AppStrings.privacySection1,
              content: AppStrings.privacySection1Content,
            ),

            SizedBox(height: 16 * scale),

            // Section 2
            _buildSection(
              context,
              icon: Icons.settings_outlined,
              title: AppStrings.privacySection2,
              content: AppStrings.privacySection2Content,
            ),

            SizedBox(height: 16 * scale),

            // Section 3
            _buildSection(
              context,
              icon: Icons.security_outlined,
              title: AppStrings.privacySection3,
              content: AppStrings.privacySection3Content,
            ),

            SizedBox(height: 16 * scale),

            // Section 4
            _buildSection(
              context,
              icon: Icons.share_outlined,
              title: AppStrings.privacySection4,
              content: AppStrings.privacySection4Content,
            ),

            SizedBox(height: 16 * scale),

            // Section 5
            _buildSection(
              context,
              icon: Icons.account_circle_outlined,
              title: AppStrings.privacySection5,
              content: AppStrings.privacySection5Content,
            ),

            SizedBox(height: 24 * scale),

            // Contact Note
            AppWidgets.sectionContainer(
              context,
              padding: EdgeInsets.all(16 * scale),
              color: AppColors.primary.withValues(alpha: 0.05),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.contact_support_outlined,
                      size: 20 * scale,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 12 * scale),
                    Expanded(
                      child: Text(
                        'Để thực hiện các quyền của bạn hoặc có câu hỏi về chính sách bảo mật, vui lòng liên hệ với chúng tôi qua mục "Liên hệ".',
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.normal,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 24 * scale),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    final scale = AppResponsive.scaleFactor(context);

    return AppWidgets.sectionContainer(
      context,
      padding: EdgeInsets.all(20 * scale),
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 24 * scale,
              color: AppColors.primary,
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.tinos(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12 * scale),
        Text(
          content,
          style:           AppTextStyles.arimo(
            fontSize: 15 * scale,
            fontWeight: FontWeight.normal,
            color: AppColors.textSecondary,
          ).copyWith(height: 1.6),
        ),
      ],
    );
  }
}
