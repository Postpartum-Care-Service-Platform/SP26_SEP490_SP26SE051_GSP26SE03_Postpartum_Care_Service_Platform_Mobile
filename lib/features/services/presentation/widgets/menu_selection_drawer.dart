import 'package:flutter/material.dart';
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
import 'menu_list_drawer.dart';

/// Menu Selection Drawer Widget
/// Shows all meal types and allows selecting menus for each meal type
class MenuSelectionDrawer extends StatefulWidget {
  final DateTime selectedDate;
  final List<MenuTypeEntity> menuTypes;
  final List<MenuEntity> availableMenus;
  final Map<int, MenuEntity> savedSelections; // menuTypeId -> MenuEntity (saved)
  final Map<int, MenuEntity> unsavedSelections; // menuTypeId -> MenuEntity (unsaved)
  final Function(Map<int, MenuEntity>) onSave; // Callback to save all selections

  const MenuSelectionDrawer({
    super.key,
    required this.selectedDate,
    required this.menuTypes,
    required this.availableMenus,
    required this.savedSelections,
    required this.unsavedSelections,
    required this.onSave,
  });

  @override
  State<MenuSelectionDrawer> createState() => _MenuSelectionDrawerState();
}

class _MenuSelectionDrawerState extends State<MenuSelectionDrawer> {
  // Temporary selections while user is choosing (will be saved when clicking save button)
  final Map<int, MenuEntity> _tempSelections = {};

  @override
  void initState() {
    super.initState();
    // Initialize temp selections with unsaved selections
    _tempSelections.addAll(widget.unsavedSelections);
  }

  /// Sort menu types in order: Sáng, Phụ (Sáng), Trưa, Phụ (Chiều), Tối
  List<MenuTypeEntity> _getSortedMenuTypes() {
    final sorted = List<MenuTypeEntity>.from(widget.menuTypes);
    sorted.sort((a, b) {
      // Define order: Sáng (1), Phụ (Sáng) (4), Trưa (2), Phụ (Chiều) (5), Tối (3)
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

  void _handleRemoveSelection(int menuTypeId) {
    setState(() {
      _tempSelections.remove(menuTypeId);
    });
  }

  void _openMenuListDrawer(MenuTypeEntity menuType) {
    // Get current selection (saved or temp)
    final hasSavedSelection = widget.savedSelections.containsKey(menuType.id);
    final hasTempSelection = _tempSelections.containsKey(menuType.id);
    final currentSelection = hasTempSelection
        ? _tempSelections[menuType.id]
        : (hasSavedSelection
            ? widget.savedSelections[menuType.id]
            : null);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MenuListDrawer(
        selectedDate: widget.selectedDate,
        menuType: menuType,
        availableMenus: widget.availableMenus,
        currentSelection: currentSelection,
        onMenuSelected: (menu) {
          setState(() {
            _tempSelections[menuType.id] = menu;
          });
        },
      ),
    );
  }

  void _handleSave() {
    if (_tempSelections.isEmpty) {
      // Show warning if no selections
      return;
    }
    widget.onSave(_tempSelections);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final maxHeight = MediaQuery.of(context).size.height * 0.9;
    final sortedMenuTypes = _getSortedMenuTypes();

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.menuSelect,
                        style: AppTextStyles.tinos(
                          fontSize: 22 * scale,
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

          // Menu type sections
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(20 * scale),
              children: [
                ...sortedMenuTypes.map((menuType) {
                  final hasSavedSelection = widget.savedSelections.containsKey(menuType.id);
                  final hasTempSelection = _tempSelections.containsKey(menuType.id);
                  final isSelected = hasSavedSelection || hasTempSelection;
                  final currentSelection = hasTempSelection
                      ? _tempSelections[menuType.id]
                      : (hasSavedSelection
                          ? widget.savedSelections[menuType.id]
                          : null);

                  return Container(
                    margin: EdgeInsets.only(bottom: 12 * scale),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12 * scale),
                      border: Border.all(
                        color: isSelected
                            ? (hasSavedSelection
                                ? AppColors.verified
                                : AppColors.primary)
                            : AppColors.borderLight,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Header - clickable to open menu list drawer
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _openMenuListDrawer(menuType),
                            borderRadius: BorderRadius.circular(12 * scale),
                            child: Container(
                              padding: EdgeInsets.all(16 * scale),
                              child: Row(
                                children: [
                                  // Icon
                                  Container(
                                    padding: EdgeInsets.all(10 * scale),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (hasSavedSelection
                                              ? AppColors.verified.withValues(alpha: 0.15)
                                              : AppColors.primary.withValues(alpha: 0.15))
                                          : AppColors.white,
                                      borderRadius: BorderRadius.circular(10 * scale),
                                    ),
                                    child: _getMenuTypeIcon(menuType.name, 24 * scale, isSelected ? (hasSavedSelection ? AppColors.verified : AppColors.primary) : AppColors.textSecondary),
                                  ),
                                  SizedBox(width: 16 * scale),
                                  // Menu type name and current selection
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          menuType.name,
                                          style: AppTextStyles.tinos(
                                            fontSize: 16 * scale,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        if (currentSelection != null) ...[
                                          SizedBox(height: 4 * scale),
                                          Text(
                                            currentSelection.menuName,
                                            style: AppTextStyles.arimo(
                                              fontSize: 13 * scale,
                                              color: AppColors.textSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  // Remove button if has temp selection
                                  if (hasTempSelection)
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: AppColors.red,
                                        size: 20 * scale,
                                      ),
                                      onPressed: () => _handleRemoveSelection(menuType.id),
                                    ),
                                  // Status indicator
                                  if (isSelected && !hasTempSelection)
                                    Icon(
                                      Icons.check_circle,
                                      color: AppColors.verified,
                                      size: 24 * scale,
                                    )
                                  else
                                    Icon(
                                      Icons.chevron_right,
                                      color: AppColors.textSecondary,
                                      size: 24 * scale,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                
                // Save button
                if (_tempSelections.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8 * scale),
                    child: AppWidgets.primaryButton(
                      text: AppStrings.menuSaveCount.replaceAll('{count}', '${_tempSelections.length}'),
                      icon: Icon(
                        Icons.save,
                        size: 20 * scale,
                        color: AppColors.white,
                      ),
                      onPressed: _handleSave,
                      width: double.infinity,
                    ),
                  ),
                
                SizedBox(height: 20 * scale), // Bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }
}
