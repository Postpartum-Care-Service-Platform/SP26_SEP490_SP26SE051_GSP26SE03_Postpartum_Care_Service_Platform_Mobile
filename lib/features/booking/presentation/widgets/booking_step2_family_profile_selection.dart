import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../family_profile/data/models/create_family_profile_request_model.dart';
import '../../../family_profile/data/models/member_type_model.dart';
import '../../../family_profile/domain/entities/family_profile_entity.dart';
import '../../../family_profile/presentation/widgets/family_profile_form_drawer.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';

class BookingStep2FamilyProfileSelection extends StatefulWidget {
  final String? accountId;
  final void Function(List<int> selectedIds) onSelectionChanged;

  const BookingStep2FamilyProfileSelection({
    super.key,
    this.accountId,
    required this.onSelectionChanged,
  });

  @override
  State<BookingStep2FamilyProfileSelection> createState() =>
      _BookingStep2FamilyProfileSelectionState();
}

class _BookingStep2FamilyProfileSelectionState
    extends State<BookingStep2FamilyProfileSelection> {
  bool _isSubmitting = false;

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
    if (gender == null || gender.trim().isEmpty)
      return AppStrings.bookingNotUpdated;

    final normalized = gender.trim().toLowerCase();
    if (normalized == 'male' || normalized == 'nam') return AppStrings.male;
    if (normalized == 'female' || normalized == 'nữ' || normalized == 'nu') {
      return AppStrings.female;
    }

    return gender;
  }

  bool _isMomOrBabyType(MemberTypeModel type) {
    final normalized = type.name.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    return normalized == 'mom' || normalized == 'baby';
  }

  Future<void> _openCreateMemberForm(List<int> selectedIds) async {
    final scale = AppResponsive.scaleFactor(context);

    List<MemberTypeModel> memberTypes;
    try {
      final allTypes = await InjectionContainer.familyProfileRepository
          .getMemberTypes();
      memberTypes =
          allTypes.where((t) => t.isActive).where(_isMomOrBabyType).toList()
            ..sort((a, b) {
              int rank(MemberTypeModel t) {
                final name = t.name.trim().toLowerCase();
                if (name == 'mom') return 0;
                if (name == 'baby') return 1;
                return 99;
              }

              final byRank = rank(a).compareTo(rank(b));
              if (byRank != 0) return byRank;
              return a.name.compareTo(b.name);
            });
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(
        context,
        message: 'Không tải được loại thành viên: $e',
      );
      return;
    }

    if (!mounted) return;

    if (memberTypes.isEmpty) {
      AppToast.showWarning(
        context,
        message: 'Không có loại thành viên Mom/Baby để thêm mới.',
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(top: 12 * scale),
          child: FamilyProfileFormDrawer(
            memberTypes: memberTypes,
            onSave:
                ({
                  required String fullName,
                  int? memberTypeId,
                  DateTime? dateOfBirth,
                  String? gender,
                  String? address,
                  String? phoneNumber,
                  File? avatar,
                }) async {
                  if (_isSubmitting) return;

                  _isSubmitting = true;
                  AppLoading.show(context, message: AppStrings.processing);

                  try {
                    final request = CreateFamilyProfileRequestModel(
                      memberTypeId: memberTypeId,
                      fullName: fullName,
                      dateOfBirth: dateOfBirth,
                      gender: gender,
                      address: address,
                      phoneNumber: phoneNumber,
                      avatar: avatar,
                    );

                    final created = await InjectionContainer
                        .familyProfileRepository
                        .createFamilyProfile(request);

                    if (!mounted || !sheetContext.mounted) return;

                    Navigator.of(sheetContext).pop();
                    AppLoading.hide(context);
                    AppToast.showSuccess(
                      context,
                      message: AppStrings.updateSuccess,
                    );

                    context.read<BookingBloc>().add(
                      BookingLoadFamilyProfiles(accountId: widget.accountId),
                    );

                    if (created.memberTypeId == 2 ||
                        created.memberTypeId == 3) {
                      final nextIds = [...selectedIds];
                      if (!nextIds.contains(created.id)) {
                        nextIds.add(created.id);
                        widget.onSelectionChanged(nextIds);
                      }
                    }
                  } catch (e) {
                    if (!mounted) return;
                    AppLoading.hide(context);
                    AppToast.showError(
                      context,
                      message: '${AppStrings.updateFailed}: $e',
                    );
                  } finally {
                    _isSubmitting = false;
                  }
                },
          ),
        );
      },
    );
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
                context.read<BookingBloc>().add(
                  BookingLoadFamilyProfiles(accountId: widget.accountId),
                );
              }
            });
            return const Center(child: AppLoadingIndicator());
          }
        }

        final filteredProfiles = profiles
            .where((p) => p.memberTypeId == 2 || p.memberTypeId == 3)
            .toList();

        return ListView(
          padding: EdgeInsets.all(16 * scale),
          children: [
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

            if (filteredProfiles.isEmpty)
              Center(
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
                        'Bạn có thể tạo trực tiếp bằng nút + ở bên dưới danh sách.',
                        style: AppTextStyles.arimo(
                          fontSize: 13 * scale,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
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
                    widget.onSelectionChanged(next);
                  },
                  child: Container(
                    padding: EdgeInsets.all(14 * scale),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14 * scale),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderLight,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 22 * scale,
                          backgroundColor: AppColors.borderLight,
                          backgroundImage:
                              (profile.avatarUrl != null &&
                                  profile.avatarUrl!.isNotEmpty)
                              ? NetworkImage(profile.avatarUrl!)
                              : null,
                          child:
                              (profile.avatarUrl == null ||
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
                            widget.onSelectionChanged(next);
                          },
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            SizedBox(height: 12 * scale),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 42 * scale,
                height: 42 * scale,
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(21 * scale),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(21 * scale),
                    onTap: _isSubmitting
                        ? null
                        : () => _openCreateMemberForm(selectedIds),
                    child: Icon(
                      Icons.add_rounded,
                      size: 24 * scale,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
