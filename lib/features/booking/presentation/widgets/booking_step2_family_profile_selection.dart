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
import '../../../health_record/domain/entities/health_record_entity.dart';
import '../../../health_record/presentation/screens/health_record_screen.dart';
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
  final Map<int, bool> _hasRecords = {};

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
    if (gender == null || gender.trim().isEmpty) {
      return AppStrings.bookingNotUpdated;
    }

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

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            context.read<BookingBloc>().add(
              BookingLoadFamilyProfiles(accountId: widget.accountId),
            );
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                  key: ValueKey(profile.id),
                  padding: EdgeInsets.only(
                    bottom: index < filteredProfiles.length - 1
                        ? 10 * scale
                        : 0,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14 * scale),
                    onTap: () {
                      final hasRecord = _hasRecords[profile.id];
                      if (hasRecord == false) {
                        AppToast.showError(
                          context,
                          message:
                              'Vui lòng cập nhật hồ sơ y tế cho ${profile.fullName} trước khi chọn',
                        );
                        return;
                      }
                      if (hasRecord == null) {
                        AppToast.showInfo(
                          context,
                          message: 'Đang kiểm tra hồ sơ y tế...',
                        );
                        return;
                      }

                      final next = [...selectedIds];
                      if (isSelected) {
                        next.remove(profile.id);
                      } else {
                        // Rule: Only 1 Mom (memberTypeId == 2) can be selected
                        if (profile.memberTypeId == 2) {
                          final existingMom = filteredProfiles.firstWhere(
                            (p) =>
                                p.memberTypeId == 2 &&
                                selectedIds.contains(p.id),
                            orElse: () => profile, // Fallback if none found
                          );
                          if (existingMom.id != profile.id &&
                              selectedIds.contains(existingMom.id)) {
                            next.remove(existingMom.id);
                          }
                        }
                        next.add(profile.id);
                      }
                      widget.onSelectionChanged(next);
                    },
                    onLongPress: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => InjectionContainer.healthRecordBloc,
                            child: HealthRecordScreen(
                              familyProfileId: profile.id,
                              isBaby: profile.memberTypeId == 3,
                              memberName: profile.fullName,
                              avatarUrl: profile.avatarUrl,
                            ),
                          ),
                        ),
                      );
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
                                SizedBox(height: 6 * scale),
                                _HealthRecordInfo(
                                  familyProfileId: profile.id,
                                  scale: scale,
                                  onRecordStatusKnown: (hasRecord) {
                                    if (_hasRecords[profile.id] != hasRecord) {
                                      setState(() {
                                        _hasRecords[profile.id] = hasRecord;
                                      });
                                    }
                                    // If auto-selected by Bloc but lacks a record, unselect it immediately
                                    if (!hasRecord &&
                                        selectedIds.contains(profile.id)) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            final next = [...selectedIds]
                                              ..remove(profile.id);
                                            widget.onSelectionChanged(next);
                                          });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: isSelected,
                            onChanged: (_) {
                              final hasRecord = _hasRecords[profile.id];
                              if (hasRecord == false) {
                                AppToast.showError(
                                  context,
                                  message:
                                      'Vui lòng cập nhật hồ sơ y tế cho ${profile.fullName} trước khi chọn',
                                );
                                return;
                              }
                              if (hasRecord == null) {
                                AppToast.showInfo(
                                  context,
                                  message: 'Đang kiểm tra hồ sơ y tế...',
                                );
                                return;
                              }

                              final next = [...selectedIds];
                              if (isSelected) {
                                next.remove(profile.id);
                              } else {
                                // Rule: Only 1 Mom (memberTypeId == 2)
                                if (profile.memberTypeId == 2) {
                                  final existingMom = filteredProfiles
                                      .firstWhere(
                                        (p) =>
                                            p.memberTypeId == 2 &&
                                            selectedIds.contains(p.id),
                                        orElse: () => profile,
                                      );
                                  if (existingMom.id != profile.id &&
                                      selectedIds.contains(existingMom.id)) {
                                    next.remove(existingMom.id);
                                  }
                                }
                                next.add(profile.id);
                              }
                              widget.onSelectionChanged(next);
                            },
                            activeColor: AppColors.primary,
                            fillColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (_hasRecords[profile.id] == false) {
                                return AppColors.borderLight;
                              }
                              if (states.contains(WidgetState.selected)) {
                                return AppColors.primary;
                              }
                              return null;
                            }),
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
          ),
        );
      },
    );
  }
}

class _HealthRecordInfo extends StatefulWidget {
  final int familyProfileId;
  final double scale;
  final void Function(bool hasRecord) onRecordStatusKnown;

  const _HealthRecordInfo({
    required this.familyProfileId,
    required this.scale,
    required this.onRecordStatusKnown,
  });

  @override
  State<_HealthRecordInfo> createState() => _HealthRecordInfoState();
}

class _HealthRecordInfoState extends State<_HealthRecordInfo> {
  late Future<List<HealthRecordEntity>> _future;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    _future = InjectionContainer.healthRecordRepository
        .getHealthRecordsByFamilyProfile(widget.familyProfileId)
        .then((records) {
          final hasRecord = records.isNotEmpty;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) widget.onRecordStatusKnown(hasRecord);
          });
          return records;
        });
  }

  @override
  void didUpdateWidget(covariant _HealthRecordInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.familyProfileId != widget.familyProfileId) {
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    return FutureBuilder<List<HealthRecordEntity>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 12 * scale,
            width: 12 * scale,
            child: CircularProgressIndicator(
              strokeWidth: 2 * scale,
              color: AppColors.primary,
            ),
          );
        }
        if (snapshot.hasError) {
          return Text(
            'Lỗi tải hồ sơ y tế',
            style: AppTextStyles.arimo(
              fontSize: 11 * scale,
              color: Colors.red,
            ).copyWith(fontStyle: FontStyle.italic),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text(
            'Chưa có hồ sơ y tế',
            style: AppTextStyles.arimo(
              fontSize: 11 * scale,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ).copyWith(fontStyle: FontStyle.italic),
          );
        }

        final record = snapshot.data!.last; // Lấy hồ sơ mới nhất

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (record.generalCondition != null &&
                record.generalCondition!.isNotEmpty) ...[
              Text(
                'Sức khỏe: ${record.generalCondition}',
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4 * scale),
            ],
            if (record.conditions.isNotEmpty)
              Wrap(
                spacing: 6 * scale,
                runSpacing: 4 * scale,
                children: record.conditions.map((c) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6 * scale,
                      vertical: 2 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4 * scale),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      c.name,
                      style: AppTextStyles.arimo(
                        fontSize: 10 * scale,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }
}
