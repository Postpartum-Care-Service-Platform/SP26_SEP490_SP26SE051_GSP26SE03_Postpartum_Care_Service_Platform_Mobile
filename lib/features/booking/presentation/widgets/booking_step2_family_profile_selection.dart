import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../family_profile/domain/entities/family_profile_entity.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';

class BookingStep2FamilyProfileSelection extends StatelessWidget {
  final void Function(List<int> selectedIds) onSelectionChanged;

  const BookingStep2FamilyProfileSelection({
    super.key,
    required this.onSelectionChanged,
  });

  String _getMemberTypeLabel(FamilyProfileEntity profile) {
    if (profile.isOwner) return AppStrings.bookingProfileOwner;

    switch (profile.memberTypeId) {
      case 1:
        return AppStrings.bookingProfileOwner;
      case 2:
        return AppStrings.bookingProfileMother;
      case 3:
        return AppStrings.bookingProfileBaby;
      case 4:
        return AppStrings.bookingProfileRelative;
      default:
        return AppStrings.bookingProfileMember;
    }
  }

  String _getGenderLabel(String? gender) {
    if (gender == null || gender.trim().isEmpty) return AppStrings.bookingNotUpdated;

    final normalized = gender.trim().toLowerCase();
    if (normalized == 'male' || normalized == 'nam') return AppStrings.male;
    if (normalized == 'female' || normalized == 'nữ' || normalized == 'nu') {
      return AppStrings.female;
    }

    return gender;
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return const Center(child: AppLoadingIndicator());
        }

        if (state is BookingError) {
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

        List<FamilyProfileEntity> profiles = [];
        List<int> selectedIds = [];

        if (state is BookingFamilyProfilesLoaded) {
          profiles = state.profiles;
          selectedIds = state.selectedFamilyProfileIds;
        } else {
          final bloc = context.read<BookingBloc>();
          profiles = bloc.familyProfiles ?? [];
          selectedIds = bloc.selectedFamilyProfileIds;
          if (profiles.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.read<BookingBloc>().add(const BookingLoadFamilyProfiles());
              }
            });
            return const Center(child: AppLoadingIndicator());
          }
        }

        // Chỉ hiển thị Mẹ (memberTypeId=2) và Em bé (memberTypeId=3)
        final filteredProfiles = profiles
            .where((p) => p.memberTypeId == 2 || p.memberTypeId == 3)
            .toList();

        if (filteredProfiles.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * scale),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.family_restroom_rounded,
                    size: 56 * scale,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  SizedBox(height: 16 * scale),
                  Text(
                    'Chưa có hồ sơ Mẹ hoặc Em bé',
                    style: AppTextStyles.arimo(
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Text(
                    'Vui lòng thêm hồ sơ Mẹ và Em bé trong mục "Hồ sơ gia đình" trước khi đặt gói dịch vụ.',
                    style: AppTextStyles.arimo(
                      fontSize: 13 * scale,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.all(16 * scale),
          children: [
            // Note giải thích mục đích
            Container(
              margin: EdgeInsets.only(bottom: 14 * scale),
              padding: EdgeInsets.all(14 * scale),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18 * scale,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 10 * scale),
                  Expanded(
                    child: Text(
                      'Chọn Mẹ và Em bé sẽ được chăm sóc trong gói dịch vụ. '
                      'Thông tin này giúp trung tâm chuẩn bị lịch trình phù hợp nhất.',
                      style: AppTextStyles.arimo(
                        fontSize: 12.5 * scale,
                        color: AppColors.textSecondary,
                      ).copyWith(height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
            // Danh sách profiles
            ...List.generate(filteredProfiles.length, (index) {
              final profile = filteredProfiles[index];
              final isSelected = selectedIds.contains(profile.id);
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < filteredProfiles.length - 1 ? 10 * scale : 0,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14 * scale),
                  onTap: () {
                    final next = [...selectedIds];
                    if (isSelected) {
                      next.remove(profile.id);
                    } else {
                      next.add(profile.id);
                    }
                    onSelectionChanged(next);
                  },
                  child: Container(
                    padding: EdgeInsets.all(14 * scale),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14 * scale),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.borderLight,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 22 * scale,
                          backgroundColor: AppColors.borderLight,
                          backgroundImage: (profile.avatarUrl != null &&
                                  profile.avatarUrl!.isNotEmpty)
                              ? NetworkImage(profile.avatarUrl!)
                              : null,
                          child: (profile.avatarUrl == null ||
                                  profile.avatarUrl!.isEmpty)
                              ? Icon(
                                  profile.memberTypeId == 3
                                      ? Icons.child_care_rounded
                                      : Icons.pregnant_woman_rounded,
                                  color: AppColors.primary,
                                  size: 22 * scale,
                                )
                              : null,
                        ),
                        SizedBox(width: 12 * scale),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.fullName,
                                style: AppTextStyles.arimo(
                                  fontSize: 15 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4 * scale),
                              Text(
                                 '${AppStrings.memberType}: ${_getMemberTypeLabel(profile)}',
                                style: AppTextStyles.arimo(
                                  fontSize: 12 * scale,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 2 * scale),
                              Text(
                                '${AppStrings.gender}: ${_getGenderLabel(profile.gender)}',
                                style: AppTextStyles.arimo(
                                  fontSize: 12 * scale,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Checkbox(
                          value: isSelected,
                          onChanged: (_) {
                            final next = [...selectedIds];
                            if (isSelected) {
                              next.remove(profile.id);
                            } else {
                              next.add(profile.id);
                            }
                            onSelectionChanged(next);
                          },
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
