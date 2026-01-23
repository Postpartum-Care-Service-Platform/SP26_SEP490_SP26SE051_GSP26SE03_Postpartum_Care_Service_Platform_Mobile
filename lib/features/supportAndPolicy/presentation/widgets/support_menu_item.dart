import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';

/// Support menu item widget with icon, title and trailing chevron
class SupportMenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;
  final bool showTrailing;

  const SupportMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.iconColor,
    this.textColor,
    this.showTrailing = true,
  });

  @override
  State<SupportMenuItem> createState() => _SupportMenuItemState();
}

class _SupportMenuItemState extends State<SupportMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final defaultIconColor = widget.iconColor ?? AppColors.textPrimary;
    final defaultTextColor = widget.textColor ?? AppColors.textPrimary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12 * scale),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12 * scale),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16 * scale,
                vertical: 16 * scale,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40 * scale,
                    height: 40 * scale,
                    decoration: BoxDecoration(
                      color: (widget.iconColor ?? AppColors.primary)
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      size: 20 * scale,
                      color: defaultIconColor,
                    ),
                  ),
                  SizedBox(width: 16 * scale),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTextStyles.arimo(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w600,
                        color: defaultTextColor,
                      ),
                    ),
                  ),
                  if (widget.showTrailing)
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 24 * scale,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
