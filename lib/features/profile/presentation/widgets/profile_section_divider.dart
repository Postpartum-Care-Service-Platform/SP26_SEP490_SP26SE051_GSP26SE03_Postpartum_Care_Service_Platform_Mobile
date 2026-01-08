import 'package:flutter/material.dart';
import '../../../../core/utils/app_responsive.dart';

/// Divider widget for separating profile menu sections
class ProfileSectionDivider extends StatelessWidget {
  final double? height;

  const ProfileSectionDivider({
    super.key,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final dividerHeight = height ?? (16 * scale);

    return SizedBox(height: dividerHeight);
  }
}
