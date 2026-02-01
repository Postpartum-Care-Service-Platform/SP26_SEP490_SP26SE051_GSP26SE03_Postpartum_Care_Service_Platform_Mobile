import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/entities/menu_type_entity.dart';

/// Selected Menu Summary Widget
/// Shows selected menus grouped by meal type for a specific date
class SelectedMenuSummary extends StatelessWidget {
  final DateTime date;
  final Map<int, MenuEntity> selectedMenus; // menuTypeId -> MenuEntity
  final List<MenuTypeEntity> menuTypes;
  final Function(int menuTypeId)? onRemove;

  const SelectedMenuSummary({
    super.key,
    required this.date,
    required this.selectedMenus,
    required this.menuTypes,
    this.onRemove,
  });

  String _formatDate(DateTime date) {
    return '${date.day} ${AppFormatters.getMonthName(date.month)} ${date.year}';
  }

  MenuTypeEntity? _getMenuType(int menuTypeId) {
    try {
      return menuTypes.firstWhere((type) => type.id == menuTypeId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    if (selectedMenus.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 8 * scale),
        padding: EdgeInsets.all(20 * scale),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.textSecondary,
              size: 20 * scale,
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Text(
                AppStrings.menuNotSelectedForDate.replaceAll('{date}', _formatDate(date)),
                style: AppTextStyles.arimo(
                  fontSize: 14 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 8 * scale),
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: AppColors.primary,
                size: 20 * scale,
              ),
              SizedBox(width: 8 * scale),
              Text(
                AppStrings.menuSelected.replaceAll('{date}', _formatDate(date)),
                style: AppTextStyles.tinos(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),
          // Selected menus by type
          ...selectedMenus.entries.map((entry) {
            final menuType = _getMenuType(entry.key);
            final menu = entry.value;

            return Container(
              margin: EdgeInsets.only(bottom: 12 * scale),
              padding: EdgeInsets.all(12 * scale),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(
                  color: AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Menu type badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10 * scale,
                      vertical: 6 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    child: Text(
                      menuType?.name ?? menu.menuTypeName,
                      style: AppTextStyles.arimo(
                        fontSize: 11 * scale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 12 * scale),
                  // Menu name
                  Expanded(
                    child: Text(
                      menu.menuName,
                      style: AppTextStyles.tinos(
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  // Remove button
                  if (onRemove != null)
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                        size: 20 * scale,
                      ),
                      onPressed: () => onRemove!(entry.key),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: 32 * scale,
                        minHeight: 32 * scale,
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
