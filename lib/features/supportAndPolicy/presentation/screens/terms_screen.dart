import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/app_app_bar.dart';

/// Terms Screen - Terms of service
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final currentDate = DateTime.now();
    final formattedDate =
        '${currentDate.day}/${currentDate.month}/${currentDate.year}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: AppStrings.termsTitle,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16 * scale),
          children: [
            // Last Updated
            Center(
              child: Text(
                AppStrings.termsLastUpdated.replaceAll('{date}', formattedDate),
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            SizedBox(height: 24 * scale),

            // Section 1
            _buildSection(
              context,
              title: AppStrings.termsSection1,
              content: AppStrings.termsSection1Content,
            ),

            SizedBox(height: 16 * scale),

            // Section 2
            _buildSection(
              context,
              title: AppStrings.termsSection2,
              content: AppStrings.termsSection2Content,
            ),

            SizedBox(height: 16 * scale),

            // Section 3
            _buildSection(
              context,
              title: AppStrings.termsSection3,
              content: AppStrings.termsSection3Content,
            ),

            SizedBox(height: 16 * scale),

            // Section 4
            _buildSection(
              context,
              title: AppStrings.termsSection4,
              content: AppStrings.termsSection4Content,
            ),

            SizedBox(height: 16 * scale),

            // Section 5
            _buildSection(
              context,
              title: AppStrings.termsSection5,
              content: AppStrings.termsSection5Content,
            ),

            SizedBox(height: 24 * scale),

            // Note
            AppWidgets.sectionContainer(
              context,
              padding: EdgeInsets.all(16 * scale),
              color: AppColors.primary.withValues(alpha: 0.05),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20 * scale,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 12 * scale),
                    Expanded(
                      child: Text(
                        'Nếu bạn có bất kỳ câu hỏi nào về các điều khoản này, vui lòng liên hệ với chúng tôi qua mục "Liên hệ".',
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
    required String title,
    required String content,
  }) {
    final scale = AppResponsive.scaleFactor(context);

    return AppWidgets.sectionContainer(
      context,
      padding: EdgeInsets.all(20 * scale),
      children: [
        Text(
          title,
          style: AppTextStyles.tinos(
            fontSize: 18 * scale,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
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
