import 'package:flutter/material.dart';

import '../../../../../core/apis/api_client.dart';
import '../../../../../core/apis/api_endpoints.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../../../features/auth/data/models/current_account_model.dart';
import '../../../../services/data/models/menu_record_model.dart';
import '../../../../services/data/models/menu_model.dart';
import '../../../../services/data/models/menu_type_model.dart';
import '../../../../../features/family_profile/domain/entities/family_profile_entity.dart';
import '../../../../../features/employee/customer_profile/data/datasources/employee_customer_profile_remote_datasource.dart';
import '../widgets/tabs/customer_profile_family_tab.dart';
import '../widgets/tabs/customer_profile_menu_tab.dart';
import '../widgets/tabs/customer_profile_account_tab.dart';
class EmployeeCustomerFamilyProfilesScreen extends StatefulWidget {
  final String customerId;
  final String customerName;

  const EmployeeCustomerFamilyProfilesScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<EmployeeCustomerFamilyProfilesScreen> createState() =>
      _EmployeeCustomerFamilyProfilesScreenState();
}

enum _MenuFilterMode { all, date, range }

class _EmployeeCustomerFamilyProfilesScreenState
    extends State<EmployeeCustomerFamilyProfilesScreen> {
  final _profileDs = EmployeeCustomerProfileRemoteDataSource();

  late Future<List<FamilyProfileEntity>> _familyProfilesFuture =
      _loadFamilyProfiles(widget.customerId);
  late Future<List<MenuRecordModel>> _menuRecordsFuture =
      _loadMenuRecordsByCurrentFilter();

  late Future<CurrentAccountModel> _accountFuture =
      _profileDs.getAccountById(widget.customerId);

  _MenuFilterMode _menuFilterMode = _MenuFilterMode.all;
  DateTime _selectedDate = DateTime.now();
  DateTime? _rangeFrom;
  DateTime? _rangeTo;

  /// Whether the current logged-in staff is a Home Staff (hide menu tab)
  bool _isHomeNurse = false;

  /// Responsive scale factor
  double get _scale => AppResponsive.scaleFactor(context);

  Map<int, MenuModel> _menuDetailsMap = {};
  List<MenuTypeModel> _menuTypes = [];

  @override
  void initState() {
    super.initState();
    _detectHomeStaffRole();
    _loadMenuDetails();
  }

  Future<void> _loadMenuDetails() async {
    try {
      final menus = await _profileDs.getAllMenus();
      final types = await _profileDs.getAllMenuTypes();
      if (mounted) {
        setState(() {
          _menuDetailsMap = {for (var m in menus) m.id: m};
          _menuTypes = types;
        });
      }
    } catch (e) {
      debugPrint('Failed to load menu details or types: $e');
    }
  }

  Future<void> _detectHomeStaffRole() async {
    try {
      final response = await ApiClient.dio.get(ApiEndpoints.getCurrentAccount);
      final data = response.data as Map<String, dynamic>?;
      if (data == null || !mounted) return;

      String? memberType = data['memberType'] as String?;
      if (memberType == null) {
        final ownerProfile = data['ownerProfile'] as Map<String, dynamic>?;
        memberType = ownerProfile?['memberTypeName'] as String?;
      }

      final raw = memberType?.toLowerCase().trim() ?? '';
      final isHome = raw == 'home-staff' ||
          raw == 'homestaff' ||
          raw == 'hoemstaff' ||
          raw == 'home nurse' ||
          raw.contains('tại nhà') ||
          raw.contains('tai nha') ||
          raw.contains('homecare');

      if (isHome && mounted) {
        setState(() {
          _isHomeNurse = true;
        });
      }
    } catch (_) {
      // Fail silently – default to showing all tabs
    }
  }

  Future<List<FamilyProfileEntity>> _loadFamilyProfiles(String accountId) {
    return _profileDs.getFamilyProfilesByAccountId(accountId);
  }

  Future<List<MenuRecordModel>> _loadMenuRecordsByCurrentFilter() {
    switch (_menuFilterMode) {
      case _MenuFilterMode.all:
        return _profileDs.getMenuRecordsByCustomer(widget.customerId);
      case _MenuFilterMode.date:
        return _profileDs.getMenuRecordsByCustomerDate(
          customerId: widget.customerId,
          date: _selectedDate,
        );
      case _MenuFilterMode.range:
        if (_rangeFrom == null || _rangeTo == null) {
          throw Exception('Vui lòng chọn đủ ngày bắt đầu và kết thúc');
        }
        return _profileDs.getMenuRecordsByCustomerDateRange(
          customerId: widget.customerId,
          from: _rangeFrom!,
          to: _rangeTo!,
        );
    }
  }

  Future<void> _pickSingleDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
      _menuFilterMode = _MenuFilterMode.date;
      _menuRecordsFuture = _loadMenuRecordsByCurrentFilter();
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _rangeFrom != null && _rangeTo != null
          ? DateTimeRange(start: _rangeFrom!, end: _rangeTo!)
          : null,
    );

    if (picked == null) return;

    setState(() {
      _rangeFrom = picked.start;
      _rangeTo = picked.end;
      _menuFilterMode = _MenuFilterMode.range;
      _menuRecordsFuture = _loadMenuRecordsByCurrentFilter();
    });
  }

  Future<void> _createMenuRecordByStaff() async => _showMenuSelectionSheet(null);

  Future<void> _updateMenuRecordByStaff(MenuRecordModel record) async => _showMenuSelectionSheet(record);

  Future<void> _showMenuSelectionSheet(MenuRecordModel? existingRecord) async {
    // 1. Fetch available menus
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    List<MenuModel> availableMenus = [];
    try {
      availableMenus = await _profileDs.getAllMenus();
      if (!mounted) return;
      Navigator.pop(context); // hide loader
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        AppToast.showError(context, message: 'Lỗi tải thực đơn: $e');
        return;
      }
    }

    if (availableMenus.isEmpty) {
      if (mounted) AppToast.showError(context, message: 'Chưa có thực đơn mẫu nào.');
      return;
    }

    // 2. Initial state
    MenuModel? selectedMenu;
    DateTime pickedDate = existingRecord?.date ?? DateTime.now();
    String mealType = 'Sáng';

    if (existingRecord != null) {
      final parts = existingRecord.name.split(' - ');
      if (parts.length > 1) mealType = parts.last;
      try {
        selectedMenu = availableMenus.firstWhere((m) => m.id == existingRecord.menuId);
      } catch (_) {}
    }

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30 * _scale)),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 12 * _scale),
                    width: 40 * _scale,
                    height: 4 * _scale,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24 * _scale),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          existingRecord == null ? 'Thêm thực đơn' : 'Cập nhật thực đơn',
                          style: AppTextStyles.tinos(
                            fontSize: 22 * _scale,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24 * _scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date & Meal Type Section
                          _sectionTitle('Thông tin thời gian'),
                          SizedBox(height: 12 * _scale),
                          Row(
                            children: [
                              Expanded(
                                child: _sheetActionCard(
                                  label: 'Ngày áp dụng',
                                  value: _fmtDate(pickedDate),
                                  icon: Icons.calendar_month_rounded,
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: pickedDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2100),
                                    );
                                    if (date != null) setStateSheet(() => pickedDate = date);
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16 * _scale),
                          _sectionTitle('Chọn buổi ăn'),
                          SizedBox(height: 12 * _scale),
                          if (_menuTypes.isEmpty)
                            const Center(child: CircularProgressIndicator())
                          else
                            Wrap(
                              spacing: 8 * _scale,
                              runSpacing: 8 * _scale,
                              children: _menuTypes.map((typeObj) {
                                final typeName = typeObj.name;
                                final isSelected = mealType == typeName;
                                return ChoiceChip(
                                  showCheckmark: false,
                                  padding: EdgeInsets.symmetric(horizontal: 14 * _scale, vertical: 8 * _scale),
                                  label: Text(
                                    typeName,
                                    style: AppTextStyles.arimo(
                                      fontSize: 13 * _scale,
                                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                      color: isSelected ? Colors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: AppColors.primary,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12 * _scale),
                                    side: BorderSide(
                                      color: isSelected ? AppColors.primary : AppColors.borderLight,
                                    ),
                                  ),
                                  onSelected: (_) {
                                    setStateSheet(() {
                                      mealType = typeName;
                                      if (selectedMenu != null && selectedMenu!.menuTypeName != mealType) {
                                        selectedMenu = null;
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),

                          SizedBox(height: 24 * _scale),
                          _sectionTitle('Chọn thực đơn mẫu'),
                          SizedBox(height: 12 * _scale),

                          // Menu List
                          Builder(builder: (context) {
                            final filteredMenus = availableMenus.where((m) => m.menuTypeName == mealType).toList();

                            return Container(
                              height: 220 * _scale,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20 * _scale),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: filteredMenus.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.restaurant_menu_rounded, color: Colors.grey[300], size: 48 * _scale),
                                          SizedBox(height: 12 * _scale),
                                          Text(
                                            'Chưa có thực đơn cho buổi $mealType',
                                            style: AppTextStyles.arimo(color: AppColors.textSecondary, fontSize: 13 * _scale),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: EdgeInsets.all(8 * _scale),
                                      itemCount: filteredMenus.length,
                                      separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.borderLight.withValues(alpha: 0.5)),
                                      itemBuilder: (context, index) {
                                        final m = filteredMenus[index];
                                        final isSelected = selectedMenu?.id == m.id;
                                        return ListTile(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * _scale)),
                                          selected: isSelected,
                                          selectedTileColor: AppColors.primary.withValues(alpha: 0.05),
                                          title: Text(
                                            m.menuName,
                                            style: AppTextStyles.arimo(
                                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                            ),
                                          ),
                                          subtitle: Text(m.menuTypeName, style: AppTextStyles.arimo(fontSize: 11 * _scale)),
                                          trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                                          onTap: () => setStateSheet(() => selectedMenu = m),
                                        );
                                      },
                                    ),
                            );
                          }),

                          if (selectedMenu != null) ...[
                            SizedBox(height: 24 * _scale),
                            _sectionTitle('Bản xem trước món ăn'),
                            SizedBox(height: 12 * _scale),
                            Container(
                              padding: EdgeInsets.all(16 * _scale),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20 * _scale),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                              ),
                              child: Column(
                                children: selectedMenu!.foods.map((food) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 8 * _scale),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8 * _scale),
                                          child: food.imageUrl != null
                                              ? Image.network(food.imageUrl!, width: 40 * _scale, height: 40 * _scale, fit: BoxFit.cover)
                                              : Container(width: 40 * _scale, height: 40 * _scale, color: Colors.grey[200]),
                                        ),
                                        SizedBox(width: 12 * _scale),
                                        Expanded(
                                          child: Text(
                                            food.name,
                                            style: AppTextStyles.arimo(fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                          SizedBox(height: 40 * _scale),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  Padding(
                    padding: EdgeInsets.all(24 * _scale),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54 * _scale,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * _scale)),
                        ),
                        onPressed: selectedMenu == null ? null : () => Navigator.pop(context, true),
                        child: Text(
                          existingRecord == null ? 'Thiết lập ngay' : 'Cập nhật ngay',
                          style: AppTextStyles.arimo(fontWeight: FontWeight.w900, fontSize: 15 * _scale),
                        ),
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

    if (confirmed != true || selectedMenu == null) return;

    try {
      final payload = {
        'menuId': selectedMenu!.id,
        'name': '${selectedMenu!.menuName} - $mealType',
        'date': _fmtDate(pickedDate),
      };
      if (existingRecord != null) payload['id'] = existingRecord.id;

      if (existingRecord == null) {
        await _profileDs.createMenuRecordsByStaff(customerId: widget.customerId, requests: [payload]);
      } else {
        await _profileDs.updateMenuRecordsByStaff(customerId: widget.customerId, requests: [payload]);
      }

      _refreshAll();
      if (mounted) AppToast.showSuccess(context, message: existingRecord == null ? 'Đã thêm thực đơn' : 'Đã cập nhật thực đơn');
    } catch (e) {
      if (mounted) AppToast.showError(context, message: 'Thất bại: $e');
    }
  }

  Widget _sheetActionCard({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16 * _scale),
      child: Container(
        padding: EdgeInsets.all(16 * _scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * _scale),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14 * _scale, color: AppColors.primary),
                SizedBox(width: 8 * _scale),
                Text(label, style: AppTextStyles.arimo(fontSize: 11 * _scale, color: AppColors.textSecondary)),
              ],
            ),
            SizedBox(height: 8 * _scale),
            Text(value, style: AppTextStyles.arimo(fontSize: 14 * _scale, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.arimo(
        fontSize: 14 * _scale,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Future<void> _deleteMenuRecordByStaff(MenuRecordModel record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa thực đơn "${record.name}" vào ngày ${_fmtDate(record.date)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa ngay'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _profileDs.deleteMenuRecordByStaff(
        menuRecordId: record.id,
        customerId: widget.customerId,
      );
      _refreshAll();
      if (mounted) AppToast.showSuccess(context, message: 'Đã xóa thực đơn');
    } catch (e) {
      if (mounted) AppToast.showError(context, message: 'Lỗi khi xóa: $e');
    }
  }

  Future<void> _viewMenuDetails(int menuId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final menu = await _profileDs.getMenuById(menuId);
      if (mounted) {
        Navigator.pop(context); // hide loader
        _showMenuDetailsDialog(menu);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // hide loader
        AppToast.showError(context, message: 'Không thể tải chi tiết thực đơn: $e');
      }
    }
  }

  void _showMenuDetailsDialog(MenuModel menu) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      menu.menuName,
                      style: AppTextStyles.arimo(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      menu.menuTypeName,
                      style: AppTextStyles.arimo(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (menu.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 12),
                      Text(
                        menu.description!,
                        style: AppTextStyles.arimo(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const Divider(height: 32),
                    Text(
                      'Danh sách món ăn',
                      style: AppTextStyles.arimo(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (menu.foods.isEmpty)
                      const Text('Chưa có món ăn nào trong thực đơn này.')
                    else
                      for (final food in menu.foods)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food.name,
                                style: AppTextStyles.arimo(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (food.description != null)
                                Text(
                                  food.description!,
                                  style: AppTextStyles.arimo(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _refreshAll() {
    setState(() {
      _familyProfilesFuture = _loadFamilyProfiles(widget.customerId);
      _menuRecordsFuture = _loadMenuRecordsByCurrentFilter();
      _accountFuture = _profileDs.getAccountById(widget.customerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    final isHomeNurse = _isHomeNurse;

    return DefaultTabController(
      length: isHomeNurse ? 2 : 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          toolbarHeight: 70 * scale,
          title: Text(
            'Hồ sơ khách hàng',
            style: AppTextStyles.arimo(
              fontSize: 20 * scale,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
          leading: Padding(
            padding: EdgeInsets.only(left: 8.0 * scale),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
              ),
              icon: Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textPrimary,
                size: 28 * scale,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 16 * scale),
              child: Row(
                children: [
                  _circleActionButton(
                    icon: Icons.refresh_rounded,
                    tooltip: 'Làm mới',
                    onPressed: _refreshAll,
                    scale: scale,
                  ),
                ],
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50 * scale),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14 * scale),
              ),
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10 * scale),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w800,
                ),
                unselectedLabelStyle: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  const Tab(text: 'Gia đình'),
                  if (!isHomeNurse) const Tab(text: 'Thực đơn'),
                  const Tab(text: 'Tài khoản'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            CustomerProfileFamilyTab(
              future: _familyProfilesFuture,
              customerId: widget.customerId,
              customerName: widget.customerName,
              scale: scale,
            ),
            if (!isHomeNurse)
              CustomerProfileMenuTab(
                future: _menuRecordsFuture,
                scale: scale,
                fmtDate: _fmtDate,
                filterWidget: _buildMenuFilterBar(scale),
                onViewDetails: _viewMenuDetails,
                onEdit: _updateMenuRecordByStaff,
                onDelete: _deleteMenuRecordByStaff,
                menuDetails: _menuDetailsMap,
              ),
            CustomerProfileAccountTab(
              future: _accountFuture,
              scale: scale,
              fmtDate: _fmtDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuFilterBar(double scale) {
    final selectedDateText = _fmtDate(_selectedDate);
    final isAll = _menuFilterMode == _MenuFilterMode.all;
    final isDate = _menuFilterMode == _MenuFilterMode.date;
    final isRange = _menuFilterMode == _MenuFilterMode.range;

    return Padding(
      padding: EdgeInsets.fromLTRB(16 * scale, 16 * scale, 16 * scale, 8 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Prominent Add Button
          InkWell(
            onTap: _createMenuRecordByStaff,
            borderRadius: BorderRadius.circular(16 * scale),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14 * scale),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(16 * scale),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 20 * scale),
                  SizedBox(width: 10 * scale),
                  Text(
                    'Thiết lập thực đơn mới',
                    style: AppTextStyles.arimo(
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16 * scale),
          
          // Filters
          Row(
            children: [
              Text(
                'Bộ lọc:',
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: SizedBox(
                  height: 40 * scale,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _filterChip(
                        label: 'Tất cả',
                        icon: Icons.grid_view_rounded,
                        isSelected: isAll,
                        onTap: () {
                          setState(() {
                            _menuFilterMode = _MenuFilterMode.all;
                            _menuRecordsFuture = _loadMenuRecordsByCurrentFilter();
                          });
                        },
                        scale: scale,
                      ),
                      SizedBox(width: 8 * scale),
                      _filterChip(
                        label: selectedDateText,
                        icon: Icons.calendar_today_rounded,
                        isSelected: isDate,
                        onTap: _pickSingleDate,
                        scale: scale,
                      ),
                      SizedBox(width: 8 * scale),
                      _filterChip(
                        label: isRange ? '${_fmtDate(_rangeFrom!)} → ${_fmtDate(_rangeTo!)}' : 'Theo khoảng',
                        icon: Icons.date_range_rounded,
                        isSelected: isRange,
                        onTap: _pickDateRange,
                        scale: scale,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          Divider(color: AppColors.borderLight.withValues(alpha: 0.5)),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required double scale,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12 * scale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14 * scale, color: isSelected ? Colors.white : AppColors.textSecondary),
            SizedBox(width: 6 * scale),
            Text(
              label,
              style: AppTextStyles.arimo(
                fontSize: 12 * scale,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    bool isLoading = false,
    required double scale,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: isLoading
            ? SizedBox(
                width: 18 * scale,
                height: 18 * scale,
                child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              )
            : Icon(icon, color: AppColors.primary, size: 22 * scale),
      ),
    );
  }

  String _fmtDate(DateTime value) => value.toIso8601String().split('T').first;
}
