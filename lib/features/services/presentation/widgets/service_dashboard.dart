import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/app_routes.dart';
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
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.background,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20 * scale,
            20 * scale,
            20 * scale,
            24 * scale,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(context, scale),
              SizedBox(height: 24 * scale),
              
              // Key Card - First element after header
              ResortKeyCard(nowPackage: nowPackage),
              SizedBox(height: 24 * scale),
              
              // Services Section
              _buildServicesSection(context, scale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, double scale) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Chào buổi sáng';
    } else if (hour < 18) {
      greeting = 'Chào buổi chiều';
    } else {
      greeting = 'Chào buổi tối';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: AppTextStyles.tinos(
            fontSize: 28 * scale,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 6 * scale),
        Text(
          AppStrings.servicesResortExperienceDescription,
          style: AppTextStyles.arimo(
            fontSize: 14 * scale,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection(BuildContext context, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner Header
        _buildServicesBanner(context, scale),
        SizedBox(height: 20 * scale),
        
        // Services Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16 * scale,
          mainAxisSpacing: 16 * scale,
          childAspectRatio: 1.0,
          children: [
            ServiceActionCard(
              iconWidget: SvgPicture.asset(
                AppAssets.calendarBold,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              title: AppStrings.servicesDailySchedule,
              onTap: () => AppRouter.push(context, AppRoutes.familySchedule),
            ),
            ServiceActionCard(
              iconWidget: SvgPicture.asset(
                AppAssets.menuFirst,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              title: AppStrings.servicesTodayMenu,
              onTap: () => AppRouter.push(context, AppRoutes.myMenu),
            ),
            ServiceActionCard(
              iconWidget: SvgPicture.asset(
                AppAssets.menuSecond,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              title: AppStrings.feedBackForService,
              onTap: () => AppRouter.push(context, AppRoutes.feedback),
            ),
            ServiceActionCard(
              iconWidget: SvgPicture.asset(
                AppAssets.serviceAmenity,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              title: AppStrings.servicesAmenityRequest,
              onTap: () => AppRouter.push(context, AppRoutes.amenity),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServicesBanner(BuildContext context, double scale) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1.2 * scale,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 16 * scale,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with decorative background
          Container(
            padding: EdgeInsets.all(8 * scale),
            child: SvgPicture.asset(
              AppAssets.helper,
              fit: BoxFit.contain,
              width: 28 * scale,
              height: 28 * scale,
            ),
          ),
          SizedBox(width: 12 * scale),
          // Title Section - Centered
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.servicesResortAmenities,
                style: AppTextStyles.tinos(
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2 * scale),
              Text(
                AppStrings.servicesExploreAmenities,
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(width: 12 * scale),
          // Helper icon at the end
          Container(
            padding: EdgeInsets.all(8 * scale),
            child: SvgPicture.asset(
              AppAssets.helper,
              fit: BoxFit.contain,
              width: 28 * scale,
              height: 28 * scale,
            ),
          ),
        ],
      ),
    );
  }

}
