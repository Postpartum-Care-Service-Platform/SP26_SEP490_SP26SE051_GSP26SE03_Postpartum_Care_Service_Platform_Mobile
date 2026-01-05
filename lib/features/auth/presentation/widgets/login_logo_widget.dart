import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/app_text_styles.dart';

/// Login Logo Widget - Displays the app logo and name
class LoginLogoWidget extends StatelessWidget {
  const LoginLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo icon from Figma (SVG)
        SvgPicture.asset(
          AppAssets.appIcon,
          width: 39.986,
          height: 39.986,
          placeholderBuilder: (context) {
            // Show placeholder while loading
            return Container(
              width: 39.986,
              height: 39.986,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: const Icon(
                Icons.home,
                color: AppColors.white,
                size: 24,
              ),
            );
          },
        ),
        const SizedBox(width: 7.997),
        // App name
        Text(
          AppStrings.appName,
          style: AppTextStyles.tinos(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

