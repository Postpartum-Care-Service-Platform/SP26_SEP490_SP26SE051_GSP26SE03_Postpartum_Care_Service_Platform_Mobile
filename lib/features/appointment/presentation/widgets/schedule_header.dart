import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../bloc/appointment_bloc.dart';
import '../bloc/appointment_event.dart';

/// Schedule screen header widget
class ScheduleHeader extends StatelessWidget {
  const ScheduleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        16 * scale,
        20 * scale,
        24 * scale,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppStrings.appointmentTitle,
              style: AppTextStyles.tinos(
                fontSize: 28 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                context.read<AppointmentBloc>().add(const AppointmentRefresh());
              },
              icon: Icon(
                Icons.refresh_rounded,
                color: AppColors.primary,
                size: 24 * scale,
              ),
              splashRadius: 24 * scale,
            ),
          ),
        ],
      ),
    );
  }
}
