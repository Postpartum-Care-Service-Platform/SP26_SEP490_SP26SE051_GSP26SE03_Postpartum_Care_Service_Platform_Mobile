import 'package:flutter/foundation.dart';
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
import '../../../../core/services/current_account_cache_service.dart';
import '../bloc/menu_bloc.dart';
import '../bloc/menu_event.dart';
import '../bloc/menu_state.dart';
import 'create_custom_menu_screen.dart';
import '../widgets/menu_calendar_picker.dart';
import '../widgets/menu_selection_drawer.dart';
import '../widgets/menu_list_drawer.dart';
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
  DateTime? _minMenuDate;
  DateTime? _maxMenuDate;
  // Unsaved selections (user is currently selecting, not yet saved)
  final Map<int, MenuEntity> _unsavedSelections = {}; // menuTypeId -> MenuEntity
  // Track deletion state
  int? _deletingCount;
  bool _isBulkSaving = false;

  @override
  void initState() {
    super.initState();
    // Normalize date to remove time component
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _loadMenuDateRange();
  }

  DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  Future<void> _loadMenuDateRange() async {
    final currentAccount = await CurrentAccountCacheService.getCurrentAccount();
    final nowPackage = currentAccount?.nowPackage;

    if (nowPackage == null) return;

    final checkinDate = nowPackage.checkinDate ?? nowPackage.firstServiceDate;
    final checkoutDate = nowPackage.checkoutDate ?? nowPackage.lastServiceDate;

    if (checkinDate == null || checkoutDate == null) return;

    final minDate = _normalizeDate(checkinDate);
    final maxDate = _normalizeDate(checkoutDate);

    final clampedSelectedDate = _selectedDate.isBefore(minDate)
        ? minDate
        : (_selectedDate.isAfter(maxDate) ? maxDate : _selectedDate);

    if (!mounted) return;

    setState(() {
      _minMenuDate = minDate;
      _maxMenuDate = maxDate;
      _selectedDate = clampedSelectedDate;
      _unsavedSelections.clear();
    });
  }

  bool _isDateInAllowedRange(DateTime date) {
    final normalizedDate = _normalizeDate(date);

    if (_minMenuDate != null && normalizedDate.isBefore(_minMenuDate!)) {
      return false;
    }

    if (_maxMenuDate != null && normalizedDate.isAfter(_maxMenuDate!)) {
      return false;
    }

    return true;
  }

  void _handleDateSelected(DateTime date) {
    // Normalize date to remove time component
    final normalizedDate = DateTime(date.year, date.month, date.day);

    if (!_isDateInAllowedRange(normalizedDate)) {
      return;
    }

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

    // Track deletion count
    setState(() {
      _deletingCount = recordIds.length;
    });

    // Show loading
    AppLoading.show(context, message: AppStrings.deleting);

    // Delete all records in batch and reload
    context.read<MenuBloc>().add(MenuRecordsDeleteRequested(recordIds));
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

    final createRequests = <CreateMenuRecordRequest>[];
    final updateRequests = <UpdateMenuRecordRequest>[];

    // Get saved records for selected date
    final savedRecords = _getSavedRecordsForDate(state);

    for (final selectedMenu in _unsavedSelections.values) {
      MenuRecordEntity? existingRecord;

      try {
        existingRecord = savedRecords.firstWhere((record) {
          if (!record.isActive) return false;

          try {
            final existingMenu = state.menus.firstWhere((m) => m.id == record.menuId);
            return existingMenu.menuTypeId == selectedMenu.menuTypeId;
          } catch (_) {
            return false;
          }
        });
      } catch (_) {
        existingRecord = null;
      }

      if (existingRecord != null) {
        // No-op update: cùng menu thì bỏ qua
        if (existingRecord.menuId != selectedMenu.id) {
          updateRequests.add(UpdateMenuRecordRequest(
            id: existingRecord.id,
            menuId: selectedMenu.id,
            name: selectedMenu.menuName,
            date: _selectedDate,
          ));
        }
      } else {
        createRequests.add(CreateMenuRecordRequest(
          menuId: selectedMenu.id,
          name: selectedMenu.menuName,
          date: _selectedDate,
        ));
      }
    }

    if (createRequests.isEmpty && updateRequests.isEmpty) {
      AppToast.showWarning(
        context,
        message: 'Không có thay đổi để lưu',
      );
      setState(() {
        _unsavedSelections.clear();
      });
      return;
    }

    if (createRequests.isNotEmpty) {
      context.read<MenuBloc>().add(MenuRecordsCreateRequested(createRequests));
    }

    if (updateRequests.isNotEmpty) {
      context.read<MenuBloc>().add(MenuRecordsUpdateRequested(updateRequests));
    }

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

  Future<void> _openBulkCreateMenuSheet(BuildContext context, MenuLoaded state) async {
    if (_minMenuDate == null || _maxMenuDate == null) {
      AppToast.showWarning(
        context,
        message: AppStrings.menuWaitingCheckIn,
      );
      return;
    }

    final sortedMenuTypes = _getSortedMenuTypes(state.menuTypes);
    final allAllowedDates = _getAllAllowedDates();

    final selectedDates = allAllowedDates.map(_normalizeDate).toSet();
    final selectionsByDate = <DateTime, Map<int, MenuEntity>>{};

    DateTime activeDate = selectedDates.contains(_normalizeDate(_selectedDate))
        ? _normalizeDate(_selectedDate)
        : (allAllowedDates.isNotEmpty ? _normalizeDate(allAllowedDates.first) : _normalizeDate(_selectedDate));

    for (final record in state.myMenuRecords) {
      if (!record.isActive) continue;
      final recordDate = _normalizeDate(record.date);
      if (!selectedDates.contains(recordDate)) continue;

      MenuEntity? menu;
      try {
        menu = state.menus.firstWhere((m) => m.id == record.menuId);
      } catch (_) {
        menu = null;
      }

      if (menu == null) continue;
      final daySelections = selectionsByDate.putIfAbsent(recordDate, () => <int, MenuEntity>{});
      daySelections[menu.menuTypeId] = menu;
    }

    Map<int, MenuEntity> getSelectionsForDate(DateTime date) {
      final normalized = _normalizeDate(date);
      return selectionsByDate.putIfAbsent(normalized, () => <int, MenuEntity>{});
    }

    Future<void> openMenuListDrawerForType(
      BuildContext bottomSheetContext,
      MenuTypeEntity menuType,
    ) async {
      final selectionsForActiveDate = getSelectionsForDate(activeDate);
      final currentSelection = selectionsForActiveDate[menuType.id];

      await showModalBottomSheet(
        context: bottomSheetContext,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => MenuListDrawer(
          selectedDate: activeDate,
          menuType: menuType,
          availableMenus: state.menus,
          customizedMenus: state.customizedMenus,
          currentSelection: currentSelection,
          onMenuSelected: (menu) {
            selectionsForActiveDate[menuType.id] = menu;
          },
        ),
      );
    }

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final scale = AppResponsive.scaleFactor(context);

            Future<void> handleBulkSave() async {
              if (selectedDates.isEmpty) {
                AppToast.showWarning(
                  context,
                  message: AppStrings.menuSelectAtLeastOneDay,
                );
                return;
              }

              final saveRequests = <SaveMenuRecordRequest>[];
              final requestDates = <DateTime>{};

              String inferMealSlot(String text) {
                final lower = text.toLowerCase();
                if (lower.contains('phụ') && lower.contains('sáng')) return 'snack_morning';
                if (lower.contains('phụ') && lower.contains('chiều')) return 'snack_afternoon';
                if (lower.contains('phụ') && lower.contains('tối')) return 'snack_night';
                if (lower.contains('sáng')) return 'morning';
                if (lower.contains('trưa')) return 'lunch';
                if (lower.contains('chiều') || lower.contains('tối')) return 'dinner';
                return 'unknown';
              }

              String dateKey(DateTime date) {
                final normalized = _normalizeDate(date);
                return '${normalized.year}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
              }

              String inferMenuTypeNameByMenu(MenuEntity menu) {
                try {
                  return state.menuTypes.firstWhere((t) => t.id == menu.menuTypeId).name;
                } catch (_) {
                  return menu.menuName;
                }
              }

              // Lập chỉ mục record hiện có theo (ngày + slot bữa) để tránh bị lọt sang POST
              final existingByDateAndSlot = <String, MenuRecordEntity>{};
              if (kDebugMode) {
                debugPrint('[MENU_BULK] selectedDates=${selectedDates.map(dateKey).toList()}');
              }
              for (final record in state.myMenuRecords) {
                if (!record.isActive) continue;

                String mealSlot = 'unknown';
                try {
                  final existingMenu = state.menus.firstWhere((m) => m.id == record.menuId);
                  final menuTypeName = inferMenuTypeNameByMenu(existingMenu);
                  mealSlot = inferMealSlot(menuTypeName);
                } catch (_) {
                  mealSlot = inferMealSlot(record.name);
                }

                if (mealSlot == 'unknown') continue;
                final existingKey = '${dateKey(record.date)}|$mealSlot';
                existingByDateAndSlot[existingKey] = record;
                if (kDebugMode) {
                  debugPrint(
                    '[MENU_BULK][EXISTING] key=$existingKey id=${record.id} menuId=${record.menuId} name=${record.name}',
                  );
                }
              }

              for (final date in selectedDates) {
                final normalizedDate = _normalizeDate(date);
                final daySelections = selectionsByDate[normalizedDate];
                if (daySelections == null || daySelections.isEmpty) continue;

                for (final menu in daySelections.values) {
                  requestDates.add(normalizedDate);

                  final selectedMealSlot = inferMealSlot(inferMenuTypeNameByMenu(menu));
                  final key = '${dateKey(normalizedDate)}|$selectedMealSlot';
                  final existingRecord = selectedMealSlot == 'unknown'
                      ? null
                      : existingByDateAndSlot[key];

                  if (existingRecord != null) {
                    // No-op update: cùng menuId thì bỏ qua
                    if (existingRecord.menuId != menu.id) {
                      saveRequests.add(SaveMenuRecordRequest(
                        menuId: menu.id,
                        name: menu.menuName,
                        date: normalizedDate,
                      ));
                      if (kDebugMode) {
                        debugPrint(
                          '[MENU_BULK][PLAN] SAVE_AS_UPDATE key=$key recordId=${existingRecord.id} oldMenuId=${existingRecord.menuId} newMenuId=${menu.id} newName=${menu.menuName}',
                        );
                      }
                    } else {
                      if (kDebugMode) {
                        debugPrint(
                          '[MENU_BULK][PLAN] SKIP_NO_OP key=$key recordId=${existingRecord.id} menuId=${menu.id}',
                        );
                      }
                    }
                  } else {
                    saveRequests.add(SaveMenuRecordRequest(
                      menuId: menu.id,
                      name: menu.menuName,
                      date: normalizedDate,
                    ));
                    if (kDebugMode) {
                      debugPrint(
                        '[MENU_BULK][PLAN] SAVE_AS_CREATE key=$key menuId=${menu.id} name=${menu.menuName}',
                      );
                    }
                  }
                }
              }

              if (kDebugMode) {
                debugPrint(
                  '[MENU_BULK][SUMMARY] saveRequests=${saveRequests.length}',
                );
              }

              if (saveRequests.isEmpty) {
                AppToast.showWarning(
                  context,
                  message: AppStrings.menuPleaseSelectAtLeastOne,
                );
                return;
              }

              setState(() {
                _isBulkSaving = true;
              });

              AppLoading.show(context, message: AppStrings.processing);

              this.context.read<MenuBloc>().add(
                MenuRecordsSaveRequested(
                  requests: saveRequests,
                  existingRecords: state.myMenuRecords,
                ),
              );

              Navigator.of(sheetContext).pop();

              AppToast.showSuccess(
                this.context,
                message: AppStrings.menuBulkSaveSuccess
                    .replaceAll('{count}', '${requestDates.length}'),
              );
            }

            final sortedSelectedDates = selectedDates.toList()..sort();
            final activeSelections = getSelectionsForDate(activeDate);

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                    padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 10 * scale),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppStrings.menuCreateForMultipleDays,
                            style: AppTextStyles.tinos(
                              fontSize: 22 * scale,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: Icon(
                            Icons.close,
                            size: 24 * scale,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20 * scale, 0, 20 * scale, 20 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(14 * scale),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12 * scale),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.menuSelectDaysToApply,
                                  style: AppTextStyles.arimo(
                                    fontSize: 15 * scale,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),

                                if (sortedSelectedDates.isNotEmpty) ...[
                                  SizedBox(height: 8 * scale),
                                  Builder(
                                    builder: (context) {
                                      final firstDate = sortedSelectedDates.first;
                                      final lastDate = sortedSelectedDates.last;

                                      // Monday-based calendar grid (T2 ... CN)
                                      final leadingEmpty = firstDate.weekday - DateTime.monday;
                                      final totalDays = lastDate.difference(firstDate).inDays + 1;

                                      final calendarCells = <DateTime?>[];
                                      for (int i = 0; i < leadingEmpty; i++) {
                                        calendarCells.add(null);
                                      }
                                      for (int i = 0; i < totalDays; i++) {
                                        calendarCells.add(firstDate.add(Duration(days: i)));
                                      }
                                      while (calendarCells.length % 7 != 0) {
                                        calendarCells.add(null);
                                      }

                                      Widget weekdayLabel(String text) {
                                        return Center(
                                          child: Text(
                                            text,
                                            style: AppTextStyles.arimo(
                                              fontSize: 12 * scale,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        );
                                      }

                                      return Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(child: weekdayLabel(AppStrings.weekDayMonday)),
                                              Expanded(child: weekdayLabel(AppStrings.weekDayTuesday)),
                                              Expanded(child: weekdayLabel(AppStrings.weekDayWednesday)),
                                              Expanded(child: weekdayLabel(AppStrings.weekDayThursday)),
                                              Expanded(child: weekdayLabel(AppStrings.weekDayFriday)),
                                              Expanded(child: weekdayLabel(AppStrings.weekDaySaturday)),
                                              Expanded(child: weekdayLabel(AppStrings.weekDaySunday)),
                                            ],
                                          ),
                                          SizedBox(height: 6 * scale),
                                          GridView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: calendarCells.length,
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 7,
                                              childAspectRatio: 1,
                                              crossAxisSpacing: 6,
                                              mainAxisSpacing: 6,
                                            ),
                                            itemBuilder: (context, index) {
                                              final date = calendarCells[index];
                                              if (date == null) {
                                                return const SizedBox.shrink();
                                              }

                                              final normalizedDate = _normalizeDate(date);
                                              final isActive = normalizedDate == _normalizeDate(activeDate);
                                              final hasMenuSelected =
                                                  (selectionsByDate[normalizedDate]?.isNotEmpty ?? false);

                                              return InkWell(
                                                borderRadius: BorderRadius.circular(10 * scale),
                                                onTap: () {
                                                  setModalState(() {
                                                    activeDate = normalizedDate;
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: isActive
                                                        ? AppColors.primary
                                                        : hasMenuSelected
                                                            ? AppColors.verified.withValues(alpha: 0.12)
                                                            : AppColors.white,
                                                    borderRadius: BorderRadius.circular(10 * scale),
                                                    border: Border.all(
                                                      color: isActive
                                                          ? AppColors.primary
                                                          : hasMenuSelected
                                                              ? AppColors.verified
                                                              : AppColors.borderLight,
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Center(
                                                        child: Text(
                                                          '${date.day}',
                                                          style: AppTextStyles.arimo(
                                                            fontSize: 13 * scale,
                                                            fontWeight: FontWeight.w700,
                                                            color: isActive
                                                                ? AppColors.white
                                                                : AppColors.textPrimary,
                                                          ),
                                                        ),
                                                      ),
                                                      if (hasMenuSelected)
                                                        Positioned(
                                                          top: 4 * scale,
                                                          right: 4 * scale,
                                                          child: Icon(
                                                            Icons.check_circle,
                                                            size: 12 * scale,
                                                            color: isActive
                                                                ? AppColors.white
                                                                : AppColors.verified,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: 12 * scale),
                          Text(
                            '${AppStrings.menuSelectMealsForBulk} - ${activeDate.day}/${activeDate.month}/${activeDate.year}',
                            style: AppTextStyles.arimo(
                              fontSize: 15 * scale,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 10 * scale),
                          ...sortedMenuTypes.map((menuType) {
                            final currentSelection = activeSelections[menuType.id];
                            final hasSelection = currentSelection != null;
                            return Container(
                              margin: EdgeInsets.only(bottom: 10 * scale),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12 * scale),
                                border: Border.all(
                                  color: hasSelection
                                      ? AppColors.verified
                                      : AppColors.borderLight,
                                  width: hasSelection ? 1.5 : 1,
                                ),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 34 * scale,
                                  height: 34 * scale,
                                  decoration: BoxDecoration(
                                    color: hasSelection
                                        ? AppColors.verified.withValues(alpha: 0.15)
                                        : AppColors.background,
                                    borderRadius: BorderRadius.circular(8 * scale),
                                  ),
                                  child: Center(
                                    child: _getMenuTypeIcon(
                                      menuType.name,
                                      18 * scale,
                                      hasSelection ? AppColors.verified : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  menuType.name,
                                  style: AppTextStyles.arimo(
                                    fontSize: 14 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: currentSelection == null
                                    ? null
                                    : Text(
                                        currentSelection.menuName,
                                        style: AppTextStyles.arimo(
                                          fontSize: 13 * scale,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (hasSelection)
                                      GestureDetector(
                                        onTap: () {
                                          setModalState(() {
                                            final daySelections = selectionsByDate[activeDate];
                                            daySelections?.remove(menuType.id);
                                            if (daySelections != null && daySelections.isEmpty) {
                                              selectionsByDate.remove(activeDate);
                                            }
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(right: 6 * scale),
                                          padding: EdgeInsets.all(2 * scale),
                                          decoration: BoxDecoration(
                                            color: AppColors.red.withValues(alpha: 0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            color: AppColors.red,
                                            size: 14 * scale,
                                          ),
                                        ),
                                      ),
                                    if (hasSelection)
                                      Padding(
                                        padding: EdgeInsets.only(right: 6 * scale),
                                        child: Icon(
                                          Icons.check_circle,
                                          color: AppColors.verified,
                                          size: 20 * scale,
                                        ),
                                      ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: AppColors.textSecondary,
                                      size: 20 * scale,
                                    ),
                                  ],
                                ),
                                onTap: () async {
                                  await openMenuListDrawerForType(context, menuType);
                                  setModalState(() {});
                                },
                              ),
                            );
                          }),
                          SizedBox(height: 20 * scale),
                          AppWidgets.primaryButton(
                            text: AppStrings.menuApplyForAllDays,
                            icon: Icon(
                              Icons.save,
                              size: 20 * scale,
                              color: AppColors.white,
                            ),
                            onPressed: handleBulkSave,
                            width: double.infinity,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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

  List<MenuTypeEntity> _getSortedMenuTypes(List<MenuTypeEntity> menuTypes) {
    final sorted = List<MenuTypeEntity>.from(menuTypes);
    sorted.sort((a, b) {
      int getOrder(String name) {
        if (name.contains('Sáng') && !name.contains('Phụ')) return 1;
        if (name.contains('Phụ') && name.contains('Sáng')) return 2;
        if (name.contains('Trưa')) return 3;
        if (name.contains('Phụ') && name.contains('Chiều')) return 4;
        if (name.contains('Chiều') && !name.contains('Phụ')) return 5;
        if (name.contains('Phụ') && name.contains('Tối')) return 6;
        if (name.contains('Tối')) return 7;
        return 99;
      }

      return getOrder(a.name).compareTo(getOrder(b.name));
    });
    return sorted;
  }

  List<DateTime> _getAllAllowedDates() {
    if (_minMenuDate == null || _maxMenuDate == null) return [];

    final days = <DateTime>[];
    var current = _normalizeDate(_minMenuDate!);
    final end = _normalizeDate(_maxMenuDate!);

    while (!current.isAfter(end)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  void _openCreateMenuFabOptions(BuildContext context, MenuLoaded state) {
    final scale = AppResponsive.scaleFactor(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20 * scale),
              topRight: Radius.circular(20 * scale),
            ),
          ),
          padding: EdgeInsets.fromLTRB(20 * scale, 12 * scale, 20 * scale, 24 * scale),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40 * scale,
                height: 4 * scale,
                margin: EdgeInsets.only(bottom: 14 * scale),
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2 * scale),
                ),
              ),
              AppWidgets.primaryButton(
                text: 'Từng ngày',
                icon: Icon(Icons.today, size: 20 * scale, color: AppColors.white),
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  _openMenuSelectionDrawer(context, state);
                },
                width: double.infinity,
              ),
              SizedBox(height: 10 * scale),
              AppWidgets.secondaryButton(
                text: 'Nhiều ngày',
                icon: Icon(Icons.calendar_month, size: 20 * scale, color: AppColors.textPrimary),
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  _openBulkCreateMenuSheet(context, state);
                },
                width: double.infinity,
              ),
            ],
          ),
        );
      },
    );
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
                      icon: SvgPicture.asset(
                        AppAssets.trash,
                        width: 20 * scale,
                        height: 20 * scale,
                        colorFilter: ColorFilter.mode(
                          AppColors.red,
                          BlendMode.srcIn,
                        ),
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
            // Hide loading on error
            AppLoading.hide(context);
            // Clear deletion tracking
            if (_deletingCount != null) {
              setState(() {
                _deletingCount = null;
              });
            }
            AppToast.showError(context, message: state.message);
          } else if (state is MenuLoaded && _deletingCount != null) {
            // Hide loading after successful deletion and reload
            AppLoading.hide(context);
            // Show success message
            final count = _deletingCount!;
            setState(() {
              _deletingCount = null;
            });
            AppToast.showSuccess(
              context,
              message: AppStrings.menuDeletedCount.replaceAll('{count}', '$count'),
            );
          } else if (state is MenuLoaded && _isBulkSaving) {
            AppLoading.hide(context);
            setState(() {
              _isBulkSaving = false;
            });
          }
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
                    minDate: _minMenuDate,
                    maxDate: _maxMenuDate,
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
                          customizedMenus: state.customizedMenus,
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

                        SizedBox(height: 18 * scale),
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

          // Show create options FAB when no unsaved selections
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
            onPressed: () => _openCreateMenuFabOptions(context, state),
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
      builder: (context) => BlocProvider.value(
        value: this.context.read<MenuBloc>(),
        child: MenuSelectionDrawer(
          selectedDate: _selectedDate,
          menuTypes: state.menuTypes,
          availableMenus: state.menus,
          customizedMenus: state.customizedMenus,
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
      ),
    );
  }
}
