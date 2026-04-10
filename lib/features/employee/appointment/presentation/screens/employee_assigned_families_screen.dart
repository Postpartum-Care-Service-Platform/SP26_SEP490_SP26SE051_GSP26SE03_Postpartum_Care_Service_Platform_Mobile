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

class EmployeeAssignedFamiliesScreen extends StatefulWidget {
  const EmployeeAssignedFamiliesScreen({super.key});

  @override
  State<EmployeeAssignedFamiliesScreen> createState() =>
      _EmployeeAssignedFamiliesScreenState();
}

class _EmployeeAssignedFamiliesScreenState
    extends State<EmployeeAssignedFamiliesScreen> {
  late DateTime _focusMonth;
  late Future<List<_AssignedCustomer>> _futureCustomers;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusMonth = DateTime(now.year, now.month, 1);
    _futureCustomers = _loadAssignedCustomers();
  }

  Future<List<_AssignedCustomer>> _loadAssignedCustomers() async {
    final from = DateTime(_focusMonth.year, _focusMonth.month, 1);
    final to = DateTime(_focusMonth.year, _focusMonth.month + 1, 0);

    final response = await ApiClient.dio.get(
      ApiEndpoints.myStaffSchedules,
      queryParameters: {
        'from': _dateOnly(from),
        'to': _dateOnly(to),
      },
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
      
      // Temporary check for booking status on any item in the group
      byCustomer.putIfAbsent(customerId, () => []).add(row);
    }

    final result = <_AssignedCustomer>[];
    for (final entry in byCustomer.entries) {
      final customerId = entry.key;
      final items = entry.value;
      
      // Check booking status from the first item (all items for a family in a month usually belong to the same booking)
      final firstRow = items.first;
      final firstFamily = firstRow['familyScheduleResponse'] as Map<String, dynamic>?;
      final firstBooking = firstRow['booking'] as Map<String, dynamic>?;
      
      final bookingStatus = (
        firstRow['bookingStatus'] ?? 
        firstFamily?['bookingStatus'] ?? 
        firstBooking?['status'] ?? 
        ''
      ).toString().toLowerCase();

      // Filter out completed bookings
      if (bookingStatus == 'completed' || 
          bookingStatus == 'complete' || 
          bookingStatus == 'hoàn thành') {
        continue;
      }
      final first = items.first;
      final family = first['familyScheduleResponse'] as Map<String, dynamic>?;

      final displayName =
          (family?['customerName'] ?? family?['name'] ?? customerId)
              .toString();
      final avatarUrl = (family?['customerAvatar'] ?? '').toString();
      final roomName = (first['roomName'] ?? '').toString();

      final activities = items
          .map((row) {
            final familyMap =
                row['familyScheduleResponse'] as Map<String, dynamic>?;
            return _AssignedActivity(
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
            );
          })
          .toList()
        ..sort((a, b) {
          final aTime = a.startAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.startAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return aTime.compareTo(bTime);
        });

      result.add(
        _AssignedCustomer(
          customerId: customerId,
          displayName: displayName,
          avatarUrl: avatarUrl,
          roomName: roomName,
          assignmentsCount: items.length,
          activities: activities,
        ),
      );
    }

    result.sort((a, b) => a.displayName.compareTo(b.displayName));
    return result;
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
    return DateTime(parsedDate.year, parsedDate.month, parsedDate.day, hour, minute);
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusMonth = DateTime(_focusMonth.year, _focusMonth.month + delta, 1);
      _futureCustomers = _loadAssignedCustomers();
    });
  }

  void _goToCurrentMonth() {
    final now = DateTime.now();
    setState(() {
      _focusMonth = DateTime(now.year, now.month, 1);
      _futureCustomers = _loadAssignedCustomers();
    });
  }

  Future<void> _showActivitiesTimelineBottomSheet(
    _AssignedCustomer customer,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final scale = AppResponsive.scaleFactor(sheetContext);
        final initialActivities = List<_AssignedActivity>.from(customer.activities);
        var filter = _ActivityFilter.all;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filteredActivities = _filterActivities(initialActivities, filter);
            final calendarDays = _buildCalendarDays(filteredActivities);

            return FractionallySizedBox(
              heightFactor: 0.9,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(22 * scale),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10 * scale),
                    Container(
                      width: 46 * scale,
                      height: 5 * scale,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        16 * scale,
                        12 * scale,
                        12 * scale,
                        8 * scale,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.arimo(
                                    fontSize: 16 * scale,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4 * scale),
                                Text(
                                  'Timeline hoạt động trong tháng • ${customer.assignmentsCount} lịch',
                                  style: AppTextStyles.arimo(
                                    fontSize: 12 * scale,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                      child: _FilterTabs(
                        current: filter,
                        onChanged: (next) {
                          setSheetState(() {
                            filter = next;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 12 * scale),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          16 * scale,
                          12 * scale,
                          16 * scale,
                          16 * scale,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(sheetContext).pop();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => EmployeeCustomerFamilyProfilesScreen(
                                        customerId: customer.customerId,
                                        customerName: customer.displayName,
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.open_in_new_rounded, size: 18 * scale),
                                label: Text(
                                  'Mở hồ sơ gia đình',
                                  style: AppTextStyles.arimo(
                                    fontSize: 14 * scale,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12 * scale),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10 * scale),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16 * scale),
                            _ActivitiesVerticalList(
                              days: calendarDays,
                              onCheckPressed: (activity) async {
                                final now = DateTime.now();
                                final status = activity.status.toLowerCase();

                                // Check for missed tasks: Status is 'missed' or time has already ended
                                final isMissedByTime = activity.endAt != null && now.isAfter(activity.endAt!);
                                if (status == 'missed' || isMissedByTime) {
                                  _showStatusNotice(
                                    sheetContext,
                                    'Lịch đã lỡ',
                                    'Bạn không thể cập nhật hoàn tất cho hoạt động đã quá thời gian thực hiện.',
                                    isError: true,
                                  );
                                  return;
                                }

                                // Check for future tasks: e.g., if now is before startAt - 15 minutes
                                if (activity.startAt != null &&
                                    now.isBefore(activity.startAt!.subtract(const Duration(minutes: 15)))) {
                                  final timeStr = DateFormat('HH:mm').format(activity.startAt!);
                                  _showStatusNotice(
                                    sheetContext,
                                    'Chưa đến giờ',
                                    'Hoạt động này dự kiến bắt đầu vào lúc $timeStr. Vui lòng quay lại khi đến giờ thực hiện.',
                                  );
                                  return;
                                }

                                final checkData = await _askForCheckInDetails(sheetContext);
                                if (!sheetContext.mounted || checkData == null) {
                                  return;
                                }

                                final success = await _checkSchedule(
                                  activity.staffScheduleId,
                                  checkData.note,
                                  checkData.imagePaths,
                                );
                                if (!success || !sheetContext.mounted || !mounted) {
                                  return;
                                }

                                setSheetState(() {
                                  final index = initialActivities.indexWhere(
                                    (item) => item.staffScheduleId == activity.staffScheduleId,
                                  );
                                  if (index != -1) {
                                    initialActivities[index] = initialActivities[index].copyWith(
                                      status: 'StaffDone',
                                      note: checkData.note,
                                    );
                                  }
                                });

                                setState(() {
                                  _futureCustomers = _loadAssignedCustomers();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<_CheckInDetails?> _askForCheckInDetails(BuildContext context) async {
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
                  const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary),
                  SizedBox(width: 8 * scale),
                  const Text('Xác nhận hoàn tất'),
                ],
              ),
              content: SizedBox(
                width: 300 * scale, // Help define intrinsic width
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          separatorBuilder: (_, __) => SizedBox(width: 8 * scale),
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8 * scale),
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
                    Row(
                      children: [
                        Expanded(
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
                            label: const Text('Máy ảnh'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 10 * scale),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10 * scale),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8 * scale),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final images = await picker.pickMultiImage(
                                imageQuality: 70,
                                maxWidth: 1200,
                              );
                              if (images.isNotEmpty) {
                                setState(() {
                                  imagePaths.addAll(images.map((e) => e.path));
                                });
                              }
                            },
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Thư viện'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 10 * scale),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10 * scale),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                          Navigator.of(dialogContext).pop(_CheckInDetails(
                            note: controller.text.trim(),
                            imagePaths: imagePaths,
                          ));
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * scale)),
        title: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.info_outline_rounded,
              color: isError ? AppColors.red : AppColors.primary,
            ),
            SizedBox(width: 8 * scale),
            Text(title, style: AppTextStyles.arimo(fontWeight: FontWeight.w800, fontSize: 18 * scale)),
          ],
        ),
        content: Text(
          message,
          style: AppTextStyles.arimo(fontSize: 14 * scale, color: AppColors.textSecondary),
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

      if (!mounted) {
        return false;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật lịch thành công.')),
      );
      return true;
    } catch (e) {
      if (!mounted) {
        return false;
      }

      String errorMessage = e.toString();
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('error')) {
          errorMessage = data['error'].toString();
        } else if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'].toString();
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

  List<_AssignedActivity> _filterActivities(
    List<_AssignedActivity> source,
    _ActivityFilter filter,
  ) {
    if (filter == _ActivityFilter.all) {
      return source;
    }

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
        case _ActivityFilter.all:
          return true;
      }
    }).toList();
  }

  List<_CalendarDay> _buildCalendarDays(List<_AssignedActivity> activities) {
    if (activities.isEmpty) {
      return const [];
    }

    final sorted = [...activities]
      ..sort((a, b) {
        final aTime = a.startAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.startAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aTime.compareTo(bTime);
      });

    final daysMap = <DateTime, List<_AssignedActivity>>{};
    for (final act in sorted) {
      final start = act.startAt;
      if (start == null) continue;
      final date = DateTime(start.year, start.month, start.day);
      daysMap.putIfAbsent(date, () => []).add(act);
    }

    final result = daysMap.entries.map((e) => _CalendarDay(date: e.key, activities: e.value)).toList();
    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    return EmployeeScaffold(
      appBar: const AppAppBar(
        title: 'Gia đình được phân công',
        centerTitle: true,
      ),
      body: FutureBuilder<List<_AssignedCustomer>>(
        future: _futureCustomers,
        builder: (context, snapshot) {
          final customers = snapshot.data ?? const <_AssignedCustomer>[];

          Widget content;
          if (snapshot.connectionState == ConnectionState.waiting) {
            content = const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (snapshot.hasError) {
            content = Center(
              child: Padding(
                padding: EdgeInsets.all(24 * scale),
                child: Text(
                  'Tải dữ liệu thất bại: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          } else if (customers.isEmpty) {
            content = Center(
              child: Padding(
                padding: EdgeInsets.all(24 * scale),
                child: Text(
                  'Bạn chưa được phân công hộ gia đình nào.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          } else {
            content = RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _futureCustomers = _loadAssignedCustomers();
                });
                await _futureCustomers;
              },
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * scale,
                  vertical: 12 * scale,
                ),
                itemCount: customers.length,
                separatorBuilder: (_, __) => SizedBox(height: 10 * scale),
                itemBuilder: (context, index) {
                  final c = customers[index];
                  return _CustomerCard(
                    customer: c,
                    onTap: () => _showActivitiesTimelineBottomSheet(c),
                  );
                },
              ),
            );
          }

          return Column(
            children: [
              _MonthToolbar(
                focusMonth: _focusMonth,
                totalFamilies: customers.length,
                onPreviousMonth: () => _changeMonth(-1),
                onNextMonth: () => _changeMonth(1),
                onCurrentMonth: _goToCurrentMonth,
              ),
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }
}

enum _ActivityFilter { all, scheduled, missed, staffDone, done }

class _FilterTabs extends StatelessWidget {
  final _ActivityFilter current;
  final ValueChanged<_ActivityFilter> onChanged;

  const _FilterTabs({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Wrap(
      spacing: 8 * scale,
      runSpacing: 8 * scale,
      children: [
        _FilterChip(
          label: 'Tất cả',
          selected: current == _ActivityFilter.all,
          onTap: () => onChanged(_ActivityFilter.all),
        ),
        _FilterChip(
          label: 'Có lịch',
          selected: current == _ActivityFilter.scheduled,
          onTap: () => onChanged(_ActivityFilter.scheduled),
        ),
        _FilterChip(
          label: 'Lỡ lịch',
          selected: current == _ActivityFilter.missed,
          onTap: () => onChanged(_ActivityFilter.missed),
        ),
        _FilterChip(
          label: 'Đã làm',
          selected: current == _ActivityFilter.staffDone,
          onTap: () => onChanged(_ActivityFilter.staffDone),
        ),
        _FilterChip(
          label: 'Khách duyệt',
          selected: current == _ActivityFilter.done,
          onTap: () => onChanged(_ActivityFilter.done),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final bgColor = selected
        ? AppColors.primary.withValues(alpha: 0.14)
        : AppColors.borderLight.withValues(alpha: 0.35);
    final textColor = selected ? AppColors.primary : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12 * scale,
          vertical: 6 * scale,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 12 * scale,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _MonthToolbar extends StatelessWidget {
  final DateTime focusMonth;
  final int totalFamilies;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onCurrentMonth;

  const _MonthToolbar({
    required this.focusMonth,
    required this.totalFamilies,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onCurrentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      margin: EdgeInsets.fromLTRB(16 * scale, 12 * scale, 16 * scale, 0),
      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 10 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: onCurrentMonth,
            child: const Text('Tháng này'),
          ),
          IconButton(
            onPressed: onPreviousMonth,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: onNextMonth,
            icon: const Icon(Icons.chevron_right),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('MM/yyyy').format(focusMonth),
                style: AppTextStyles.arimo(
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4 * scale),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * scale,
                  vertical: 4 * scale,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Tổng gia đình: $totalFamilies',
                  style: AppTextStyles.arimo(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AssignedCustomer {
  final String customerId;
  final String displayName;
  final String avatarUrl;
  final String roomName;
  final int assignmentsCount;
  final List<_AssignedActivity> activities;

  const _AssignedCustomer({
    required this.customerId,
    required this.displayName,
    required this.avatarUrl,
    required this.roomName,
    required this.assignmentsCount,
    required this.activities,
  });
}

class _AssignedActivity {
  final int staffScheduleId;
  final DateTime? startAt;
  final DateTime? endAt;
  final String activity;
  final String status;
  final String note;

  const _AssignedActivity({
    required this.staffScheduleId,
    required this.startAt,
    required this.endAt,
    required this.activity,
    required this.status,
    required this.note,
  });

  _AssignedActivity copyWith({
    String? status,
    String? note,
  }) {
    return _AssignedActivity(
      staffScheduleId: staffScheduleId,
      startAt: startAt,
      endAt: endAt,
      activity: activity,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }
}

class _CalendarDay {
  final DateTime date;
  final List<_AssignedActivity> activities;

  const _CalendarDay({required this.date, required this.activities});
}

class _ActivitiesVerticalList extends StatelessWidget {
  final List<_CalendarDay> days;
  final ValueChanged<_AssignedActivity> onCheckPressed;

  const _ActivitiesVerticalList({required this.days, required this.onCheckPressed});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    if (days.isEmpty) {
      return Container(
        padding: EdgeInsets.all(24 * scale),
        alignment: Alignment.center,
        child: Text(
          'Không có hoạt động nào',
          style: AppTextStyles.arimo(color: AppColors.textSecondary, fontSize: 14 * scale),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: days.map((day) {
        final weekdayFormat = DateFormat('EEEE', 'en_US').format(day.date);
        String vnWeekday = '';
        switch(weekdayFormat) {
          case 'Monday': vnWeekday = 'Thứ Hai'; break;
          case 'Tuesday': vnWeekday = 'Thứ Ba'; break;
          case 'Wednesday': vnWeekday = 'Thứ Tư'; break;
          case 'Thursday': vnWeekday = 'Thứ Năm'; break;
          case 'Friday': vnWeekday = 'Thứ Sáu'; break;
          case 'Saturday': vnWeekday = 'Thứ Bảy'; break;
          case 'Sunday': vnWeekday = 'Chủ Nhật'; break;
        }

        return Padding(
          padding: EdgeInsets.only(bottom: 12 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 12 * scale, left: 4 * scale, top: 4 * scale),
                child: Row(
                  children: [
                    Text(
                      vnWeekday,
                      style: AppTextStyles.arimo(
                        fontWeight: FontWeight.w800,
                        fontSize: 15 * scale,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 8 * scale),
                    Text(
                      DateFormat('dd/MM/yyyy').format(day.date),
                      style: AppTextStyles.arimo(
                        fontWeight: FontWeight.w600,
                        fontSize: 13 * scale,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ...day.activities.map((activity) => _TimelineActivityCard(
                activity: activity,
                onCheckPressed: onCheckPressed,
              )),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _TimelineActivityCard extends StatelessWidget {
  final _AssignedActivity activity;
  final ValueChanged<_AssignedActivity> onCheckPressed;

  const _TimelineActivityCard({
    required this.activity,
    required this.onCheckPressed,
  });

  Color _statusColor() {
    final normalized = activity.status.toLowerCase();
    if (normalized == 'done' || normalized == 'completed') {
      return const Color(0xFF16A34A);
    }
    if (normalized == 'staffdone' || normalized == 'staff_done') {
      return const Color(0xFF0EA5E9);
    }
    if (normalized == 'missed') {
      return const Color(0xFFDC2626);
    }
    if (normalized == 'cancelled') {
      return const Color(0xFF9CA3AF);
    }
    return const Color(0xFF2563EB);
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final statusColor = _statusColor();
    final startLabel = activity.startAt != null
        ? DateFormat('HH:mm').format(activity.startAt!)
        : '--:--';
    final endLabel = activity.endAt != null
        ? DateFormat('HH:mm').format(activity.endAt!)
        : '--:--';
    
    final canCheck = !(activity.status.toLowerCase() == 'done' ||
        activity.status.toLowerCase() == 'completed' ||
        activity.status.toLowerCase() == 'staffdone' ||
        activity.status.toLowerCase() == 'staff_done');

    return Padding(
      padding: EdgeInsets.only(bottom: 10 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48 * scale,
            child: Padding(
              padding: EdgeInsets.only(top: 2 * scale),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    startLabel,
                    style: AppTextStyles.arimo(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2 * scale),
                  Text(
                    endLabel,
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(14 * scale, 12 * scale, 12 * scale, 10 * scale),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10 * scale),
                  bottomRight: Radius.circular(10 * scale),
                  bottomLeft: Radius.circular(4 * scale),
                  topLeft: Radius.circular(4 * scale),
                ),
                border: Border(
                  left: BorderSide(color: statusColor, width: 4 * scale),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          activity.activity,
                          style: AppTextStyles.arimo(
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 3 * scale),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4 * scale),
                        ),
                        child: Text(
                          _getStatusDisplayText(activity.status),
                          style: AppTextStyles.arimo(
                            fontSize: 10 * scale,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (activity.note.isNotEmpty) ...[
                    SizedBox(height: 6 * scale),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.notes_rounded, size: 14 * scale, color: AppColors.textSecondary),
                        SizedBox(width: 4 * scale),
                        Expanded(
                          child: Text(
                            'Ghi chú: ${activity.note}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.arimo(
                              fontSize: 12 * scale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (canCheck) ...[
                    SizedBox(height: 10 * scale),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => onCheckPressed(activity),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 6 * scale),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6 * scale),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_outline_rounded, size: 14 * scale, color: AppColors.white),
                              SizedBox(width: 4 * scale),
                              Text(
                                'Hoàn tất',
                                style: AppTextStyles.arimo(
                                  fontSize: 12 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusDisplayText(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'scheduled') return 'Có lịch';
    if (normalized == 'missed') return 'Lỡ lịch';
    if (normalized == 'staffdone' || normalized == 'staff_done') return 'Đã làm';
    if (normalized == 'done' || normalized == 'completed') return 'Khách duyệt';
    return status;
  }
}

class _CustomerCard extends StatelessWidget {
  final _AssignedCustomer customer;
  final VoidCallback onTap;

  const _CustomerCard({required this.customer, required this.onTap});

  String _buildActivitiesPreview(List<_AssignedActivity> activities) {
    final previews = activities.take(2).map((activity) {
      final time = activity.startAt != null
          ? DateFormat('dd/MM HH:mm').format(activity.startAt!)
          : '--:--';
      return '$time • ${activity.activity}';
    }).toList();

    if (activities.length > 2) {
      previews.add('+${activities.length - 2} hoạt động nữa');
    }

    return previews.join('  |  ');
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16 * scale),
        child: Padding(
          padding: EdgeInsets.all(14 * scale),
          child: Row(
            children: [
              Container(
                width: 44 * scale,
                height: 44 * scale,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14 * scale),
                ),
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                child: customer.avatarUrl.isNotEmpty
                    ? Image.network(
                        customer.avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.family_restroom_rounded,
                          color: AppColors.primary,
                          size: 22 * scale,
                        ),
                      )
                    : Icon(
                        Icons.family_restroom_rounded,
                        color: AppColors.primary,
                        size: 22 * scale,
                      ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.arimo(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      customer.roomName.isNotEmpty
                          ? customer.roomName
                          : 'Chưa có thông tin phòng',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.arimo(
                        fontSize: 12 * scale,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 6 * scale),
                    Text(
                      'Lịch được phân công: ${customer.assignmentsCount}',
                      style: AppTextStyles.arimo(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    if (customer.activities.isNotEmpty) ...[
                      SizedBox(height: 6 * scale),
                      Text(
                        _buildActivitiesPreview(customer.activities),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.arimo(
                          fontSize: 11 * scale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 26 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _CheckInDetails {
  final String note;
  final List<String> imagePaths;

  _CheckInDetails({required this.note, required this.imagePaths});
}
