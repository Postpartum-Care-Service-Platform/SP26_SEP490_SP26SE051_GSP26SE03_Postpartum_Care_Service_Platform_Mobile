import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/entities/menu_type_entity.dart';
import '../../domain/entities/food_entity.dart';
import 'menu_list_item.dart';

/// Menu List Drawer Widget
/// Shows list of menus for a specific meal type and allows selecting one
class MenuListDrawer extends StatefulWidget {
  final DateTime selectedDate;
  final MenuTypeEntity menuType;
  final List<MenuEntity> availableMenus;
  final MenuEntity? currentSelection; // Currently selected menu (saved or unsaved)
  final Function(MenuEntity) onMenuSelected; // Callback when menu is selected

  const MenuListDrawer({
    super.key,
    required this.selectedDate,
    required this.menuType,
    required this.availableMenus,
    this.currentSelection,
    required this.onMenuSelected,
  });

  @override
  State<MenuListDrawer> createState() => _MenuListDrawerState();
}

class _MenuListDrawerState extends State<MenuListDrawer> {
  MenuEntity? _selectedMenuForDetail; // Menu selected to show foods
  final List<MenuEntity> _menusForType = [];

  @override
  void initState() {
    super.initState();
    // Filter menus for this menu type
    _menusForType.addAll(
      widget.availableMenus.where((menu) => menu.menuTypeId == widget.menuType.id).toList(),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${AppFormatters.getMonthName(date.month)} ${date.year}';
  }

  IconData _getMenuTypeIcon(String menuTypeName) {
    if (menuTypeName.contains('Sáng') && !menuTypeName.contains('Phụ')) {
      return Icons.sunny_snowing;
    } else if (menuTypeName.contains('Trưa')) {
      return Icons.wb_sunny;
    } else if (menuTypeName.contains('Tối')) {
      return Icons.nightlight;
    } else if (menuTypeName.contains('Phụ')) {
      return Icons.cookie;
    }
    return Icons.restaurant;
  }

  void _handleMenuTap(MenuEntity menu) {
    setState(() {
      // If clicking the same menu, deselect it
      if (_selectedMenuForDetail?.id == menu.id) {
        _selectedMenuForDetail = null;
      } else {
        _selectedMenuForDetail = menu;
      }
    });
  }

  void _handleSelectMenu(MenuEntity menu) {
    widget.onMenuSelected(menu);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20 * scale),
          topRight: Radius.circular(20 * scale),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: EdgeInsets.only(top: 12 * scale, bottom: 8 * scale),
            width: 40 * scale,
            height: 4 * scale,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(2 * scale),
            ),
          ),

          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 16 * scale),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8 * scale,
                  offset: Offset(0, 2 * scale),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(10 * scale),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10 * scale),
                  ),
                  child: Icon(
                    _getMenuTypeIcon(widget.menuType.name),
                    color: AppColors.primary,
                    size: 24 * scale,
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.menuForType.replaceAll('{type}', widget.menuType.name),
                        style: AppTextStyles.tinos(
                          fontSize: 20 * scale,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        _formatDate(widget.selectedDate),
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: AppColors.textPrimary,
                    size: 24 * scale,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: _menusForType.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(40 * scale),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 64 * scale,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 16 * scale),
                          Text(
                            AppStrings.menuNoMenuForType.replaceAll('{type}', widget.menuType.name),
                            style: AppTextStyles.arimo(
                              fontSize: 16 * scale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(20 * scale),
                    children: [
                      // Menu list
                      ..._menusForType.map((menu) {
                        final isSelected = _selectedMenuForDetail?.id == menu.id;
                        final isCurrentSelection = widget.currentSelection?.id == menu.id;

                        return Column(
                          children: [
                            MenuListItem(
                              menu: menu,
                              isSelected: isCurrentSelection,
                              onTap: () => _handleMenuTap(menu),
                            ),
                            SizedBox(height: 12 * scale),
                            // Show foods if this menu is selected for detail
                            if (isSelected) ...[
                              _FoodsList(menu: menu),
                              SizedBox(height: 12 * scale),
                              AppWidgets.primaryButton(
                                text: AppStrings.menuSelectThis,
                                icon: Icon(
                                  Icons.check,
                                  size: 20 * scale,
                                  color: AppColors.white,
                                ),
                                onPressed: () => _handleSelectMenu(menu),
                                width: double.infinity,
                              ),
                              SizedBox(height: 12 * scale),
                            ],
                          ],
                        );
                      }).toList(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Widget to display foods of a menu
class _FoodsList extends StatelessWidget {
  final MenuEntity menu;

  const _FoodsList({required this.menu});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    if (menu.foods.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Text(
          AppStrings.menuNoFoods,
          style: AppTextStyles.arimo(
            fontSize: 14 * scale,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant,
                color: AppColors.primary,
                size: 20 * scale,
              ),
              SizedBox(width: 8 * scale),
              Text(
                AppStrings.menuFoodsListCount.replaceAll('{count}', '${menu.foods.length}'),
                style: AppTextStyles.arimo(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          ...menu.foods.map((food) => _FoodItem(food: food)),
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
