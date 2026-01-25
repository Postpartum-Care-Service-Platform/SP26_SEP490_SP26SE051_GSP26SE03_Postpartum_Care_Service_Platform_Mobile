import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../domain/entities/menu_entity.dart';

/// Menu List Item Widget
class MenuListItem extends StatelessWidget {
  final MenuEntity menu;
  final bool isSelected;
  final VoidCallback onTap;

  const MenuListItem({
    super.key,
    required this.menu,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16 * scale),
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        child: Container(
          padding: EdgeInsets.all(16 * scale),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.white,
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.borderLight,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Menu type badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * scale,
                  vertical: 6 * scale,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
                child: Text(
                  menu.menuTypeName,
                  style: AppTextStyles.arimo(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(width: 12 * scale),
              // Menu name and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.menuName,
                      style: AppTextStyles.tinos(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (menu.description != null && menu.description!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4 * scale),
                        child: Text(
                          menu.description!,
                          style: AppTextStyles.arimo(
                            fontSize: 12 * scale,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (menu.foods.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 8 * scale),
                        child: Text(
                          '${menu.foods.length} món',
                          style: AppTextStyles.arimo(
                            fontSize: 11 * scale,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Selection indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24 * scale,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
