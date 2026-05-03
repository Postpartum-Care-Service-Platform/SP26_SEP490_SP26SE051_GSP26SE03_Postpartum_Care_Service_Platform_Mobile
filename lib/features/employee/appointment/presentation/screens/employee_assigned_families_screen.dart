import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../../core/apis/api_client.dart';
import '../../../../../core/apis/api_endpoints.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/app_app_bar.dart';
import '../../../../../features/employee/customer_profile/presentation/screens/employee_customer_family_profiles_screen.dart';
import '../../../../../features/employee/shell/presentation/widgets/employee_scaffold.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../operations/presentation/screens/staff_health_care_flow_screen.dart';
import '../../../customer_profile/data/datasources/employee_customer_profile_remote_datasource.dart';
import '../../../../family_profile/domain/entities/family_profile_entity.dart';

class EmployeeAssignedFamiliesScreen extends StatefulWidget {
  final VoidCallback? onBackToDefaultStaffPage;

  const EmployeeAssignedFamiliesScreen({
    super.key,
    this.onBackToDefaultStaffPage,
  });

  @override
  State<EmployeeAssignedFamiliesScreen> createState() =>
      _EmployeeAssignedFamiliesScreenState();
}

class _EmployeeAssignedFamiliesScreenState
    extends State<EmployeeAssignedFamiliesScreen> {
  late DateTime _fromDate;
  late DateTime _toDate;
  late Future<List<AssignedCustomer>> _futureCustomers;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, 1);
    _toDate = DateTime(now.year, now.month + 1, 0);
    _futureCustomers = _loadAssignedCustomers();
  }

  Future<List<AssignedCustomer>> _loadAssignedCustomers() async {
    final fromStr = _dateOnly(_fromDate);
    final toStr = _dateOnly(_toDate);

    final response = await ApiClient.dio.get(
      ApiEndpoints.myStaffSchedules,
      queryParameters: {'from': fromStr, 'to': toStr},
    );

    final data = response.data as List<dynamic>? ?? const [];
    final byCustomer = <String, List<Map<String, dynamic>>>{};

    for (final item in data) {
      final row = item as Map<String, dynamic>;
      final family = row['familyScheduleResponse'] as Map<String, dynamic>?;

      final customerId = (family?['customerId'] ?? '').toString().trim();
      if (customerId.isEmpty) {
        continue;
      }

      byCustomer.putIfAbsent(customerId, () => []).add(row);
    }

    final result = <AssignedCustomer>[];
    for (final entry in byCustomer.entries) {
      final customerId = entry.key;
      final items = entry.value;

      final first = items.first;
      final family = first['familyScheduleResponse'] as Map<String, dynamic>?;

      final displayName =
          (family?['customerName'] ?? family?['name'] ?? customerId).toString();
      final avatarUrl = (family?['customerAvatar'] ?? '').toString();
      final roomName = (first['roomName'] ?? '').toString();

      final activities =
          items.map((row) {
            final familyMap =
                row['familyScheduleResponse'] as Map<String, dynamic>?;
            return AssignedActivity(
              staffScheduleId: (row['id'] as num?)?.toInt() ?? 0,
              startAt: _parseScheduleDateTime(
                familyMap?['workDate']?.toString(),
                familyMap?['startTime']?.toString(),
              ),
              endAt: _parseScheduleDateTime(
                familyMap?['workDate']?.toString(),
                familyMap?['endTime']?.toString(),
              ),
              activity: (familyMap?['activity'] ?? 'Hoạt động').toString(),
              status: (familyMap?['status'] ?? 'Scheduled').toString(),
              note: (familyMap?['note'] ?? '').toString(),
              checkedAt: row['checkedAt'] != null
                  ? DateTime.tryParse(row['checkedAt'].toString())
                  : null,
              images:
                  (row['images'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [],
            );
          }).toList()..sort((a, b) {
            final aTime = a.startAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bTime = b.startAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return aTime.compareTo(bTime);
          });

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final hasTodayActivity = activities.any(
        (a) =>
            a.startAt != null &&
            DateTime(
              a.startAt!.year,
              a.startAt!.month,
              a.startAt!.day,
            ).isAtSameMomentAs(today),
      );

      final isCurrentlyActive = activities.any(
        (a) =>
            a.startAt != null &&
            a.endAt != null &&
            now.isAfter(a.startAt!) &&
            now.isBefore(a.endAt!),
      );

      final hasUpcomingActivity = activities.any(
        (a) =>
            a.startAt != null &&
            DateTime(
              a.startAt!.year,
              a.startAt!.month,
              a.startAt!.day,
            ).isAtSameMomentAs(today) &&
            a.status.toLowerCase() == 'scheduled',
      );

      result.add(
        AssignedCustomer(
          customerId: customerId,
          displayName: displayName,
          avatarUrl: avatarUrl,
          roomName: roomName,
          assignmentsCount: items.length,
          activities: activities,
          hasTodayActivity: hasTodayActivity,
          isCurrentlyActive: isCurrentlyActive,
          hasUpcomingActivity: hasUpcomingActivity,
        ),
      );
    }

    result.sort((a, b) {
      if (a.isCurrentlyActive && !b.isCurrentlyActive) return -1;
      if (!a.isCurrentlyActive && b.isCurrentlyActive) return 1;
      if (a.hasUpcomingActivity && !b.hasUpcomingActivity) return -1;
      if (!a.hasUpcomingActivity && b.hasUpcomingActivity) return 1;
      if (a.hasTodayActivity && !b.hasTodayActivity) return -1;
      if (!a.hasTodayActivity && b.hasTodayActivity) return 1;
      return a.displayName.compareTo(b.displayName);
    });
    return result;
  }

  void _navigateToTimeline(BuildContext context, AssignedCustomer customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeActivitiesTimelineScreen(
          customer: customer,
          onStatusUpdated: () {
            setState(() {
              _futureCustomers = _loadAssignedCustomers();
            });
          },
        ),
      ),
    );
  }

  String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  DateTime? _parseScheduleDateTime(String? date, String? time) {
    if (date == null || date.isEmpty) {
      return null;
    }
    final parsedDate = DateTime.tryParse(date);
    if (parsedDate == null) {
      return null;
    }

    final safeTime = (time ?? '').split('.').first;
    if (safeTime.isEmpty) {
      return DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
    }

    final parts = safeTime.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      hour,
      minute,
    );
  }

  Future<void> _selectDateRange() async {
    final initialRange = DateTimeRange(start: _fromDate, end: _toDate);
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: initialRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() {
        _fromDate = result.start;
        _toDate = result.end;
        _futureCustomers = _loadAssignedCustomers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    return EmployeeScaffold(
      appBar: AppAppBar(
        title: 'Gia đình được phân công',
        centerTitle: true,
        showBackButton: true,
        onBackPressed: widget.onBackToDefaultStaffPage,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _futureCustomers = _loadAssignedCustomers();
              });
            },
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: FutureBuilder<List<AssignedCustomer>>(
        future: _futureCustomers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final customers = snapshot.data ?? const <AssignedCustomer>[];

          if (snapshot.hasError) {
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _futureCustomers = _loadAssignedCustomers();
                });
                await _futureCustomers;
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 100 * scale),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(24 * scale),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 48 * scale,
                            color: AppColors.red,
                          ),
                          SizedBox(height: 16 * scale),
                          Text(
                            'Tải dữ liệu thất bại\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.arimo(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 24 * scale),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _futureCustomers = _loadAssignedCustomers();
                              });
                            },
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (customers.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _futureCustomers = _loadAssignedCustomers();
                });
                await _futureCustomers;
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 100 * scale),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(24 * scale),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 64 * scale,
                            color: AppColors.borderLight,
                          ),
                          SizedBox(height: 16 * scale),
                          Text(
                            'Bạn chưa được phân công hộ gia đình nào.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.arimo(
                              fontSize: 16 * scale,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _futureCustomers = _loadAssignedCustomers();
              });
              await _futureCustomers;
            },
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20 * scale,
                    16 * scale,
                    20 * scale,
                    0,
                  ),
                  child: _buildWelcomeHeader(scale),
                ),
                Expanded(child: _buildMainContent(customers, scale)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent(List<AssignedCustomer> customers, double scale) {
    var displayCustomers = customers;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      displayCustomers = customers
          .where((c) => c.displayName.toLowerCase().contains(q))
          .toList();
    }

    Widget searchBar = Padding(
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        12 * scale,
        20 * scale,
        4 * scale,
      ),
      child: TextField(
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        decoration: InputDecoration(
          hintText: 'Tìm kiếm gia đình...',
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12 * scale),
            borderSide: BorderSide(color: AppColors.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12 * scale),
            borderSide: BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12 * scale),
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );

    if (customers.length == 1 && _searchQuery.isEmpty) {
      final customer = customers.first;
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: 20 * scale,
          vertical: 20 * scale,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FocusFamilyCard(
              customer: customer,
              onTap: () => _navigateToTimeline(context, customer),
            ),
            SizedBox(height: 24 * scale),
            _buildQuickStats(customer, scale),
          ],
        ),
      );
    }

    final todayFamilies = displayCustomers
        .where((c) => c.hasTodayActivity)
        .toList();
    final otherFamilies = displayCustomers
        .where((c) => !c.hasTodayActivity)
        .toList();

    return Column(
      children: [
        if (customers.length > 5) searchBar,
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: 16 * scale,
              vertical: 16 * scale,
            ),
            children: [
              if (todayFamilies.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.only(left: 4 * scale, bottom: 12 * scale),
                  child: Text(
                    'CÓ LỊCH HÔM NAY',
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                ...todayFamilies.map(
                  (c) => Padding(
                    padding: EdgeInsets.only(bottom: 16 * scale),
                    child: _FamilyCard(
                      customer: c,
                      onTap: () => _navigateToTimeline(context, c),
                    ),
                  ),
                ),
                SizedBox(height: 8 * scale),
              ],
              if (otherFamilies.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.only(
                    left: 4 * scale,
                    bottom: 12 * scale,
                    top: todayFamilies.isNotEmpty ? 8 * scale : 0,
                  ),
                  child: Text(
                    'CÁC GIA ĐÌNH KHÁC',
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                ...otherFamilies.map(
                  (c) => Padding(
                    padding: EdgeInsets.only(bottom: 16 * scale),
                    child: _FamilyCard(
                      customer: c,
                      onTap: () => _navigateToTimeline(context, c),
                    ),
                  ),
                ),
              ],
              if (displayCustomers.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(32 * scale),
                    child: Text(
                      'Không tìm thấy gia đình phù hợp.',
                      style: AppTextStyles.arimo(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader(double scale) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting = 'Chào buổi sáng';
    if (hour >= 12 && hour < 18) greeting = 'Chào buổi chiều';
    if (hour >= 18) greeting = 'Chào buổi tối';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: AppTextStyles.arimo(
            fontSize: 14 * scale,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          'Bắt đầu ngày làm việc nào!',
          style: AppTextStyles.tinos(
            fontSize: 24 * scale,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16 * scale),
        _buildDateRangeIndicator(scale),
      ],
    );
  }

  Widget _buildDateRangeIndicator(double scale) {
    final df = DateFormat('dd/MM/yyyy');
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_month_rounded,
            color: AppColors.primary,
            size: 20 * scale,
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lọc theo thời gian',
                  style: AppTextStyles.arimo(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  '${df.format(_fromDate)} - ${df.format(_toDate)}',
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _selectDateRange,
            icon: Icon(Icons.edit_calendar_rounded, size: 18 * scale),
            label: const Text('Thay đổi'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 12 * scale),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(AssignedCustomer customer, double scale) {
    final doneCount = customer.activities
        .where((a) => a.status.toLowerCase().contains('done'))
        .length;

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Hoàn thành',
            value: '$doneCount',
            icon: Icons.task_alt_rounded,
            color: const Color(0xFF10B981),
            scale: scale,
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: _StatTile(
            label: 'Tổng công việc',
            value: '${customer.assignmentsCount}',
            icon: Icons.assignment_outlined,
            color: const Color(0xFF3B82F6),
            scale: scale,
          ),
        ),
      ],
    );
  }
}

class AssignedCustomer {
  final String customerId;
  final String displayName;
  final String avatarUrl;
  final String roomName;
  final int assignmentsCount;
  final List<AssignedActivity> activities;
  final bool hasTodayActivity;
  final bool isCurrentlyActive;
  final bool hasUpcomingActivity;

  AssignedCustomer({
    required this.customerId,
    required this.displayName,
    required this.avatarUrl,
    required this.roomName,
    required this.assignmentsCount,
    required this.activities,
    this.hasTodayActivity = false,
    this.isCurrentlyActive = false,
    this.hasUpcomingActivity = false,
  });
}

class AssignedActivity {
  final int staffScheduleId;
  final DateTime? startAt;
  final DateTime? endAt;
  final String activity;
  final String status;
  final String note;
  final DateTime? checkedAt;
  final List<String> images;

  AssignedActivity({
    required this.staffScheduleId,
    required this.startAt,
    required this.endAt,
    required this.activity,
    required this.status,
    required this.note,
    this.checkedAt,
    this.images = const [],
  });

  AssignedActivity copyWith({
    String? status,
    String? note,
    DateTime? checkedAt,
    List<String>? images,
  }) {
    return AssignedActivity(
      staffScheduleId: staffScheduleId,
      startAt: startAt,
      endAt: endAt,
      activity: activity,
      status: status ?? this.status,
      note: note ?? this.note,
      checkedAt: checkedAt ?? this.checkedAt,
      images: images ?? this.images,
    );
  }
}

class _CalendarDay {
  final DateTime date;
  final List<AssignedActivity> activities;

  _CalendarDay({required this.date, required this.activities});
}

class _FocusFamilyCard extends StatelessWidget {
  final AssignedCustomer customer;
  final VoidCallback onTap;

  const _FocusFamilyCard({required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final now = DateTime.now();
    final todayStr = DateFormat('dd/MM').format(now);

    final todayActivities = customer.activities
        .where(
          (a) =>
              a.startAt != null &&
              a.startAt!.year == now.year &&
              a.startAt!.month == now.month &&
              a.startAt!.day == now.day,
        )
        .toList();

    AssignedActivity? currentOrNext;
    if (customer.isCurrentlyActive) {
      currentOrNext = todayActivities
          .where(
            (a) =>
                a.startAt != null &&
                a.endAt != null &&
                now.isAfter(a.startAt!) &&
                now.isBefore(a.endAt!),
          )
          .firstOrNull;
    } else {
      currentOrNext = todayActivities
          .where((a) => a.startAt != null && a.startAt!.isAfter(now))
          .toList()
          .firstOrNull;
    }

    final displayActivity =
        currentOrNext ??
        (todayActivities.isNotEmpty ? todayActivities.first : null);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: customer.hasUpcomingActivity
              ? AppColors.primary.withValues(alpha: 0.03)
              : AppColors.white,
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(
            color: customer.hasUpcomingActivity
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.3),
            width: customer.hasUpcomingActivity ? 2 : 1,
          ),
          boxShadow: customer.hasUpcomingActivity
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 12 * scale,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20 * scale),
              child: Row(
                children: [
                  Hero(
                    tag: 'avatar_${customer.customerId}',
                    child: Container(
                      width: 64 * scale,
                      height: 64 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(
                            customer.avatarUrl.isNotEmpty
                                ? customer.avatarUrl
                                : 'https://ui-avatars.com/api/?name=${customer.displayName}&background=random',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16 * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (customer.isCurrentlyActive)
                          Text(
                            '• ĐANG TRONG GIỜ',
                            style: AppTextStyles.arimo(
                              fontSize: 10 * scale,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        Text(
                          customer.displayName,
                          style: AppTextStyles.tinos(
                            fontSize: 22 * scale,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          customer.roomName.isNotEmpty
                              ? customer.roomName
                              : 'Chưa có thông tin phòng',
                          style: AppTextStyles.arimo(
                            fontSize: 13 * scale,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                20 * scale,
                0,
                20 * scale,
                20 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  SizedBox(height: 16 * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'HOẠT ĐỘNG TIẾP THEO ($todayStr)',
                        style: AppTextStyles.arimo(
                          fontSize: 10 * scale,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12 * scale),
                  if (todayActivities.isEmpty)
                    Text(
                      'Hôm nay không có lịch phân công.',
                      style: AppTextStyles.arimo(
                        fontSize: 13 * scale,
                        color: AppColors.textSecondary,
                      ),
                    )
                  else if (displayActivity != null)
                    Row(
                      children: [
                        Text(
                          DateFormat('HH:mm').format(displayActivity.startAt!),
                          style: AppTextStyles.arimo(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 12 * scale),
                        Expanded(
                          child: Text(
                            displayActivity.activity,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.arimo(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilyCard extends StatelessWidget {
  final AssignedCustomer customer;
  final VoidCallback onTap;

  const _FamilyCard({required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: customer.hasUpcomingActivity
              ? AppColors.primary.withValues(alpha: 0.03)
              : AppColors.white,
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(
            color: customer.hasUpcomingActivity
                ? AppColors.primary
                : (customer.hasTodayActivity
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : AppColors.borderLight.withValues(alpha: 0.5)),
            width: customer.hasUpcomingActivity ? 2 : 1,
          ),
          boxShadow: customer.hasUpcomingActivity
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 8 * scale,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8 * scale),
              child: Image.network(
                customer.avatarUrl.isNotEmpty
                    ? customer.avatarUrl
                    : 'https://ui-avatars.com/api/?name=${customer.displayName}&background=random',
                width: 44 * scale,
                height: 44 * scale,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.displayName,
                    style: AppTextStyles.arimo(
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${customer.assignmentsCount} công việc trong khoảng thời gian',
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (customer.isCurrentlyActive)
              Container(
                width: 8 * scale,
                height: 8 * scale,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              )
            else if (customer.hasUpcomingActivity)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8 * scale,
                  vertical: 4 * scale,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
                child: Text(
                  'SẮP TỚI',
                  style: AppTextStyles.arimo(
                    fontSize: 9 * scale,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              )
            else
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.borderLight,
              ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double scale;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.arimo(
              fontSize: 22 * scale,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          SizedBox(height: 2 * scale),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.arimo(
              fontSize: 9 * scale,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInDetails {
  final String note;
  final List<String> imagePaths;

  _CheckInDetails({required this.note, required this.imagePaths});
}

enum _ActivityFilter { all, scheduled, missed, staffDone, done }

class _FilterTabs extends StatelessWidget {
  final _ActivityFilter current;
  final ValueChanged<_ActivityFilter> onChanged;

  const _FilterTabs({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _ActivityFilter.values.map((v) {
          final isSelected = v == current;
          String label = 'Tất cả';
          switch (v) {
            case _ActivityFilter.scheduled:
              label = 'Sắp tới';
              break;
            case _ActivityFilter.missed:
              label = 'Đã lỡ';
              break;
            case _ActivityFilter.staffDone:
              label = 'Đã làm';
              break;
            case _ActivityFilter.done:
              label = 'Hoàn tất';
              break;
            case _ActivityFilter.all:
              label = 'Tất cả';
              break;
          }

          return Padding(
            padding: EdgeInsets.only(right: 8 * scale),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onChanged(v),
              selectedColor: AppColors.primary,
              labelStyle: AppTextStyles.arimo(
                fontSize: 13 * scale,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ActivitiesVerticalList extends StatelessWidget {
  final String customerId;
  final List<_CalendarDay> days;
  final Function(AssignedActivity) onCheckPressed;

  const _ActivitiesVerticalList({
    required this.customerId,
    required this.days,
    required this.onCheckPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    if (days.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40 * scale),
          child: Column(
            children: [
              Icon(
                Icons.event_busy_rounded,
                size: 48 * scale,
                color: AppColors.borderLight,
              ),
              SizedBox(height: 12 * scale),
              Text(
                'Không có hoạt động nào phù hợp với bộ lọc.',
                style: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: days.map((day) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12 * scale),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10 * scale,
                      vertical: 4 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4 * scale),
                    ),
                    child: Text(
                      DateFormat('EEEE, dd/MM').format(day.date),
                      style: AppTextStyles.arimo(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(indent: 12)),
                ],
              ),
            ),
            ...day.activities.asMap().entries.map((entry) {
              final idx = entry.key;
              final act = entry.value;
              final isLast = idx == day.activities.length - 1;
              return _ActivityItem(
                activity: act,
                onCheck: () => onCheckPressed(act),
                customerId: customerId,
                isLast: isLast,
              );
            }),
          ],
        );
      }).toList(),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final AssignedActivity activity;
  final VoidCallback onCheck;
  final bool isLast;
  final String customerId;

  const _ActivityItem({
    required this.activity,
    required this.onCheck,
    required this.customerId,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final statusColor = _getStatusColor(activity.status);
    final isDone = activity.status.toLowerCase().contains('done');
    final startTime = activity.startAt != null
        ? DateFormat('HH:mm').format(activity.startAt!)
        : '--:--';

    final isScheduled = activity.status.toLowerCase() == 'scheduled';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday =
        activity.startAt != null &&
        DateTime(
          activity.startAt!.year,
          activity.startAt!.month,
          activity.startAt!.day,
        ).isAtSameMomentAs(today);
    final hasStarted =
        activity.startAt != null && now.isAfter(activity.startAt!);

    final activityNameLower = activity.activity.toLowerCase();
    final isForMom =
        activityNameLower.contains('mẹ') ||
        activityNameLower.contains('sản phụ');
    final isForBaby =
        activityNameLower.contains('bé') || activityNameLower.contains('trẻ');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: Time mile stone
          SizedBox(
            width: 45 * scale,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  startTime,
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Bắt đầu',
                  style: AppTextStyles.arimo(
                    fontSize: 10 * scale,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8 * scale),
          // Middle: Timeline line & dot
          SizedBox(
            width: 20 * scale,
            child: Column(
              children: [
                Container(
                  width: 14 * scale,
                  height: 14 * scale,
                  margin: EdgeInsets.only(top: 2 * scale),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: statusColor, width: 3 * scale),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.2),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2 * scale,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            statusColor.withValues(alpha: 0.5),
                            AppColors.borderLight.withValues(alpha: 0.2),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Right: Content Card
          Expanded(
            child: GestureDetector(
              onTap: isDone
                  ? () => _showActivityDetailsDialog(context, activity)
                  : null,
              child: Container(
                margin: EdgeInsets.only(bottom: 24 * scale),
                padding: EdgeInsets.all(16 * scale),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16 * scale),
                  border: Border.all(
                    color: AppColors.borderLight.withValues(alpha: 0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.activity,
                                style: AppTextStyles.arimo(
                                  fontSize: 16 * scale,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (isForMom || isForBaby) ...[
                                SizedBox(height: 6 * scale),
                                Wrap(
                                  spacing: 6 * scale,
                                  runSpacing: 4 * scale,
                                  children: [
                                    if (isForMom)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6 * scale,
                                          vertical: 2 * scale,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFDF2F8),
                                          borderRadius: BorderRadius.circular(
                                            4 * scale,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFFBCFE8),
                                          ),
                                        ),
                                        child: Text(
                                          'Chăm sóc mẹ',
                                          style: AppTextStyles.arimo(
                                            fontSize: 10 * scale,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFFBE185D),
                                          ),
                                        ),
                                      ),
                                    if (isForBaby)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6 * scale,
                                          vertical: 2 * scale,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(
                                            4 * scale,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFBFDBFE),
                                          ),
                                        ),
                                        child: Text(
                                          'Chăm sóc bé',
                                          style: AppTextStyles.arimo(
                                            fontSize: 10 * scale,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1D4ED8),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(width: 8 * scale),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8 * scale,
                            vertical: 4 * scale,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6 * scale),
                          ),
                          child: Text(
                            _getStatusText(activity.status),
                            style: AppTextStyles.arimo(
                              fontSize: 11 * scale,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * scale),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14 * scale,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4 * scale),
                        Text(
                          _formatTimeRange(activity.startAt, activity.endAt),
                          style: AppTextStyles.arimo(
                            fontSize: 12 * scale,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (activity.note.isNotEmpty) ...[
                      SizedBox(height: 10 * scale),
                      Container(
                        padding: EdgeInsets.all(10 * scale),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.borderLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8 * scale),
                          border: Border.all(
                            color: AppColors.borderLight.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          activity.note,
                          style: AppTextStyles.arimo(
                            fontSize: 13 * scale,
                            color: AppColors.textSecondary,
                          ).copyWith(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                    if (isScheduled && isToday) ...[
                      SizedBox(height: 16 * scale),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showHealthRecordSelectionSheet(context, scale),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[700],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 10 * scale),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10 * scale),
                            ),
                          ),
                          icon: Icon(
                            Icons.medical_services_outlined,
                            size: 18 * scale,
                          ),
                          label: Text(
                            'Ghi nhận sức khỏe',
                            style: AppTextStyles.arimo(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      if (hasStarted) ...[
                        SizedBox(height: 8 * scale),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: onCheck,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.orange),
                              foregroundColor: Colors.orange,
                              padding: EdgeInsets.symmetric(
                                vertical: 10 * scale,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10 * scale),
                              ),
                            ),
                            icon: Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18 * scale,
                            ),
                            label: Text(
                              'Xác nhận hoàn tất',
                              style: AppTextStyles.arimo(
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                    if (isDone) ...[
                      SizedBox(height: 10 * scale),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Nhấn để xem chi tiết',
                            style: AppTextStyles.arimo(
                              fontSize: 12 * scale,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 4 * scale),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 10 * scale,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showActivityDetailsDialog(
    BuildContext context,
    AssignedActivity activity,
  ) {
    final scale = AppResponsive.scaleFactor(context);
    final statusColor = _getStatusColor(activity.status);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * scale),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20 * scale),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primary,
                        size: 24 * scale,
                      ),
                      SizedBox(width: 8 * scale),
                      Expanded(
                        child: Text(
                          'Chi tiết hoạt động',
                          style: AppTextStyles.arimo(
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * scale),
                  Text(
                    activity.activity,
                    style: AppTextStyles.arimo(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8 * scale,
                          vertical: 4 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6 * scale),
                        ),
                        child: Text(
                          _getStatusText(activity.status),
                          style: AppTextStyles.arimo(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * scale),
                  if (activity.startAt != null && activity.endAt != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16 * scale,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 8 * scale),
                        Text(
                          'Thời gian: ${_formatTimeRange(activity.startAt, activity.endAt)}',
                          style: AppTextStyles.arimo(
                            fontSize: 14 * scale,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * scale),
                  ],
                  if (activity.checkedAt != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 16 * scale,
                          color: Colors.green,
                        ),
                        SizedBox(width: 8 * scale),
                        Text(
                          'Xác nhận lúc: ${DateFormat('HH:mm - dd/MM/yyyy').format(activity.checkedAt!.toLocal())}',
                          style: AppTextStyles.arimo(
                            fontSize: 14 * scale,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * scale),
                  ],
                  if (activity.note.isNotEmpty) ...[
                    SizedBox(height: 8 * scale),
                    Text(
                      'Ghi chú:',
                      style: AppTextStyles.arimo(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12 * scale),
                      decoration: BoxDecoration(
                        color: AppColors.borderLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8 * scale),
                        border: Border.all(
                          color: AppColors.borderLight.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        activity.note,
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          color: AppColors.textSecondary,
                        ).copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  if (activity.images.isNotEmpty) ...[
                    SizedBox(height: 16 * scale),
                    Text(
                      'Hình ảnh minh chứng:',
                      style: AppTextStyles.arimo(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8 * scale,
                        mainAxisSpacing: 8 * scale,
                      ),
                      itemCount: activity.images.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            _showFullScreenImage(
                              context,
                              activity.images[index],
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8 * scale),
                            child: Image.network(
                              activity.images[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(0),
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    color: Colors.black87,
                    child: InteractiveViewer(
                      child: Image.network(imageUrl, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return const Color(0xFF3B82F6);
      case 'missed':
        return Colors.red;
      case 'staffdone':
      case 'staff_done':
        return const Color(0xFFF59E0B);
      case 'done':
      case 'completed':
        return const Color(0xFF10B981);
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Sắp tới';
      case 'missed':
        return 'Đã lỡ';
      case 'staffdone':
      case 'staff_done':
        return 'Đã làm';
      case 'done':
      case 'completed':
        return 'Hoàn tất';
      default:
        return 'Chưa xác định';
    }
  }

  String _formatTimeRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '--:--';
    final fmt = DateFormat('HH:mm');
    return '${fmt.format(start)} - ${fmt.format(end)}';
  }

  Future<void> _showHealthRecordSelectionSheet(
    BuildContext context,
    double scale,
  ) async {
    // 1. Detect target type from activity name
    final activityNameLower = activity.activity.toLowerCase();
    final isForMom =
        activityNameLower.contains('mẹ') ||
        activityNameLower.contains('sản phụ');
    final isForBaby =
        activityNameLower.contains('bé') || activityNameLower.contains('trẻ');

    // 2. Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      // 3. Fetch family members
      final ds = EmployeeCustomerProfileRemoteDataSource();
      final allMembers = await ds.getFamilyProfilesByAccountId(customerId);

      // Filter out Head of Family - only Mom and Baby need health records
      final members = allMembers.where((m) {
        final type = m.memberTypeName?.toLowerCase() ?? '';
        return !type.contains('head of family') && !type.contains('chủ hộ');
      }).toList();

      if (context.mounted) Navigator.pop(context); // Hide loading

      if (members.isEmpty) {
        if (context.mounted) {
          AppToast.showInfo(
            context,
            message: 'Khách hàng này chưa có hồ sơ gia đình.',
          );
        }
        return;
      }

      // 4. Try automatic selection
      FamilyProfileEntity? autoSelected;
      if (isForMom && !isForBaby) {
        final moms = members
            .where(
              (m) => m.memberTypeName?.toLowerCase().contains('mom') ?? false,
            )
            .toList();
        if (moms.length == 1) autoSelected = moms.first;
      } else if (isForBaby && !isForMom) {
        final babies = members
            .where(
              (m) => m.memberTypeName?.toLowerCase().contains('baby') ?? false,
            )
            .toList();
        if (babies.length == 1) autoSelected = babies.first;
      }

      if (autoSelected != null) {
        if (context.mounted) {
          StaffHealthCareFlowScreen.showAsBottomSheet(
            context,
            familyProfileId: autoSelected.id,
            familyMemberName: autoSelected.fullName,
            memberType: autoSelected.memberTypeName,
            activityName: activity.activity,
          );
        }
        return;
      }

      // 5. If ambiguous or no match, show member selection sheet
      if (context.mounted) {
        final selectedMember = await showModalBottomSheet<FamilyProfileEntity>(
          context: context,
          backgroundColor: Colors.white,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(32 * scale),
            ),
          ),
          builder: (context) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                24 * scale,
                12 * scale,
                24 * scale,
                24 * scale,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40 * scale,
                      height: 4 * scale,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: 24 * scale),
                    Text(
                      'Chọn người cần ghi nhận',
                      style: AppTextStyles.arimo(
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 20 * scale),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: members.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12 * scale),
                      itemBuilder: (context, index) {
                        final m = members[index];
                        final isBaby =
                            m.memberTypeName?.toLowerCase().contains('baby') ??
                            false;
                        return InkWell(
                          onTap: () => Navigator.pop(context, m),
                          borderRadius: BorderRadius.circular(16 * scale),
                          child: Container(
                            padding: EdgeInsets.all(12 * scale),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.borderLight.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(16 * scale),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      (isBaby ? Colors.pink : AppColors.primary)
                                          .withValues(alpha: 0.1),
                                  child: Icon(
                                    isBaby
                                        ? Icons.child_care_rounded
                                        : Icons.person,
                                    color: isBaby
                                        ? Colors.pink
                                        : AppColors.primary,
                                  ),
                                ),
                                SizedBox(width: 16 * scale),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.fullName,
                                        style: AppTextStyles.arimo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16 * scale,
                                        ),
                                      ),
                                      Text(
                                        m.memberTypeName ?? '',
                                        style: AppTextStyles.arimo(
                                          fontSize: 12 * scale,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 30 * scale),
                  ],
                ),
              ),
            );
          },
        );

        if (selectedMember != null && context.mounted) {
          // 4. Show Health Record form in bottom sheet
          StaffHealthCareFlowScreen.showAsBottomSheet(
            context,
            familyProfileId: selectedMember.id,
            familyMemberName: selectedMember.fullName,
            memberType: selectedMember.memberTypeName,
            activityName: activity.activity,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Hide loading
        AppToast.showError(
          context,
          message: 'Lỗi tải danh sách thành viên: $e',
        );
      }
    }
  }
}

class EmployeeActivitiesTimelineScreen extends StatefulWidget {
  final AssignedCustomer customer;
  final VoidCallback onStatusUpdated;

  const EmployeeActivitiesTimelineScreen({
    super.key,
    required this.customer,
    required this.onStatusUpdated,
  });

  @override
  State<EmployeeActivitiesTimelineScreen> createState() =>
      _EmployeeActivitiesTimelineScreenState();
}

class _EmployeeActivitiesTimelineScreenState
    extends State<EmployeeActivitiesTimelineScreen> {
  late List<AssignedActivity> _activities;
  _ActivityFilter _filter = _ActivityFilter.scheduled;

  @override
  void initState() {
    super.initState();
    _activities = List<AssignedActivity>.from(widget.customer.activities);
  }

  List<AssignedActivity> _filterActivities(
    List<AssignedActivity> source,
    _ActivityFilter filter,
  ) {
    if (filter == _ActivityFilter.all) return source;
    return source.where((activity) {
      final normalized = activity.status.toLowerCase();
      switch (filter) {
        case _ActivityFilter.scheduled:
          return normalized == 'scheduled';
        case _ActivityFilter.missed:
          return normalized == 'missed';
        case _ActivityFilter.staffDone:
          return normalized == 'staffdone' || normalized == 'staff_done';
        case _ActivityFilter.done:
          return normalized == 'done' || normalized == 'completed';
        default:
          return true;
      }
    }).toList();
  }

  List<_CalendarDay> _buildCalendarDays(List<AssignedActivity> activities) {
    if (activities.isEmpty) return const [];
    final sorted = [...activities]
      ..sort((a, b) {
        final aTime = a.startAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.startAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aTime.compareTo(bTime);
      });
    final daysMap = <DateTime, List<AssignedActivity>>{};
    for (final act in sorted) {
      final start = act.startAt;
      if (start == null) continue;
      final date = DateTime(start.year, start.month, start.day);
      daysMap.putIfAbsent(date, () => []).add(act);
    }
    final result = daysMap.entries
        .map((e) => _CalendarDay(date: e.key, activities: e.value))
        .toList();
    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final filteredActivities = _filterActivities(_activities, _filter);
    final calendarDays = _buildCalendarDays(filteredActivities);

    return EmployeeScaffold(
      appBar: AppAppBar(
        title: widget.customer.displayName,
        centerTitle: true,
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EmployeeCustomerFamilyProfilesScreen(
                    customerId: widget.customer.customerId,
                    customerName: widget.customer.displayName,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.account_circle_outlined,
              color: AppColors.primary,
            ),
            tooltip: 'Hồ sơ gia đình',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timeline hoạt động trong tháng • ${widget.customer.assignmentsCount} lịch',
                  style: AppTextStyles.arimo(
                    fontSize: 13 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 16 * scale),
                _FilterTabs(
                  current: _filter,
                  onChanged: (next) {
                    setState(() {
                      _filter = next;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16 * scale,
                0,
                16 * scale,
                16 * scale,
              ),
              child: _ActivitiesVerticalList(
                customerId: widget.customer.customerId,
                days: calendarDays,
                onCheckPressed: (activity) => _handleCheckIn(activity),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCheckIn(AssignedActivity activity) async {
    final now = DateTime.now();
    final status = activity.status.toLowerCase();
    final activityDate = activity.startAt != null
        ? DateTime(
            activity.startAt!.year,
            activity.startAt!.month,
            activity.startAt!.day,
          )
        : null;
    final today = DateTime(now.year, now.month, now.day);

    if (status != 'scheduled') {
      _showStatusNotice(
        context,
        'Trạng thái không hợp lệ',
        'Bạn chỉ có thể cập nhật những hoạt động đang ở trạng thái "Sắp tới".',
        isError: true,
      );
      return;
    }

    if (activityDate == null || !activityDate.isAtSameMomentAs(today)) {
      _showStatusNotice(
        context,
        'Thời gian không phù hợp',
        'Bạn chỉ được phép cập nhật hoạt động diễn ra trong ngày hôm nay.',
        isError: true,
      );
      return;
    }

    if (activity.startAt != null && now.isBefore(activity.startAt!)) {
      _showStatusNotice(
        context,
        'Chưa tới giờ',
        'Hoạt động này chưa đến giờ thực hiện. Vui lòng quay lại sau.',
        isError: true,
      );
      return;
    }

    final checkData = await _askForCheckInDetails(context, activity.activity);
    if (!mounted || checkData == null) return;

    final success = await _checkSchedule(
      activity.staffScheduleId,
      checkData.note,
      checkData.imagePaths,
    );
    if (!success || !mounted) return;

    setState(() {
      final index = _activities.indexWhere(
        (item) => item.staffScheduleId == activity.staffScheduleId,
      );
      if (index != -1) {
        _activities[index] = _activities[index].copyWith(
          status: 'StaffDone',
          note: checkData.note,
          images: checkData.imagePaths,
          checkedAt: DateTime.now(),
        );
      }
      _filter = _ActivityFilter.staffDone;
    });

    widget.onStatusUpdated();
  }

  Future<_CheckInDetails?> _askForCheckInDetails(
    BuildContext context,
    String activityName,
  ) async {
    final scale = AppResponsive.scaleFactor(context);
    final controller = TextEditingController();
    final picker = ImagePicker();
    List<String> imagePaths = [];

    final result = await showDialog<_CheckInDetails>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              surfaceTintColor: Colors.transparent,
              scrollable: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16 * scale),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8 * scale),
                  const Text('Xác nhận hoàn tất'),
                ],
              ),
              content: SizedBox(
                width: 300 * scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12 * scale),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8 * scale),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hoạt động',
                            style: AppTextStyles.arimo(
                              fontSize: 11 * scale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4 * scale),
                          Text(
                            activityName,
                            style: AppTextStyles.arimo(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16 * scale),
                    Text(
                      'Vui lòng chụp ảnh hoặc chọn ảnh minh chứng kết quả trước khi nhấn xác nhận.',
                      style: AppTextStyles.arimo(
                        fontSize: 13 * scale,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 16 * scale),
                    TextField(
                      controller: controller,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Ghi chú',
                        hintText: 'Nhập ghi chú (tuỳ chọn)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * scale),
                        ),
                        contentPadding: EdgeInsets.all(12 * scale),
                      ),
                    ),
                    SizedBox(height: 20 * scale),
                    Text(
                      'Hình ảnh minh chứng (${imagePaths.length})',
                      style: AppTextStyles.arimo(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 10 * scale),
                    if (imagePaths.isNotEmpty) ...[
                      SizedBox(
                        height: 80 * scale,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: imagePaths.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(width: 8 * scale),
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    8 * scale,
                                  ),
                                  child: Image.file(
                                    File(imagePaths[index]),
                                    width: 80 * scale,
                                    height: 80 * scale,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        imagePaths.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 12 * scale),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final image = await picker.pickImage(
                            source: ImageSource.camera,
                            imageQuality: 70,
                            maxWidth: 1200,
                          );
                          if (image != null) {
                            setState(() {
                              imagePaths.add(image.path);
                            });
                          }
                        },
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Chụp ảnh minh chứng'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12 * scale),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10 * scale),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Huỷ'),
                ),
                ElevatedButton(
                  onPressed: imagePaths.isEmpty
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop(
                            _CheckInDetails(
                              note: controller.text.trim(),
                              imagePaths: imagePaths,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.borderLight,
                  ),
                  child: const Text('Xác nhận'),
                ),
              ],
            );
          },
        );
      },
    );

    return result;
  }

  void _showStatusNotice(
    BuildContext context,
    String title,
    String message, {
    bool isError = false,
  }) {
    final scale = AppResponsive.scaleFactor(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16 * scale),
        ),
        title: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.info_outline_rounded,
              color: isError ? AppColors.red : AppColors.primary,
            ),
            SizedBox(width: 8 * scale),
            Text(
              title,
              style: AppTextStyles.arimo(
                fontWeight: FontWeight.w800,
                fontSize: 18 * scale,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTextStyles.arimo(
            fontSize: 14 * scale,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  Future<bool> _checkSchedule(
    int staffScheduleId,
    String? note,
    List<String> imagePaths,
  ) async {
    try {
      final formDataMap = {
        'StaffScheduleId': staffScheduleId,
        'Note': note ?? '',
      };
      final formData = FormData.fromMap(formDataMap);
      if (imagePaths.isNotEmpty) {
        for (final path in imagePaths) {
          final file = await MultipartFile.fromFile(
            path,
            filename: path.split('/').last,
          );
          formData.files.add(MapEntry('Images', file));
        }
      }
      await ApiClient.dio.patch(
        ApiEndpoints.checkStaffSchedule,
        data: formData,
      );
      if (!mounted) return false;
      AppToast.showSuccess(context, message: 'Cập nhật lịch thành công.');
      return true;
    } catch (e) {
      if (!mounted) return false;
      String errorMessage = e.toString();
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('error')) {
          errorMessage = data['error'].toString();
        }
      }
      _showStatusNotice(
        context,
        'Cập nhật thất bại',
        errorMessage,
        isError: true,
      );
      return false;
    }
  }
}
