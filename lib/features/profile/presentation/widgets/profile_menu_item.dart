import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';

/// Profile menu item widget with icon, title and trailing chevron
class ProfileMenuItem extends StatefulWidget {
  final IconData? icon;
  final String? svgIcon;
  final String title;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;
  final bool showTrailing;

  const ProfileMenuItem({
    super.key,
    this.icon,
    this.svgIcon,
    required this.title,
    this.onTap,
    this.iconColor,
    this.textColor,
    this.showTrailing = true,
  }) : assert(icon != null || svgIcon != null, 'Either icon or svgIcon must be provided');

  @override
  State<ProfileMenuItem> createState() => _ProfileMenuItemState();
}

class _ProfileMenuItemState extends State<ProfileMenuItem> {
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
                horizontal: 12 * scale,
                vertical: 12 * scale,
              ),
              child: Row(
                children: [
                  widget.svgIcon != null
                      ? SvgPicture.asset(
                          widget.svgIcon!,
                          width: 20 * scale,
                          height: 20 * scale,
                          colorFilter: ColorFilter.mode(
                            defaultIconColor,
                            BlendMode.srcIn,
                          ),
                        )
                      : Icon(
                          widget.icon,
                          size: 20 * scale,
                          color: defaultIconColor,
                        ),
                  SizedBox(width: 14 * scale),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTextStyles.arimo(
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.w600,
                        color: defaultTextColor,
                      ),
                    ),
                  ),
                  if (widget.showTrailing)
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18 * scale,
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
