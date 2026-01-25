import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/entities/menu_type_entity.dart';

/// Unsaved Menu Selections Card Widget
/// Displays menu selections that have not been saved yet
class UnsavedMenuSelectionsCard extends StatelessWidget {
  final DateTime date;
  final Map<int, MenuEntity> unsavedSelections; // menuTypeId -> MenuEntity
  final List<MenuTypeEntity> menuTypes;
  final Function(int menuTypeId)? onRemove;

  const UnsavedMenuSelectionsCard({
    super.key,
    required this.date,
    required this.unsavedSelections,
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

    if (unsavedSelections.isEmpty) {
      return const SizedBox.shrink();
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
          // Header with unsaved badge
          Row(
            children: [
              Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
                size: 20 * scale,
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: Text(
                  AppStrings.menuSelecting.replaceAll('{date}', _formatDate(date)),
                  style: AppTextStyles.tinos(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8 * scale,
                  vertical: 4 * scale,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6 * scale),
                ),
                child: Text(
                  AppStrings.menuNotSaved,
                  style: AppTextStyles.arimo(
                    fontSize: 10 * scale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),
          // Unsaved selections
          ...unsavedSelections.entries.map((entry) {
            final menuType = _getMenuType(entry.key);
            final menu = entry.value;

            return Container(
              margin: EdgeInsets.only(bottom: 12 * scale),
              padding: EdgeInsets.all(12 * scale),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
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
