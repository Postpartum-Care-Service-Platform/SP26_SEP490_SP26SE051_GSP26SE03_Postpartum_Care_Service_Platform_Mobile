import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../screens/notification_screen.dart';

/// Notification filter tabs widget
class NotificationFilterTabs extends StatelessWidget {
  final NotificationFilter currentFilter;
  final ValueChanged<NotificationFilter> onFilterChanged;
  final int unreadCount;

  const NotificationFilterTabs({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Row(
      children: [
        _FilterTab(
          scale: scale,
          label: 'Tất cả',
          filter: NotificationFilter.all,
          isSelected: currentFilter == NotificationFilter.all,
          onTap: () => onFilterChanged(NotificationFilter.all),
        ),
        SizedBox(width: 8 * scale),
        _FilterTab(
          scale: scale,
          label: 'Chưa đọc',
          filter: NotificationFilter.unread,
          isSelected: currentFilter == NotificationFilter.unread,
          badge: unreadCount > 0 ? unreadCount : null,
          onTap: () => onFilterChanged(NotificationFilter.unread),
        ),
        SizedBox(width: 8 * scale),
        _FilterTab(
          scale: scale,
          label: 'Đã đọc',
          filter: NotificationFilter.read,
          isSelected: currentFilter == NotificationFilter.read,
          onTap: () => onFilterChanged(NotificationFilter.read),
        ),
      ],
    );
  }
}

class _FilterTab extends StatelessWidget {
  final double scale;
  final String label;
  final NotificationFilter filter;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badge;

  const _FilterTab({
    required this.scale,
    required this.label,
    required this.filter,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12 * scale),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12 * scale,
              vertical: 10 * scale,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.white,
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: AppTextStyles.arimo(
                      fontSize: 13 * scale,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? AppColors.white : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (badge != null && badge! > 0) ...[
                  SizedBox(width: 6 * scale),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6 * scale,
                      vertical: 2 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.white.withValues(alpha: 0.2)
                          : AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10 * scale),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 20 * scale,
                      minHeight: 20 * scale,
                    ),
                    child: Text(
                      badge! > 9 ? '9+' : '$badge',
                      style: AppTextStyles.arimo(
                        fontSize: 11 * scale,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? AppColors.white : AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
