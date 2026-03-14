import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_bottom_navigation_bar.dart';

class BookingCancelledScreen extends StatelessWidget {
  final String? message;

  const BookingCancelledScreen({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * scale),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 86 * scale,
                height: 86 * scale,
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cancel_outlined,
                  size: 44 * scale,
                  color: AppColors.red,
                ),
              ),
              SizedBox(height: 20 * scale),
              Text(
                AppStrings.bookingCancelledTitle,
                style: AppTextStyles.arimo(
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8 * scale),
              Text(
                message?.trim().isNotEmpty == true
                    ? message!.trim()
                    : AppStrings.bookingCancelledSubtitle,
                style: AppTextStyles.arimo(
                  fontSize: 14 * scale,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28 * scale),
              AppWidgets.primaryButton(
                text: AppStrings.bookingCancelledBackToServices,
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const AppScaffold(
                        initialTab: AppBottomTab.services,
                      ),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

