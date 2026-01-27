import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/app_app_bar.dart';

/// About Screen - Information about the company
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: AppStrings.aboutTitle,
        centerTitle: true,
        titleFontSize: 20 * scale,
        titleFontWeight: FontWeight.w700,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16 * scale),
          children: [
            // App Logo/Icon Section
            Center(
              child: Container(
                width: 120 * scale,
                height: 120 * scale,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(20 * scale),
                child: SvgPicture.asset(
                  'assets/images/app_icon_3.svg',
                  width: 80 * scale,
                  height: 80 * scale,
                ),
              ),
            ),

            SizedBox(height: 24 * scale),

            // App Name
            Center(
              child: Text(
                AppStrings.appName,
                style: AppTextStyles.tinos(
                  fontSize: 28 * scale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            SizedBox(height: 8 * scale),

            Center(
              child: Text(
                AppStrings.tagline,
                style: AppTextStyles.arimo(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            SizedBox(height: 32 * scale),

            // Description
            AppWidgets.sectionContainer(
              context,
              padding: EdgeInsets.all(20 * scale),
              children: [
                Text(
                  AppStrings.aboutDescription,
                  style:                   AppTextStyles.arimo(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.normal,
                    color: AppColors.textPrimary,
                  ).copyWith(height: 1.6),
                ),
              ],
            ),

            SizedBox(height: 24 * scale),

            // Mission Section
            _buildSection(
              context,
              icon: Icons.flag_outlined,
              title: AppStrings.aboutMission,
              content: AppStrings.aboutMissionContent,
            ),

            SizedBox(height: 16 * scale),

            // Vision Section
            _buildSection(
              context,
              icon: Icons.remove_red_eye_outlined,
              title: AppStrings.aboutVision,
              content: AppStrings.aboutVisionContent,
            ),

            SizedBox(height: 16 * scale),

            // Values Section
            AppWidgets.sectionContainer(
              context,
              padding: EdgeInsets.all(20 * scale),
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite_outline_rounded,
                      size: 24 * scale,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 12 * scale),
                    Text(
                      AppStrings.aboutValues,
                      style: AppTextStyles.tinos(
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20 * scale),
                _buildValueItem(
                  context,
                  icon: Icons.favorite_rounded,
                  text: AppStrings.aboutValue1,
                ),
                SizedBox(height: 12 * scale),
                _buildValueItem(
                  context,
                  icon: Icons.verified_outlined,
                  text: AppStrings.aboutValue2,
                ),
                SizedBox(height: 12 * scale),
                _buildValueItem(
                  context,
                  icon: Icons.security_outlined,
                  text: AppStrings.aboutValue3,
                ),
                SizedBox(height: 12 * scale),
                _buildValueItem(
                  context,
                  icon: Icons.trending_up_outlined,
                  text: AppStrings.aboutValue4,
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
            Text(
              title,
              style: AppTextStyles.tinos(
                fontSize: 20 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
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

  Widget _buildValueItem(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final scale = AppResponsive.scaleFactor(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 20 * scale,
          color: AppColors.primary,
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.arimo(
              fontSize: 15 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
