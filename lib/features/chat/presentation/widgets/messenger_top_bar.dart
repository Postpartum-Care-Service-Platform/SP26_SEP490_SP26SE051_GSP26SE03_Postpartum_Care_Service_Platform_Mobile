import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';

class MessengerTopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback? onSupport;

  const MessengerTopBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
    this.onSupport,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18 * scale, sigmaY: 18 * scale),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            8 * scale,
            topPadding + 8 * scale,
            8 * scale,
            10 * scale,
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.75),
            border: Border(
              bottom: BorderSide(
                color: Colors.black.withValues(alpha: 0.06),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primary,
                  size: 18 * scale,
                ),
              ),
              Container(
                width: 36 * scale,
                height: 36 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.06),
                ),
                child: Padding(
                  padding: EdgeInsets.all(4 * scale),
                  child: SvgPicture.asset(
                    AppAssets.appIconThird,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: 10 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.arimo(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.arimo(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onSupport != null)
                IconButton(
                  onPressed: onSupport,
                  icon: Icon(Icons.support_agent_rounded,
                      color: AppColors.primary, size: 20 * scale),
                  tooltip: 'Hỗ trợ',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

