import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/entities/menu_type_entity.dart';
import '../../domain/entities/menu_record_entity.dart';
import '../../domain/entities/food_entity.dart';

/// Saved Menu Records Card Widget
/// Displays menu records that have been saved to the server
/// Shows detailed menu information organized by meal type (Sáng, Trưa, Chiều, etc.)
class SavedMenuRecordsCard extends StatelessWidget {
  final DateTime date;
  final List<MenuRecordEntity> savedRecords;
  final List<MenuEntity> allMenus;
  final List<MenuTypeEntity> menuTypes;

  const SavedMenuRecordsCard({
    super.key,
    required this.date,
    required this.savedRecords,
    required this.allMenus,
    required this.menuTypes,
  });

  MenuEntity? _getMenu(int menuId) {
    try {
      return allMenus.firstWhere((m) => m.id == menuId);
    } catch (e) {
      return null;
    }
  }


  /// Get menu record for a specific menu type
  MenuRecordEntity? _getRecordForMenuType(int menuTypeId) {
    for (final record in savedRecords) {
      final menu = _getMenu(record.menuId);
      if (menu != null && menu.menuTypeId == menuTypeId) {
        return record;
      }
    }
    return null;
  }

  /// Sort menu types in order: Sáng, Phụ (Sáng), Trưa, Phụ (Chiều), Tối
  List<MenuTypeEntity> _getSortedMenuTypes() {
    final sorted = List<MenuTypeEntity>.from(menuTypes);
    sorted.sort((a, b) {
      final orderA = _getMenuTypeOrder(a.name);
      final orderB = _getMenuTypeOrder(b.name);
      return orderA.compareTo(orderB);
    });
    return sorted;
  }

  int _getMenuTypeOrder(String name) {
    if (name.contains('Sáng') && !name.contains('Phụ')) {
      return 1; // Sáng
    } else if (name.contains('Phụ') && name.contains('Sáng')) {
      return 2; // Phụ (Sáng)
    } else if (name.contains('Trưa')) {
      return 3; // Trưa
    } else if (name.contains('Phụ') && name.contains('Chiều')) {
      return 4; // Phụ (Chiều)
    } else if (name.contains('Tối')) {
      return 5; // Tối
    }
    return 99; // Unknown, put at end
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    if (savedRecords.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedMenuTypes = _getSortedMenuTypes();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 8 * scale),
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.3),
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
          // Menu sections by meal type
          ...sortedMenuTypes.map((menuType) {
            final record = _getRecordForMenuType(menuType.id);
            final menu = record != null ? _getMenu(record.menuId) : null;
            final hasMenu = record != null && menu != null;

            return _MenuSection(
              menuType: menuType,
              menu: menu,
              record: record,
              hasMenu: hasMenu,
              scale: scale,
            );
          }),
        ],
      ),
    );
  }
}

/// Menu Section Widget - displays menu for a specific meal type
class _MenuSection extends StatelessWidget {
  final MenuTypeEntity menuType;
  final MenuEntity? menu;
  final MenuRecordEntity? record;
  final bool hasMenu;
  final double scale;

  const _MenuSection({
    required this.menuType,
    this.menu,
    this.record,
    required this.hasMenu,
    required this.scale,
  });

  Widget _getMenuTypeIcon(String menuTypeName, double size, Color color) {
    if (menuTypeName.contains('Sáng') && !menuTypeName.contains('Phụ')) {
      return Icon(Icons.sunny_snowing, size: size, color: color);
    } else if (menuTypeName.contains('Trưa')) {
      return SvgPicture.asset(
        AppAssets.sun,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    } else if (menuTypeName.contains('Tối')) {
      return SvgPicture.asset(
        AppAssets.moon,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    } else if (menuTypeName.contains('Phụ')) {
      return Icon(Icons.cookie, size: size, color: color);
    }
    return Icon(Icons.restaurant, size: size, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header: MenuType - MenuName
          Row(
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(8 * scale),
                child: _getMenuTypeIcon(
                  menuType.name,
                  20 * scale,
                  AppColors.primary,
                ),
              ),
              SizedBox(width: 12 * scale),
              // Menu type and name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menuType.name,
                      style: AppTextStyles.tinos(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.bold,
                        color: hasMenu
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (hasMenu && menu != null) ...[
                      SizedBox(height: 4 * scale),
                      Text(
                        record?.name.isNotEmpty == true
                            ? record!.name
                            : menu!.menuName,
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Foods grid (2 items per row) - only show if has menu
          if (hasMenu && menu != null && menu!.foods.isNotEmpty) ...[
            SizedBox(height: 12 * scale),
            _FoodsGrid(foods: menu!.foods, scale: scale),
          ] else if (!hasMenu) ...[
            // Empty space for sections without menu
            SizedBox(height: 12 * scale),
            Container(
              height: 60 * scale,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(
                  color: AppColors.borderLight.withValues(alpha: 0.5),
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Text(
                  AppStrings.menuNotSelected,
                  style: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  )
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Foods Grid Widget - displays foods in a 2-column grid
class _FoodsGrid extends StatelessWidget {
  final List<FoodEntity> foods;
  final double scale;

  const _FoodsGrid({
    required this.foods,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12 * scale,
        mainAxisSpacing: 12 * scale,
        childAspectRatio: 1.2,
      ),
      itemCount: foods.length,
      itemBuilder: (context, index) {
        final food = foods[index];
        return _FoodItem(food: food, scale: scale);
      },
    );
  }
}

/// Food Item Widget - displays a single food item
class _FoodItem extends StatelessWidget {
  final FoodEntity food;
  final double scale;

  const _FoodItem({
    required this.food,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none, // Cho phép badge vẽ ra ngoài khung ảnh
        children: [
          // Food image or placeholder - full fill
          ClipRRect(
            borderRadius: BorderRadius.circular(12 * scale),
            child: food.imageUrl != null
                ? Image.network(
                    food.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.borderLight,
                        child: Icon(
                          Icons.restaurant,
                          color: AppColors.textSecondary,
                          size: 32 * scale,
                        ),
                      );
                    },
                  )
                : Container(
                    color: AppColors.borderLight,
                    child: Icon(
                      Icons.restaurant,
                      color: AppColors.textSecondary,
                      size: 32 * scale,
                    ),
                  ),
          ),
          
          // Gradient overlay at bottom for food name
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12 * scale),
                  bottomRight: Radius.circular(12 * scale),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
              padding: EdgeInsets.all(12 * scale),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food name
                  Text(
                    food.name,
                    style: AppTextStyles.arimo(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Food type badge - top right corner with clearer contrast
          if (food.type.trim().isNotEmpty)
            Positioned(
              // Half in, half out của khung ảnh: dịch lên nhiều hơn nhưng vẫn nằm trong card
              top: -12 * scale,
              right: 12 * scale,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8 * scale),
                child: BackdropFilter(
                  filter:
                      ImageFilter.blur(sigmaX: 10 * scale, sigmaY: 10 * scale),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10 * scale,
                      vertical: 4 * scale,
                    ),
                    decoration: BoxDecoration(
                      // Darker semi-transparent background for better readability
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(8 * scale),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.7),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8 * scale,
                          offset: Offset(0, 3 * scale),
                        ),
                      ],
                    ),
                    child: Text(
                      food.type,
                      style: AppTextStyles.arimo(
                        fontSize: 11 * scale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
