import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
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

        if (profiles.isEmpty) {
          return Center(
            child: Text(
              'Chưa có thành viên gia đình',
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(16 * scale),
          itemCount: profiles.length,
          separatorBuilder: (_, __) => SizedBox(height: 10 * scale),
          itemBuilder: (context, index) {
            final profile = profiles[index];
            final isSelected = selectedIds.contains(profile.id);

            return InkWell(
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
                  children: [
                    Icon(
                      profile.isOwner ? Icons.person : Icons.family_restroom,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 10 * scale),
                    Expanded(
                      child: Text(
                        profile.fullName,
                        style: AppTextStyles.arimo(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
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
            );
          },
        );
      },
    );
  }
}
