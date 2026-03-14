import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';

class ChatHeader extends StatelessWidget {
  /// null nếu không cho phép tạo cuộc hội thoại mới (staff mode).
  final VoidCallback? onCreateConversation;

  const ChatHeader({
    super.key,
    this.onCreateConversation,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48 * scale,
              height: 48 * scale,
              padding: EdgeInsets.all(8 * scale),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                AppAssets.appIcon,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.chatTitle,
                    style: AppTextStyles.tinos(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    AppStrings.chatSubtitle,
                    style: AppTextStyles.arimo(
                      fontSize: 13 * scale,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (onCreateConversation != null) ...[
          SizedBox(height: 12 * scale),
          AppWidgets.secondaryButton(
            text: AppStrings.chatNewConversation,
            onPressed: onCreateConversation!,
            height: 44 * scale,
          ),
        ],
      ],
    );
  }
}

