import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../bloc/menu_bloc.dart';
import '../bloc/menu_event.dart';
import '../bloc/menu_state.dart';
import '../widgets/menu_calendar_picker.dart';
import '../widgets/menu_selection_drawer.dart';
import '../widgets/saved_menu_records_card.dart';
import '../widgets/unsaved_menu_selections_card.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/entities/menu_record_entity.dart';
import '../../domain/entities/menu_type_entity.dart';

/// My Menu Screen - Main screen for menu selection and viewing
class MyMenuScreen extends StatefulWidget {
  const MyMenuScreen({super.key});

  @override
  State<MyMenuScreen> createState() => _MyMenuScreenState();
}

class _MyMenuScreenState extends State<MyMenuScreen> {
  late DateTime _selectedDate;
  // Unsaved selections (user is currently selecting, not yet saved)
  final Map<int, MenuEntity> _unsavedSelections = {}; // menuTypeId -> MenuEntity

  @override
  void initState() {
    super.initState();
    // Normalize date to remove time component
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _handleDateSelected(DateTime date) {
    // Normalize date to remove time component
    final normalizedDate = DateTime(date.year, date.month, date.day);
    setState(() {
      _selectedDate = normalizedDate;
      // Clear unsaved selections when changing date
      _unsavedSelections.clear();
    });
  }

  /// Get saved records for the selected date
  List<MenuRecordEntity> _getSavedRecordsForDate(MenuLoaded state) {
    final normalizedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    return state.myMenuRecords.where((record) {
      if (!record.isActive) return false;
      final recordDate = DateTime(
        record.date.year,
        record.date.month,
        record.date.day,
      );
      return recordDate.year == normalizedDate.year &&
          recordDate.month == normalizedDate.month &&
          recordDate.day == normalizedDate.day;
    }).toList();
  }

  void _handleRemoveUnsavedSelection(int menuTypeId) {
    setState(() {
      _unsavedSelections.remove(menuTypeId);
    });
  }

  void _showDeleteMenuDialog(BuildContext context, MenuLoaded state) {
    final scale = AppResponsive.scaleFactor(context);
    final savedRecords = _getSavedRecordsForDate(state);
    
    if (savedRecords.isEmpty) {
      AppToast.showWarning(
        context,
        message: AppStrings.menuNoMenuToDelete,
      );
      return;
    }

    // Map to track selected records for deletion
    final selectedRecordIds = <int>{};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 16 * scale),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.menuSelectMealToDelete,
                          style: AppTextStyles.arimo(
                            fontSize: 20 * scale,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
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

                // List of menu records to delete
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                    children: savedRecords.map((record) {
                      // Find menu - skip if not found
                      MenuEntity? menu;
                      try {
                        menu = state.menus.firstWhere(
                          (m) => m.id == record.menuId,
                        );
                      } catch (e) {
                        // Menu not found, skip this record
                        return const SizedBox.shrink();
                      }

                      // Find menu type - skip if not found
                      MenuTypeEntity? menuType;
                      try {
                        menuType = state.menuTypes.firstWhere(
                          (t) => t.id == menu!.menuTypeId,
                        );
                      } catch (e) {
                        // Menu type not found, skip this record
                        return const SizedBox.shrink();
                      }

                      final isSelected = selectedRecordIds.contains(record.id);

                      return Container(
                        margin: EdgeInsets.only(bottom: 12 * scale),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.red.withValues(alpha: 0.1)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(12 * scale),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.red
                                : AppColors.borderLight,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: CheckboxListTile(
                          value: isSelected,
                          onChanged: (value) {
                            setModalState(() {
                              if (value == true) {
                                selectedRecordIds.add(record.id);
                              } else {
                                selectedRecordIds.remove(record.id);
                              }
                            });
                          },
                          title: Text(
                            menuType.name,
                            style: AppTextStyles.arimo(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            record.name.isNotEmpty ? record.name : menu.menuName,
                            style: AppTextStyles.arimo(
                              fontSize: 14 * scale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          activeColor: AppColors.red,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16 * scale,
                            vertical: 8 * scale,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Action buttons
                Padding(
                  padding: EdgeInsets.all(20 * scale),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14 * scale),
                            side: BorderSide(color: AppColors.borderLight),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12 * scale),
                            ),
                          ),
                          child: Text(
                            'Hủy',
                            style: AppTextStyles.arimo(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12 * scale),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: selectedRecordIds.isEmpty
                              ? null
                              : () {
                                  Navigator.of(context).pop();
                                  _handleDeleteSavedRecords(selectedRecordIds.toList());
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.red,
                            disabledBackgroundColor: AppColors.borderLight,
                            padding: EdgeInsets.symmetric(vertical: 14 * scale),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12 * scale),
                            ),
                          ),
                          child: Text(
                            selectedRecordIds.isEmpty
                                ? AppStrings.menuSelectMeal
                                : AppStrings.menuDeleteCount.replaceAll('{count}', '${selectedRecordIds.length}'),
                            style: AppTextStyles.arimo(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleDeleteSavedRecords(List<int> recordIds) {
    if (recordIds.isEmpty) return;

    // Delete records one by one (or batch if API supports)
    for (final recordId in recordIds) {
      context.read<MenuBloc>().add(MenuRecordDeleteRequested(recordId));
    }

    AppToast.showSuccess(
      context,
      message: AppStrings.menuDeletedCount.replaceAll('{count}', '${recordIds.length}'),
    );
  }

  void _handleSaveMenus() {
    final state = context.read<MenuBloc>().state;
    if (state is! MenuLoaded) return;

    if (_unsavedSelections.isEmpty) {
      AppToast.showWarning(
        context,
        message: AppStrings.menuPleaseSelectAtLeastOne,
      );
      return;
    }

    // Get saved records for the selected date
    final savedRecords = _getSavedRecordsForDate(state);

    // Create save requests
    final saveRequests = _unsavedSelections.entries.map((entry) {
      final menu = entry.value;
      return SaveMenuRecordRequest(
        menuId: menu.id,
        name: menu.menuName,
        date: _selectedDate,
      );
    }).toList();

    context.read<MenuBloc>().add(MenuRecordsSaveRequested(
      requests: saveRequests,
      existingRecords: savedRecords,
    ));

    // Clear unsaved selections after saving
    setState(() {
      _unsavedSelections.clear();
    });

    // Show success message
    AppToast.showSuccess(
      context,
      message: AppStrings.menuSaveSuccess,
    );
  }

  List<DateTime> _getDatesWithMenus(List<MenuRecordEntity> records) {
    return records
        .where((record) => record.isActive)
        .map((record) => record.date)
        .toSet()
        .toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${AppFormatters.getMonthName(date.month)} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        final savedRecords = state is MenuLoaded ? _getSavedRecordsForDate(state) : <MenuRecordEntity>[];
        
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppAppBar(
            title: AppStrings.servicesTodayMenu,
            showBackButton: true,
            centerTitle: true,
            actions: savedRecords.isNotEmpty
                ? [
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: AppColors.red,
                        size: 24 * scale,
                      ),
                      onPressed: () {
                        if (state is MenuLoaded) {
                          _showDeleteMenuDialog(context, state);
                        }
                      },
                    ),
                  ]
                : null,
          ),
      body: BlocConsumer<MenuBloc, MenuState>(
        listener: (context, state) {
          if (state is MenuError) {
            AppToast.showError(context, message: state.message);
          }
          // Note: Success messages are handled in specific event handlers
        },
        builder: (context, state) {
          if (state is MenuLoading) {
            return Center(
              child: AppLoadingIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state is MenuError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64 * scale,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16 * scale),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 16 * scale,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24 * scale),
                  AppWidgets.primaryButton(
                    text: AppStrings.retry,
                    onPressed: () {
                      context.read<MenuBloc>().add(const MenuLoadRequested());
                    },
                    width: 200,
                  ),
                ],
              ),
            );
          }

          if (state is MenuLoaded) {
            final datesWithMenus = _getDatesWithMenus(state.myMenuRecords);
            final savedRecords = _getSavedRecordsForDate(state);

            return Column(
              children: [
                // Calendar picker
                Padding(
                  padding: EdgeInsets.only(top: 16 * scale),
                  child: MenuCalendarPicker(
                    selectedDate: _selectedDate,
                    onDateSelected: _handleDateSelected,
                    datesWithMenus: datesWithMenus,
                  ),
                ),

                SizedBox(height: 20 * scale),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Saved menu records (from server)
                        SavedMenuRecordsCard(
                          date: _selectedDate,
                          savedRecords: savedRecords,
                          allMenus: state.menus,
                          menuTypes: state.menuTypes,
                        ),

                        // Unsaved menu selections (user is currently selecting)
                        UnsavedMenuSelectionsCard(
                          date: _selectedDate,
                          unsavedSelections: _unsavedSelections,
                          menuTypes: state.menuTypes,
                          onRemove: _handleRemoveUnsavedSelection,
                        ),

                        // Empty state if no saved records and no unsaved selections
                        if (savedRecords.isEmpty && _unsavedSelections.isEmpty)
                          Container(
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
                                    AppStrings.menuNotSelectedForDate.replaceAll('{date}', _formatDate(_selectedDate)),
                                    style: AppTextStyles.arimo(
                                      fontSize: 14 * scale,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        SizedBox(height: 20 * scale),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, state) {
          if (state is! MenuLoaded) {
            return const SizedBox.shrink();
          }

          // Show "Lưu menu" FAB if there are unsaved selections
          if (_unsavedSelections.isNotEmpty) {
            return AppWidgets.primaryFabExtended(
              context: context,
              text: AppStrings.menuSaveCount.replaceAll('{count}', '${_unsavedSelections.length}'),
              icon: Icons.save,
              onPressed: _handleSaveMenus,
            );
          }

          // Show "Chọn menu" FAB (small, compact) when no unsaved selections
          final scale = AppResponsive.scaleFactor(context);
          return AppWidgets.primaryFabIcon(
            context: context,
            iconWidget: SvgPicture.asset(
              AppAssets.menuThird,
              width: 36 * scale,
              height: 36 * scale,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => _openMenuSelectionDrawer(context, state),
          );
        },
      ),
        );
      },
    );
  }

  /// Open menu selection drawer
  void _openMenuSelectionDrawer(BuildContext context, MenuLoaded state) {
    // Build saved selections map (menuTypeId -> MenuEntity)
    final savedSelections = <int, MenuEntity>{};
    final savedRecords = _getSavedRecordsForDate(state);
    
    for (final record in savedRecords) {
      try {
        final menu = state.menus.firstWhere((m) => m.id == record.menuId);
        savedSelections[menu.menuTypeId] = menu;
      } catch (e) {
        // Menu not found, skip
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MenuSelectionDrawer(
        selectedDate: _selectedDate,
        menuTypes: state.menuTypes,
        availableMenus: state.menus,
        savedSelections: savedSelections,
        unsavedSelections: _unsavedSelections,
        onSave: (selections) {
          // Update unsaved selections with new selections from drawer
          setState(() {
            _unsavedSelections.clear();
            _unsavedSelections.addAll(selections);
          });
          // Automatically save after closing drawer
          _handleSaveMenus();
        },
      ),
    );
  }
}
