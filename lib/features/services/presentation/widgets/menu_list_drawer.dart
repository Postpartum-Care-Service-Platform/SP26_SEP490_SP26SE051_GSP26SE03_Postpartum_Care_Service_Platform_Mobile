import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/entities/menu_type_entity.dart';
import '../../domain/entities/food_entity.dart';
import 'menu_list_item.dart';
import '../bloc/menu_bloc.dart';
import '../bloc/menu_state.dart';
import '../screens/create_custom_menu_screen.dart';

/// Menu List Drawer Widget
/// Shows list of menus for a specific meal type and allows selecting one
class MenuListDrawer extends StatefulWidget {
  final DateTime selectedDate;
  final MenuTypeEntity menuType;
  final List<MenuEntity> availableMenus;
  final List<MenuEntity> customizedMenus;
  final MenuEntity? currentSelection; // Currently selected menu (saved or unsaved)
  final Function(MenuEntity) onMenuSelected; // Callback when menu is selected

  const MenuListDrawer({
    super.key,
    required this.selectedDate,
    required this.menuType,
    required this.availableMenus,
    required this.customizedMenus,
    this.currentSelection,
    required this.onMenuSelected,
  });

  @override
  State<MenuListDrawer> createState() => _MenuListDrawerState();
}

class _MenuListDrawerState extends State<MenuListDrawer> {
  int _selectedTabIndex = 0; // 0: Center, 1: Mine

  @override
  void initState() {
    super.initState();
    
    // If the current selection is a customized menu, start on the "Mine" tab
    if (widget.currentSelection != null) {
      final isCustomized = widget.customizedMenus.any((m) => m.id == widget.currentSelection!.id);
      if (isCustomized) {
        _selectedTabIndex = 1;
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${AppFormatters.getMonthName(date.month)} ${date.year}';
  }

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

  void _openMenuDetail(MenuEntity menu) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MenuDetailSheet(
        menu: menu,
        selectedDate: widget.selectedDate,
        onSelect: () => _handleSelectMenu(menu),
      ),
    );
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
                  child: _getMenuTypeIcon(
                    widget.menuType.name,
                    24 * scale,
                    AppColors.primary,
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

          // Tab Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 8 * scale),
            child: Container(
              padding: EdgeInsets.all(5 * scale),
              decoration: BoxDecoration(
                color: AppColors.homeServiceScheduleHighlightBg.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(14 * scale),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                   _buildTab(0, AppStrings.menuCustomCenter),
                   _buildTab(1, AppStrings.menuCustomMine),
                ],
              ),
            ),
          ),
          Flexible(
            child: BlocBuilder<MenuBloc, MenuState>(
              builder: (context, state) {
                return _buildContent(state);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    final scale = AppResponsive.scaleFactor(context);
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10 * scale),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10 * scale),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4 * scale,
                      offset: Offset(0, 2 * scale),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(MenuState state) {
    final scale = AppResponsive.scaleFactor(context);
    
    // Calculate menus for type dynamically from state
    List<MenuEntity> menusForType = widget.availableMenus.where((m) => m.menuTypeId == widget.menuType.id).toList();
    List<MenuEntity> customizedMenusForType = widget.customizedMenus.where((m) => m.menuTypeId == widget.menuType.id).toList();

    if (state is MenuLoaded) {
      menusForType = state.menus.where((m) => m.menuTypeId == widget.menuType.id).toList();
      customizedMenusForType = state.customizedMenus.where((m) => m.menuTypeId == widget.menuType.id).toList();
    }

    final menusToShow = _selectedTabIndex == 0 ? menusForType : customizedMenusForType;

    if (_selectedTabIndex == 1 && menusToShow.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32 * scale),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20 * scale),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  AppAssets.pencilFeedback,
                  width: 48 * scale,
                  height: 48 * scale,
                  colorFilter: ColorFilter.mode(
                    AppColors.primary.withValues(alpha: 0.5),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(height: 16 * scale),
              Text(
                'Bạn chưa có thực đơn cá nhân nào cho bữa này',
                style: AppTextStyles.arimo(
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8 * scale),
              Text(
                'Hãy tạo thực đơn mang dấu ấn riêng của bạn!',
                style: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24 * scale),
              _buildAddCustomButton(),
            ],
          ),
        ),
      );
    }

    if (menusToShow.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40 * scale),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant_menu, size: 64 * scale, color: AppColors.textSecondary),
              SizedBox(height: 16 * scale),
              Text(
                AppStrings.menuNoMenuForType.replaceAll('{type}', widget.menuType.name),
                style: AppTextStyles.arimo(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(20 * scale, 0, 20 * scale, 20 * scale),
      children: [
        if (_selectedTabIndex == 1) ...[
          _buildAddCustomButton(),
          SizedBox(height: 16 * scale),
        ],
        for (int i = 0; i < menusToShow.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: 12 * scale),
            child: Row(
              children: [
                Expanded(
                  child: MenuListItem(
                    menu: menusToShow[i],
                    isSelected: widget.currentSelection?.id == menusToShow[i].id,
                    onTap: () => _openMenuDetail(menusToShow[i]),
                  ),
                ),
                SizedBox(width: 12 * scale),
                if (i + 1 < menusToShow.length)
                  Expanded(
                    child: MenuListItem(
                      menu: menusToShow[i + 1],
                      isSelected: widget.currentSelection?.id == menusToShow[i + 1].id,
                      onTap: () => _openMenuDetail(menusToShow[i + 1]),
                    ),
                  )
                else
                  const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAddCustomButton() {
    final scale = AppResponsive.scaleFactor(context);

    return InkWell(
      onTap: () async {
        final menuBloc = context.read<MenuBloc>();
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: menuBloc,
              child: CreateCustomMenuScreen(menuType: widget.menuType),
            ),
          ),
        );

        if (result != null && result is MenuEntity && mounted) {
          // Select the new menu in the parent, but stay in the drawer
          widget.onMenuSelected(result);
        }
      },
      borderRadius: BorderRadius.circular(16 * scale),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14 * scale, horizontal: 24 * scale),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(
            color: AppColors.primary,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 10 * scale,
              offset: Offset(0, 4 * scale),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle, color: AppColors.primary, size: 22 * scale),
            SizedBox(width: 10 * scale),
            Text(
              AppStrings.menuCustomTitle,
              style: AppTextStyles.arimo(
                fontSize: 15 * scale,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
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

/// Full-screen style bottom sheet to show menu details & foods
class _MenuDetailSheet extends StatelessWidget {
  final MenuEntity menu;
  final DateTime selectedDate;
  final VoidCallback onSelect;

  const _MenuDetailSheet({
    required this.menu,
    required this.selectedDate,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      margin: EdgeInsets.only(top: 40 * scale),
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 4 * scale),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu.menuName,
                        style: AppTextStyles.tinos(
                          fontSize: 20 * scale,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: AppTextStyles.arimo(
                          fontSize: 13 * scale,
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
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20 * scale, 0, 20 * scale, 12 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (menu.description != null && menu.description!.isNotEmpty) ...[
                    Text(
                      menu.description!,
                      style: AppTextStyles.arimo(
                        fontSize: 13 * scale,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 12 * scale),
                  ],
                  _FoodsList(menu: menu),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20 * scale, 8 * scale, 20 * scale, 16 * scale),
              child: AppWidgets.primaryButton(
                text: AppStrings.menuSelectThis,
                icon: Icon(
                  Icons.check,
                  size: 20 * scale,
                  color: AppColors.white,
                ),
                onPressed: () {
                  // Close detail sheet
                  Navigator.of(context).pop();
                  // Then notify parent (MenuListDrawer) to save & close list
                  onSelect();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
