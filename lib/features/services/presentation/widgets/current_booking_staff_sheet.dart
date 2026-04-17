import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/data/models/staff_model.dart';
import '../../data/datasources/feedback_remote_datasource.dart';

class CurrentBookingStaffSheet extends StatefulWidget {
  const CurrentBookingStaffSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CurrentBookingStaffSheet(),
    );
  }

  @override
  State<CurrentBookingStaffSheet> createState() => _CurrentBookingStaffSheetState();
}

class _CurrentBookingStaffSheetState extends State<CurrentBookingStaffSheet> {
  late Future<List<StaffModel>> _staffFuture;

  @override
  void initState() {
    super.initState();
    // Fetch data khi mở sheet
    final remoteDataSource = FeedbackRemoteDataSourceImpl();
    _staffFuture = remoteDataSource.getCurrentBookingStaff();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(top: kToolbarHeight),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24 * scale)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12 * scale, bottom: 16 * scale),
                width: 40 * scale,
                height: 4 * scale,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2 * scale),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * scale),
              child: Text(
                'Nhân viên phục vụ',
                style: AppTextStyles.tinos(
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 4 * scale),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * scale),
              child: Text(
                'Danh sách nhân viên chăm sóc gia đình bạn',
                style: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20 * scale),
            Divider(height: 1, color: AppColors.borderLight),

            Flexible(
              child: FutureBuilder<List<StaffModel>>(
                future: _staffFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: 200 * scale,
                      alignment: Alignment.center,
                      child: const AppLoadingIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Container(
                      height: 200 * scale,
                      padding: EdgeInsets.all(24 * scale),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, size: 40 * scale, color: AppColors.red),
                          SizedBox(height: 12 * scale),
                          Text(
                            'Không thể tải danh sách nhân viên.',
                            style: AppTextStyles.arimo(fontSize: 14 * scale, color: AppColors.textSecondary),
                          ),
                          SizedBox(height: 12 * scale),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                final remoteDataSource = FeedbackRemoteDataSourceImpl();
                                _staffFuture = remoteDataSource.getCurrentBookingStaff();
                              });
                            },
                            child: const Text('Thử lại'),
                          )
                        ],
                      ),
                    );
                  }

                  final staffs = snapshot.data ?? [];

                  if (staffs.isEmpty) {
                    return Container(
                      height: 200 * scale,
                      alignment: Alignment.center,
                      child: Text(
                        'Chưa có thông tin nhân viên.',
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.fromLTRB(20 * scale, 16 * scale, 20 * scale, bottomInset + 32 * scale),
                    itemCount: staffs.length,
                    separatorBuilder: (_, __) => SizedBox(height: 16 * scale),
                    itemBuilder: (context, index) {
                      final staff = staffs[index];
                      return Container(
                        padding: EdgeInsets.all(16 * scale),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16 * scale),
                          border: Border.all(color: AppColors.borderLight),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10 * scale,
                              offset: Offset(0, 4 * scale),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28 * scale,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              backgroundImage: staff.avatarUrl != null && staff.avatarUrl!.isNotEmpty
                                  ? NetworkImage(staff.avatarUrl!)
                                  : null,
                              child: staff.avatarUrl == null || staff.avatarUrl!.isEmpty
                                  ? Text(
                                      staff.fullName.isNotEmpty ? staff.fullName[0].toUpperCase() : 'S',
                                      style: AppTextStyles.arimo(
                                        fontSize: 20 * scale,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : null,
                            ),
                            SizedBox(width: 16 * scale),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    staff.fullName,
                                    style: AppTextStyles.arimo(
                                      fontSize: 16 * scale,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (staff.phone != null && staff.phone!.isNotEmpty) ...[
                                    SizedBox(height: 6 * scale),
                                    Row(
                                      children: [
                                        Icon(Icons.phone, size: 14 * scale, color: AppColors.primary),
                                        SizedBox(width: 6 * scale),
                                        Text(
                                          staff.phone!,
                                          style: AppTextStyles.arimo(
                                            fontSize: 13 * scale,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (staff.email != null && staff.email!.isNotEmpty) ...[
                                    SizedBox(height: 4 * scale),
                                    Row(
                                      children: [
                                        Icon(Icons.email_outlined, size: 14 * scale, color: AppColors.textSecondary),
                                        SizedBox(width: 6 * scale),
                                        Expanded(
                                          child: Text(
                                            staff.email!,
                                            style: AppTextStyles.arimo(
                                              fontSize: 12 * scale,
                                              color: AppColors.textSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
