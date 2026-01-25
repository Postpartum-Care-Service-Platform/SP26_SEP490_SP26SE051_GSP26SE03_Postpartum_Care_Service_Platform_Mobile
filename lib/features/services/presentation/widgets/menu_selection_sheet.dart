import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/entities/menu_type_entity.dart';
import 'menu_list_item.dart';
import 'menu_detail_card.dart';

/// Menu Selection Bottom Sheet
/// Allows user to select menus for different meal types
class MenuSelectionSheet extends StatefulWidget {
  final DateTime selectedDate;
  final MenuTypeEntity menuType;
  final List<MenuEntity> availableMenus;
  final MenuEntity? currentSelection;
  final Function(MenuEntity) onMenuSelected;

  const MenuSelectionSheet({
    super.key,
    required this.selectedDate,
    required this.menuType,
    required this.availableMenus,
    this.currentSelection,
    required this.onMenuSelected,
  });

  @override
  State<MenuSelectionSheet> createState() => _MenuSelectionSheetState();
}

class _MenuSelectionSheetState extends State<MenuSelectionSheet> {
  MenuEntity? _selectedMenu;
  bool _showDetail = false;

  @override
  void initState() {
    super.initState();
    _selectedMenu = widget.currentSelection;
  }

  void _handleMenuTap(MenuEntity menu) {
    setState(() {
      _selectedMenu = menu;
      _showDetail = true;
    });
  }

  void _handleConfirm() {
    if (_selectedMenu != null) {
      widget.onMenuSelected(_selectedMenu!);
      Navigator.of(context).pop();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${AppFormatters.getMonthName(date.month)} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final filteredMenus = widget.availableMenus
        .where((menu) => menu.menuTypeId == widget.menuType.id)
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24 * scale),
          topRight: Radius.circular(24 * scale),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12 * scale),
            width: 40 * scale,
            height: 4 * scale,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(2 * scale),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.all(20 * scale),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.menuSelectForType.replaceAll('{type}', widget.menuType.name),
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
          Expanded(
            child: _showDetail && _selectedMenu != null
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        MenuDetailCard(menu: _selectedMenu!),
                        SizedBox(height: 20 * scale),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                          child: AppWidgets.primaryButton(
                            text: AppStrings.menuSelectThis,
                            onPressed: _handleConfirm,
                          ),
                        ),
                        SizedBox(height: 20 * scale),
                      ],
                    ),
                  )
                : filteredMenus.isEmpty
                    ? Center(
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
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                        itemCount: filteredMenus.length,
                        itemBuilder: (context, index) {
                          final menu = filteredMenus[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12 * scale),
                            child: MenuListItem(
                              menu: menu,
                              isSelected: _selectedMenu?.id == menu.id,
                              onTap: () => _handleMenuTap(menu),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
