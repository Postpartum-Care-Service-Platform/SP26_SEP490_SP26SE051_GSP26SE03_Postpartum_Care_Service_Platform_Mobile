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
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10 * scale,
                offset: Offset(0, 4 * scale),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top badge spanning the card
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * scale,
                  vertical: 6 * scale,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.16),
                      AppColors.primary.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(999 * scale),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      menu.menuTypeName,
                      style: AppTextStyles.arimo(
                        fontSize: 11 * scale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 16 * scale,
                      ),
                  ],
                ),
              ),
              SizedBox(height: 10 * scale),
              // Menu name
              Text(
                menu.menuName,
                style: AppTextStyles.tinos(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              // Description under name, show enough info
              if (menu.description != null && menu.description!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 6 * scale),
                  child: Text(
                    menu.description!,
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
