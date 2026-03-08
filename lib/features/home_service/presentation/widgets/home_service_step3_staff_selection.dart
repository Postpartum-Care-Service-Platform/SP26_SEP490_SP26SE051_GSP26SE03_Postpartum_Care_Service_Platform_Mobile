import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../domain/entities/home_staff_entity.dart';
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
          return const Center(child: AppLoadingIndicator());
        }

        if (state is HomeServiceLoading) {
          return const Center(child: AppLoadingIndicator());
        }

        if (state is HomeServiceFreeStaffLoaded) {
          final staffList = state.staffList;
          final selectedStaff = state.selectedStaff;

          return SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: staffList.isEmpty
                      ? Center(
                          child: Text(
                            AppStrings.homeServiceNoFreeStaff,
                            style: AppTextStyles.arimo(
                              fontSize: 16 * scale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.all(16 * scale),
                          itemCount: staffList.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12 * scale,
                            mainAxisSpacing: 12 * scale,
                            childAspectRatio: 0.76,
                          ),
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

        if (state is HomeServiceError) {
          return Center(
            child: Text(
              state.message,
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        return const Center(child: AppLoadingIndicator());
      },
    );
  }
}

class _StaffCard extends StatelessWidget {
  final HomeStaffEntity staff;
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
        padding: EdgeInsets.fromLTRB(12 * scale, 10 * scale, 12 * scale, 10 * scale),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.homeServiceShadowLight,
              blurRadius: 12 * scale,
              offset: Offset(0, 4 * scale),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 20 * scale,
              ),
            ),
            Center(
              child: CircleAvatar(
                radius: 34 * scale,
                backgroundImage: staff.avatarUrl != null
                    ? NetworkImage(staff.avatarUrl!)
                    : null,
                child: staff.avatarUrl == null
                    ? Icon(Icons.person, size: 34 * scale)
                    : null,
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              staff.fullName ?? staff.username,
              style: AppTextStyles.tinos(
                fontSize: 19 * scale,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4 * scale),
            Text(
              staff.email,
              style: AppTextStyles.arimo(
                fontSize: 13 * scale,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4 * scale),
            Text(
              staff.phone,
              style: AppTextStyles.arimo(
                fontSize: 13 * scale,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (staff.age != null) ...[
              SizedBox(height: 4 * scale),
              Text(
                '${staff.age} ${AppStrings.homeServiceYearsOld}',
                style: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
