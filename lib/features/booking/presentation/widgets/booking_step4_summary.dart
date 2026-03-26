import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/bloc/booking_state.dart';
import '../../../../../features/employee/room/domain/entities/room_entity.dart';
import '../../../family_profile/domain/entities/family_profile_entity.dart';
import '../../../package/domain/entities/package_entity.dart';

class BookingStep4Summary extends StatelessWidget {
  final VoidCallback onConfirm;

  const BookingStep4Summary({
    super.key,
    required this.onConfirm,
  });

  String _formatPrice(double price) {
    final priceInt = price.toInt();
    final priceStr = priceInt.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < priceStr.length; i++) {
      if (i > 0 && (priceStr.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(priceStr[i]);
    }

    return '${buffer.toString()}${AppStrings.currencyUnit}';
  }

  String _getWeekdayLabel(DateTime date) {
    final days = [
      AppStrings.weekDaySunday,
      AppStrings.weekDayMonday,
      AppStrings.weekDayTuesday,
      AppStrings.weekDayWednesday,
      AppStrings.weekDayThursday,
      AppStrings.weekDayFriday,
      AppStrings.weekDaySaturday,
    ];
    return days[date.weekday % 7];
  }

  String _formatShortDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

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
        final bookingBloc = context.read<BookingBloc>();

        PackageEntity? package;
        RoomEntity? room;
        DateTime? startDate;

        if (state is BookingSummaryReady) {
          package = state.package;
          room = state.room;
          startDate = state.startDate;
        } else {
          package = bookingBloc.selectedPackage;
          startDate = bookingBloc.selectedDate;

          final selectedRoomId = bookingBloc.selectedRoomId;
          final rooms = bookingBloc.rooms;
          if (selectedRoomId != null && rooms != null && rooms.isNotEmpty) {
            try {
              room = rooms.firstWhere((r) => r.id == selectedRoomId);
            } catch (_) {
              room = null;
            }
          }
        }

        if (package == null || room == null || startDate == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16 * scale),
                Text(
                  AppStrings.bookingLoadingInfo,
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        final endDate = package.durationDays != null
            ? startDate.add(Duration(days: package.durationDays!))
            : startDate;

        final allProfiles = bookingBloc.familyProfiles ?? [];
        final selectedIds = bookingBloc.selectedFamilyProfileIds;
        final selectedProfiles = allProfiles
            .where((profile) => selectedIds.contains(profile.id))
            .toList();

        final totalPrice = package.basePrice;
        final depositAmount = totalPrice * 0.1;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _ServicePackageCard(
                        packageName: package.packageName,
                        roomTypeName: package.roomTypeName ?? AppStrings.bookingNotUpdated,
                        durationText: package.durationDays != null
                            ? '${package.durationDays} ${AppStrings.bookingDays}'
                            : AppStrings.bookingDays,
                      ),
                    ),
                    SizedBox(width: 10 * scale),
                    Expanded(
                      child: _SelectedRoomCard(
                        roomName: room.name,
                        floorText: room.floor != null
                            ? '${room.floor}'
                            : AppStrings.bookingNotUpdated,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14 * scale),
              _SummarySection(
                title: AppStrings.bookingSummaryServiceInfoWithCount
                    .replaceAll('{count}', '${selectedProfiles.length}'),
                child: selectedProfiles.isEmpty
                    ? Text(
                        AppStrings.bookingSummaryNoSelectedMembers,
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : Column(
                        children: selectedProfiles
                            .map(
                              (profile) => Padding(
                                padding: EdgeInsets.only(bottom: 10 * scale),
                                child: _SelectedMemberTile(
                                  profile: profile,
                                  memberTypeLabel: _getMemberTypeLabel(profile),
                                  genderLabel: _getGenderLabel(profile.gender),
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),
              SizedBox(height: 14 * scale),
              _SummarySection(
                title: AppStrings.bookingSummaryStayDuration,
                child: Row(
                  children: [
                    Expanded(
                      child: _DateInfoCard(
                        icon: Icons.login,
                        title: AppStrings.bookingCheckIn,
                        dayLabel: _getWeekdayLabel(startDate),
                        dateLabel: _formatShortDate(startDate),
                      ),
                    ),
                    SizedBox(width: 10 * scale),
                    Expanded(
                      child: _DateInfoCard(
                        icon: Icons.logout,
                        title: AppStrings.bookingCheckOut,
                        dayLabel: _getWeekdayLabel(endDate),
                        dateLabel: _formatShortDate(endDate),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14 * scale),
              _SummarySection(
                title: AppStrings.bookingSummaryPaymentMethod,
                child: Container(
                  padding: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 76 * scale,
                        height: 38 * scale,
                        padding: EdgeInsets.all(2 * scale),
                        child: SvgPicture.asset(
                          AppAssets.payosLogo,
                          fit: BoxFit.contain,
                          colorFilter: ColorFilter.mode(
                            AppColors.verified,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      SizedBox(width: 10 * scale),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.paymentPayOS,
                              style: AppTextStyles.arimo(
                                fontSize: 15 * scale,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2 * scale),
                            Text(
                              AppStrings.bookingSummaryPayOsSafe,
                              style: AppTextStyles.arimo(
                                fontSize: 12 * scale,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.check_circle,
                        color: AppColors.verified,
                        size: 20 * scale,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 14 * scale),
              _SummarySection(
                title: AppStrings.invoicePriceDetails,
                child: Column(
                  children: [
                    _PriceRow(
                      label: AppStrings.bookingTotalPrice,
                      amount: totalPrice,
                      scale: scale,
                    ),
                    SizedBox(height: 8 * scale),
                    _PriceRow(
                      label: AppStrings.bookingDiscount,
                      amount: 0,
                      scale: scale,
                    ),
                    Divider(height: 22 * scale),
                    _PriceRow(
                      label: AppStrings.bookingFinalAmount,
                      amount: totalPrice,
                      scale: scale,
                      isTotal: true,
                    ),
                    SizedBox(height: 12 * scale),
                    Container(
                      padding: EdgeInsets.all(12 * scale),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10 * scale),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.bookingDeposit,
                            style: AppTextStyles.arimo(
                              fontSize: 14 * scale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            _formatPrice(depositAmount),
                            style: AppTextStyles.tinos(
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8 * scale),
            ],
          ),
        );
      },
    );
  }
}

class _ServicePackageCard extends StatelessWidget {
  final String packageName;
  final String roomTypeName;
  final String durationText;

  const _ServicePackageCard({
    required this.packageName,
    required this.roomTypeName,
    required this.durationText,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.bookingSummaryServiceInfo,
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            packageName,
            style: AppTextStyles.tinos(
              fontSize: 22 * scale,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12 * scale),
          Row(
            children: [
              Icon(
                Icons.timelapse,
                size: 12 * scale,
                color: AppColors.primary,
              ),
              SizedBox(width: 6 * scale),
              Text(
                durationText,
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 8 * scale),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8 * scale,
                    vertical: 5 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10 * scale),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bed_outlined,
                        size: 12 * scale,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4 * scale),
                      Flexible(
                        child: Text(
                          roomTypeName,
                          style: AppTextStyles.arimo(
                            fontSize: 8 * scale,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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

class _DateInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String dayLabel;
  final String dateLabel;

  const _DateInfoCard({
    required this.icon,
    required this.title,
    required this.dayLabel,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 12 * scale,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: AppColors.primary, width: 1.2),
      ),
      child: Column(
        children: [
          Container(
            width: 34 * scale,
            height: 34 * scale,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            child: Icon(
              icon,
              size: 17 * scale,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            title,
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6 * scale),
          Text(
            dayLabel,
            style: AppTextStyles.arimo(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2 * scale),
          Text(
            dateLabel,
            style: AppTextStyles.arimo(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SelectedRoomCard extends StatelessWidget {
  final String roomName;
  final String floorText;

  const _SelectedRoomCard({
    required this.roomName,
    required this.floorText,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.bookingSummarySelectedRoom,
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 10 * scale),
          _InfoRow(
            icon: Icons.meeting_room_outlined,
            label: AppStrings.bookingSummaryRoomName,
            value: roomName,
          ),
          SizedBox(height: 10 * scale),
          _InfoRow(
            icon: Icons.layers_outlined,
            label: AppStrings.bookingFloor,
            value: floorText,
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final String title;
  final Widget child;

  const _SummarySection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 10 * scale),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18 * scale, color: AppColors.primary),
        SizedBox(width: 8 * scale),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 2 * scale),
              Text(
                value,
                style: AppTextStyles.arimo(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectedMemberTile extends StatelessWidget {
  final FamilyProfileEntity profile;
  final String memberTypeLabel;
  final String genderLabel;

  const _SelectedMemberTile({
    required this.profile,
    required this.memberTypeLabel,
    required this.genderLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18 * scale,
            backgroundColor: AppColors.borderLight,
            backgroundImage: (profile.avatarUrl != null &&
                    profile.avatarUrl!.isNotEmpty)
                ? NetworkImage(profile.avatarUrl!)
                : null,
            child: (profile.avatarUrl == null || profile.avatarUrl!.isEmpty)
                ? Icon(
                    Icons.person,
                    size: 18 * scale,
                    color: AppColors.primary,
                  )
                : null,
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  '$memberTypeLabel • $genderLabel',
                  style: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final double scale;
  final bool isTotal;

  const _PriceRow({
    required this.label,
    required this.amount,
    required this.scale,
    this.isTotal = false,
  });

  String _formatPrice(double price) {
    final priceInt = price.toInt();
    final priceStr = priceInt.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < priceStr.length; i++) {
      if (i > 0 && (priceStr.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(priceStr[i]);
    }

    return '${buffer.toString()}${AppStrings.currencyUnit}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: isTotal ? 16 * scale : 14 * scale,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          _formatPrice(amount),
          style: AppTextStyles.arimo(
            fontSize: isTotal ? 18 * scale : 14 * scale,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
