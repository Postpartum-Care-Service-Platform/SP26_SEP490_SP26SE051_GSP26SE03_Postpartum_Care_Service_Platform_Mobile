import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/app_app_bar.dart';

/// Contact Screen - Contact information and support
class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: AppStrings.contactTitle,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16 * scale),
          children: [
            // Phone Section
            _buildContactCard(
              context,
              icon: Icons.phone_outlined,
              title: AppStrings.contactPhone,
              content: AppStrings.contactPhoneNumber,
              buttonText: AppStrings.contactCallNow,
              onButtonTap: () => _makePhoneCall(AppStrings.contactPhoneNumber),
            ),

            SizedBox(height: 16 * scale),

            // Email Section
            _buildContactCard(
              context,
              icon: Icons.email_outlined,
              title: AppStrings.contactEmail,
              content: AppStrings.contactEmailAddress,
              buttonText: AppStrings.contactSendEmail,
              onButtonTap: () => _sendEmail(AppStrings.contactEmailAddress),
            ),

            SizedBox(height: 16 * scale),

            // Address Section
            _buildInfoCard(
              context,
              icon: Icons.location_on_outlined,
              title: AppStrings.contactAddress,
              content: AppStrings.contactFullAddress,
            ),

            SizedBox(height: 16 * scale),

            // Working Hours Section
            _buildInfoCard(
              context,
              icon: Icons.access_time_outlined,
              title: AppStrings.contactWorkingHours,
              content: AppStrings.contactHours,
            ),

            SizedBox(height: 24 * scale),

            // Additional Info
            AppWidgets.sectionContainer(
              context,
              padding: EdgeInsets.all(16 * scale),
              children: [
                Text(
                  'Chúng tôi luôn sẵn sàng hỗ trợ bạn!',
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.normal,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8 * scale),
                Text(
                  'Nếu bạn có bất kỳ câu hỏi hoặc cần hỗ trợ, vui lòng liên hệ với chúng tôi qua số hotline hoặc email. Đội ngũ hỗ trợ của chúng tôi sẽ phản hồi trong thời gian sớm nhất.',
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.normal,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            SizedBox(height: 24 * scale),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required String buttonText,
    required VoidCallback onButtonTap,
  }) {
    final scale = AppResponsive.scaleFactor(context);

    return AppWidgets.sectionContainer(
      context,
      padding: EdgeInsets.all(20 * scale),
      children: [
        Row(
          children: [
            Container(
              width: 48 * scale,
              height: 48 * scale,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24 * scale,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 16 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    content,
                    style: AppTextStyles.arimo(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16 * scale),
        SizedBox(
          width: double.infinity,
          child: AppWidgets.secondaryButton(
            text: buttonText,
            onPressed: onButtonTap,
            icon: Icon(
              icon == Icons.phone_outlined ? Icons.phone : Icons.email,
              size: 20 * scale,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48 * scale,
              height: 48 * scale,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24 * scale,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 16 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    content,
                    style: AppTextStyles.arimo(
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
