import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../bloc/home_service_bloc.dart';
import '../bloc/home_service_event.dart';
import '../bloc/home_service_state.dart';

class HomeServiceStep3StaffSelection extends StatelessWidget {
  const HomeServiceStep3StaffSelection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocBuilder<HomeServiceBloc, HomeServiceState>(
      builder: (context, state) {
        if (state is HomeServiceActivitiesLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<HomeServiceBloc>().add(const HomeServiceLoadFreeStaff());
          });

          return const Center(child: AppLoadingIndicator());
        }

        if (state is HomeServiceFreeStaffLoaded) {
          final staffList = state.staffList;
          final selectedStaff = state.selectedStaff;

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: staffList.isEmpty
                      ? Center(
                          child: Text(
                            'Không có nhân viên rảnh',
                            style: AppTextStyles.arimo(
                              fontSize: 16 * scale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16 * scale),
                          itemCount: staffList.length,
                          itemBuilder: (context, index) {
                            final staff = staffList[index];
                            final isSelected = selectedStaff?.id == staff.id;

                            return _StaffCard(
                              staff: staff,
                              isSelected: isSelected,
                              onTap: () {
                                context.read<HomeServiceBloc>().add(
                                      HomeServiceSelectStaff(staff),
                                    );
                              },
                            );
                          },
                        ),
                ),
                SizedBox(height: 8 * scale),
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}

class _StaffCard extends StatelessWidget {
  final dynamic staff;
  final bool isSelected;
  final VoidCallback onTap;

  const _StaffCard({
    required this.staff,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12 * scale),
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12 * scale,
              offset: Offset(0, 4 * scale),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30 * scale,
              backgroundImage: staff.avatarUrl != null
                  ? NetworkImage(staff.avatarUrl!)
                  : null,
              child: staff.avatarUrl == null
                  ? Icon(Icons.person, size: 30 * scale)
                  : null,
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.fullName ?? staff.username,
                    style: AppTextStyles.tinos(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    staff.email,
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (staff.age != null) ...[
                    SizedBox(height: 2 * scale),
                    Text(
                      '${staff.age} tuổi',
                      style: AppTextStyles.arimo(
                        fontSize: 12 * scale,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24 * scale,
              ),
          ],
        ),
      ),
    );
  }
}
