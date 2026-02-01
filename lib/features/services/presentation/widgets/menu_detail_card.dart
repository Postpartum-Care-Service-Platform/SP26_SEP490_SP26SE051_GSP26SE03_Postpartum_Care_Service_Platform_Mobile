import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/entities/food_entity.dart';

/// Menu Detail Card Widget
class MenuDetailCard extends StatelessWidget {
  final MenuEntity menu;

  const MenuDetailCard({
    super.key,
    required this.menu,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 8 * scale),
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
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
              Expanded(
                child: Text(
                  menu.menuName,
                  style: AppTextStyles.tinos(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (menu.description != null && menu.description!.isNotEmpty) ...[
            SizedBox(height: 12 * scale),
            Text(
              menu.description!,
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (menu.foods.isNotEmpty) ...[
            SizedBox(height: 20 * scale),
            Divider(
              color: AppColors.borderLight,
              thickness: 1,
            ),
            SizedBox(height: 12 * scale),
            Text(
              AppStrings.menuFoodsList,
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12 * scale),
            ...menu.foods.map((food) => _FoodItem(food: food)),
          ],
        ],
      ),
    );
  }
}

class _FoodItem extends StatelessWidget {
  final FoodEntity food;

  const _FoodItem({required this.food});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food image or placeholder
          Container(
            width: 60 * scale,
            height: 60 * scale,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: food.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8 * scale),
                    child: Image.network(
                      food.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.restaurant,
                          color: AppColors.textSecondary,
                          size: 24 * scale,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.restaurant,
                    color: AppColors.textSecondary,
                    size: 24 * scale,
                  ),
          ),
          SizedBox(width: 12 * scale),
          // Food details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        food.name,
                        style: AppTextStyles.tinos(
                          fontSize: 15 * scale,
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
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6 * scale),
                      ),
                      child: Text(
                        food.type,
                        style: AppTextStyles.arimo(
                          fontSize: 10 * scale,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (food.description != null && food.description!.isNotEmpty) ...[
                  SizedBox(height: 4 * scale),
                  Text(
                    food.description!,
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
