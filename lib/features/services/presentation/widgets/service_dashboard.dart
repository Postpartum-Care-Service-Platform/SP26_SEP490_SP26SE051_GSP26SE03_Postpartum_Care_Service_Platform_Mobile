import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/data/models/current_account_model.dart';
import 'resort_key_card.dart';
import 'service_action_card.dart';

class ServiceDashboard extends StatelessWidget {
  final NowPackageModel nowPackage;

  const ServiceDashboard({
    super.key,
    required this.nowPackage,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding:
            EdgeInsets.fromLTRB(20 * scale, 16 * scale, 20 * scale, 24 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(scale),
            SizedBox(height: 12 * scale),
            Text(
              AppStrings.servicesResortExperience,
              style: AppTextStyles.tinos(
                fontSize: 22 * scale,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4 * scale),
            Text(
              AppStrings.servicesResortExperienceDescription,
              style: AppTextStyles.arimo(
                fontSize: 13 * scale,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 20 * scale),
            ResortKeyCard(nowPackage: nowPackage),
            SizedBox(height: 20 * scale),
            AppWidgets.sectionHeader(
              context,
              title: AppStrings.servicesResortAmenities,
            ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12 * scale,
              mainAxisSpacing: 12 * scale,
              childAspectRatio: 1.2,
              children: [
                ServiceActionCard(
                  icon: Icons.schedule_rounded,
                  title: AppStrings.servicesDailySchedule,
                  subtitle: AppStrings.servicesDailyScheduleDescription,
                  onTap: () => _showComingSoon(context),
                ),
                ServiceActionCard(
                  icon: Icons.restaurant_menu_rounded,
                  title: AppStrings.servicesTodayMenu,
                  subtitle: AppStrings.servicesTodayMenuDescription,
                  onTap: () => _showComingSoon(context),
                ),
                ServiceActionCard(
                  icon: Icons.spa_rounded,
                  title: AppStrings.servicesSpaRegistration,
                  subtitle: AppStrings.servicesSpaRegistrationDescription,
                  onTap: () => _showComingSoon(context),
                ),
                ServiceActionCard(
                  icon: Icons.room_service_rounded,
                  title: AppStrings.servicesAmenityRequest,
                  subtitle: AppStrings.servicesAmenityRequestDescription,
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * scale),
      child: Row(
        children: [
          SizedBox(
            width: 52 * scale,
            child: const SizedBox.shrink(),
          ),
          Expanded(
            child: Text(
              AppStrings.bookingTitle,
              style: AppTextStyles.tinos(
                fontSize: 22 * scale,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 52 * scale),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    AppToast.showInfo(
      context,
      message: AppStrings.featureUnderDevelopment,
    );
  }
}
