import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';

class InvoiceSection extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const InvoiceSection({
    super.key,
    required this.title,
    required this.child,
    this.isExpanded = true,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ).copyWith(letterSpacing: 0.5),
                ),
                if (onToggle != null)
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20 * scale,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ),
          if (isExpanded) ...[
            SizedBox(height: 16 * scale),
            child,
          ],
        ],
      ),
    );
  }
}
