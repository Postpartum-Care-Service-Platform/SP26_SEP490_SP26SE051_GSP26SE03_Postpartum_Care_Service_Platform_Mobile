import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../widgets/support_menu_item.dart';

/// Support and Policy Screen - Main screen with menu items
class SupportAndPolicyScreen extends StatelessWidget {
  const SupportAndPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: AppStrings.supportAndPolicyTitle,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 8 * scale),
          children: [
            AppWidgets.sectionContainer(
              context,
              children: [
                SupportMenuItem(
                  icon: Icons.help_outline_rounded,
                  title: AppStrings.help,
                  onTap: () => AppRouter.push(context, AppRoutes.help),
                ),
                SupportMenuItem(
                  icon: Icons.contact_support_outlined,
                  title: AppStrings.contact,
                  onTap: () => AppRouter.push(context, AppRoutes.contact),
                ),
                SupportMenuItem(
                  icon: Icons.info_outline_rounded,
                  title: AppStrings.about,
                  onTap: () => AppRouter.push(context, AppRoutes.about),
                ),
                SupportMenuItem(
                  icon: Icons.description_outlined,
                  title: AppStrings.terms,
                  onTap: () => AppRouter.push(context, AppRoutes.terms),
                ),
                SupportMenuItem(
                  icon: Icons.lock_outline_rounded,
                  title: AppStrings.privacy,
                  onTap: () => AppRouter.push(context, AppRoutes.privacy),
                ),
              ],
            ),
            SizedBox(height: 24 * scale),
          ],
        ),
      ),
    );
  }
}
