import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_assets.dart';

/// Google Sign In Button Widget
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Google icon - Using Material icon as placeholder
    // Replace with actual Google icon asset when available
    return AppWidgets.secondaryButton(
      text: AppStrings.google,
      onPressed: onPressed,
      icon: SvgPicture.asset(
        AppAssets.googleIcon,
        width: 15.995,
        height: 15.995,
        placeholderBuilder: (context) {
          // Show placeholder while loading
          return const Icon(
            Icons.g_mobiledata,
            size: 15.995,
            color: Colors.black,
          );
        },
      ),
    );
  }
}

