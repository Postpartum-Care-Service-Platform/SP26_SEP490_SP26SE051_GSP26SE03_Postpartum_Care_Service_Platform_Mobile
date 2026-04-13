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

class EmployeeAssignedFamiliesScreen extends StatefulWidget {
  const EmployeeAssignedFamiliesScreen({super.key});

  @override
  State<EmployeeAssignedFamiliesScreen> createState() =>
      _EmployeeAssignedFamiliesScreenState();
}

class _EmployeeAssignedFamiliesScreenState
    extends State<EmployeeAssignedFamiliesScreen> {
  late DateTime _fromDate;
  late DateTime _toDate;
  late Future<List<_AssignedCustomer>> _futureCustomers;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, 1);
    _toDate = DateTime(now.year, now.month + 1, 0);
    _futureCustomers = _loadAssignedCustomers();
  }

  Future<List<_AssignedCustomer>> _loadAssignedCustomers() async {
    final fromStr = _dateOnly(_fromDate);
    final toStr = _dateOnly(_toDate);

    final response = await ApiClient.dio.get(
      ApiEndpoints.myStaffSchedules,
      queryParameters: {
        'from': fromStr,
        'to': toStr,
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
      
      byCustomer.putIfAbsent(customerId, () => []).add(row);
    }

    final result = <_AssignedCustomer>[];
    for (final entry in byCustomer.entries) {
      final customerId = entry.key;
      final items = entry.value;
      
      final firstRow = items.first;
      final firstFamily = firstRow['familyScheduleResponse'] as Map<String, dynamic>?;
      final firstBooking = firstRow['booking'] as Map<String, dynamic>?;
      
      final bookingStatus = (
        firstRow['bookingStatus'] ?? 
        firstFamily?['bookingStatus'] ?? 
        firstBooking?['status'] ?? 
        ''
      ).toString().toLowerCase();


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

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final hasTodayActivity = activities.any((a) =>
          a.startAt != null &&
          DateTime(a.startAt!.year, a.startAt!.month, a.startAt!.day)
              .isAtSameMomentAs(today));

      final isCurrentlyActive = activities.any((a) =>
          a.startAt != null &&
          a.endAt != null &&
          now.isAfter(a.startAt!) &&
          now.isBefore(a.endAt!));

      result.add(
        _AssignedCustomer(
          customerId: customerId,
          displayName: displayName,
          avatarUrl: avatarUrl,
          roomName: roomName,
          assignmentsCount: items.length,
          activities: activities,
          hasTodayActivity: hasTodayActivity,
          isCurrentlyActive: isCurrentlyActive,
        ),
      );
    }

    result.sort((a, b) {
      if (a.isCurrentlyActive && !b.isCurrentlyActive) return -1;
      if (!a.isCurrentlyActive && b.isCurrentlyActive) return 1;
      if (a.hasTodayActivity && !b.hasTodayActivity) return -1;
      if (!a.hasTodayActivity && b.hasTodayActivity) return 1;
      return a.displayName.compareTo(b.displayName);
    });
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
                                    fontSize: 18 * scale,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4 * scale),
                                Text(
                                  'Timeline hoạt động trong tháng • ${customer.assignmentsCount} lịch',
                                  style: AppTextStyles.arimo(
                                    fontSize: 13 * scale,
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
                                icon: Icon(Icons.open_in_new_rounded, size: 20 * scale),
                                label: Text(
                                  'Mở hồ sơ gia đình',
                                  style: AppTextStyles.arimo(
                                    fontSize: 15 * scale,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14 * scale),
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

                                bool isMissedByTime = false;
                                if (activity.endAt != null) {
                                  final endDay = DateTime(activity.endAt!.year, activity.endAt!.month, activity.endAt!.day);
                                  final today = DateTime(now.year, now.month, now.day);
                                  isMissedByTime = today.isAfter(endDay);
                                }

                                if (status == 'missed' || isMissedByTime) {
                                  _showStatusNotice(
                                    sheetContext,
                                    'Lịch đã lỡ',
                                    'Bạn không thể cập nhật hoàn tất vì hoạt động này đã qua ngày thực hiện.',
                                    isError: true,
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
                width: 300 * scale,
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

      AppToast.showSuccess(context, message: 'Cập nhật lịch thành công.');
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

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24 * scale),
                child: Text('Tải dữ liệu thất bại: ${snapshot.error}', textAlign: TextAlign.center),
              ),
            );
          } else if (customers.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24 * scale),
                child: Text('Bạn chưa được phân công hộ gia đình nào.', textAlign: TextAlign.center),
              ),
            );
          } else {
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
                    padding: EdgeInsets.fromLTRB(20 * scale, 16 * scale, 20 * scale, 0),
                    child: _buildWelcomeHeader(scale),
                  ),
                  Expanded(
                    child: customers.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: 100 * scale),
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24 * scale),
                                  child: const Text(
                                    'Bạn chưa có lịch phân công nào trong khoảng thời gian này.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : _buildMainContent(customers, scale),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildMainContent(List<_AssignedCustomer> customers, double scale) {
    if (customers.length == 1) {
      final customer = customers.first;
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 20 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FocusFamilyCard(
              customer: customer,
              onTap: () => _showActivitiesTimelineBottomSheet(customer),
            ),
            SizedBox(height: 24 * scale),
            _buildQuickStats(customer, scale),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
      itemCount: customers.length,
      separatorBuilder: (_, __) => SizedBox(height: 16 * scale),
      itemBuilder: (context, index) {
        final c = customers[index];
        return _FamilyCard(
          customer: c,
          onTap: () => _showActivitiesTimelineBottomSheet(c),
        );
      },
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
          Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20 * scale),
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

  Widget _buildQuickStats(_AssignedCustomer customer, double scale) {
    final doneCount = customer.activities.where((a) => a.status.toLowerCase().contains('done')).length;
    
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

class _AssignedCustomer {
  final String customerId;
  final String displayName;
  final String avatarUrl;
  final String roomName;
  final int assignmentsCount;
  final List<_AssignedActivity> activities;
  final bool hasTodayActivity;
  final bool isCurrentlyActive;

  _AssignedCustomer({
    required this.customerId,
    required this.displayName,
    required this.avatarUrl,
    required this.roomName,
    required this.assignmentsCount,
    required this.activities,
    this.hasTodayActivity = false,
    this.isCurrentlyActive = false,
  });
}

class _AssignedActivity {
  final int staffScheduleId;
  final DateTime? startAt;
  final DateTime? endAt;
  final String activity;
  final String status;
  final String note;

  _AssignedActivity({
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

  _CalendarDay({required this.date, required this.activities});
}

class _FocusFamilyCard extends StatelessWidget {
  final _AssignedCustomer customer;
  final VoidCallback onTap;

  const _FocusFamilyCard({required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final now = DateTime.now();
    final todayStr = DateFormat('dd/MM').format(now);
    
    final todayActivities = customer.activities.where((a) =>
      a.startAt != null &&
      a.startAt!.year == now.year &&
      a.startAt!.month == now.month &&
      a.startAt!.day == now.day
    ).toList();

    _AssignedActivity? currentOrNext;
    if (customer.isCurrentlyActive) {
      currentOrNext = todayActivities.where((a) => 
        a.startAt != null && a.endAt != null && now.isAfter(a.startAt!) && now.isBefore(a.endAt!)).firstOrNull;
    } else {
      currentOrNext = todayActivities.where((a) => a.startAt != null && a.startAt!.isAfter(now))
        .toList().firstOrNull;
    }
    
    final displayActivity = currentOrNext ?? (todayActivities.isNotEmpty ? todayActivities.first : null);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
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
                          image: NetworkImage(customer.avatarUrl.isNotEmpty 
                            ? customer.avatarUrl 
                            : 'https://ui-avatars.com/api/?name=${customer.displayName}&background=random'),
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
                          customer.roomName.isNotEmpty ? customer.roomName : 'Chưa có thông tin phòng',
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
              padding: EdgeInsets.fromLTRB(20 * scale, 0, 20 * scale, 20 * scale),
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
                      style: AppTextStyles.arimo(fontSize: 13 * scale, color: AppColors.textSecondary),
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
  final _AssignedCustomer customer;
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
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(
            color: customer.hasTodayActivity 
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.borderLight.withValues(alpha: 0.5),
            width: 1,
          ),
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
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              )
            else
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.borderLight),
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
              label = 'Bỏ lỡ';
              break;
            case _ActivityFilter.staffDone:
              label = 'Đã cập nhật';
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
  final List<_CalendarDay> days;
  final Function(_AssignedActivity) onCheckPressed;

  const _ActivitiesVerticalList({
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
              Icon(Icons.event_busy_rounded, size: 48 * scale, color: AppColors.borderLight),
              SizedBox(height: 12 * scale),
              Text(
                'Không có hoạt động nào phù hợp với bộ lọc.',
                style: AppTextStyles.arimo(fontSize: 13 * scale, color: AppColors.textSecondary),
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
                    padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
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
            ...day.activities.map((act) => _ActivityItem(
              activity: act,
              onCheck: () => onCheckPressed(act),
            )),
          ],
        );
      }).toList(),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final _AssignedActivity activity;
  final VoidCallback onCheck;

  const _ActivityItem({required this.activity, required this.onCheck});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final statusColor = _getStatusColor(activity.status);
    final isDone = activity.status.toLowerCase().contains('done');

    return Container(
      margin: EdgeInsets.only(bottom: 12 * scale),
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDone ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
              size: 18 * scale,
              color: statusColor,
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        activity.activity,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.arimo(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8 * scale),
                    Text(
                      _formatTimeRange(activity.startAt, activity.endAt),
                      style: AppTextStyles.arimo(
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (activity.note.isNotEmpty) ...[
                  SizedBox(height: 4 * scale),
                  Text(
                    activity.note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.arimo(
                      fontSize: 13 * scale,
                      color: AppColors.textSecondary,
                    ).copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
                SizedBox(height: 10 * scale),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6 * scale),
                      ),
                      child: Text(
                        _getStatusText(activity.status),
                        style: AppTextStyles.arimo(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    if (!isDone)
                      TextButton.icon(
                        onPressed: onCheck,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 6 * scale),
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8 * scale),
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: Icon(Icons.add_task_rounded, size: 16 * scale, color: AppColors.primary),
                        label: Text(
                          'Cập nhật',
                          style: AppTextStyles.arimo(
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
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
        return 'Sắp diễn ra';
      case 'missed':
        return 'Đã lỡ';
      case 'staffdone':
      case 'staff_done':
        return 'Đã cập nhật';
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
}
