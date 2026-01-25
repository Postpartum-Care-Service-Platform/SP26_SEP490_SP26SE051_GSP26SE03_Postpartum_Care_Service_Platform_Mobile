import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';

class CheckInOutCards extends StatelessWidget {
  final DateTime? checkInDate;
  final DateTime? checkOutDate;

  const CheckInOutCards({
    super.key,
    required this.checkInDate,
    required this.checkOutDate,
  });

  String _getDayName(DateTime date) {
    final days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return days[date.weekday % 7];
  }

  String _getDateString(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    if (checkInDate == null) {
      return const SizedBox();
    }

    return Row(
      children: [
        Expanded(
          child: _DateCard(
            icon: Icons.login,
            label: AppStrings.bookingCheckIn,
            date: checkInDate!,
            getDayName: _getDayName,
            getDateString: _getDateString,
            borderColor: AppColors.primary,
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: _DateCard(
            icon: Icons.logout,
            label: AppStrings.bookingCheckOut,
            date: checkOutDate,
            getDayName: _getDayName,
            getDateString: _getDateString,
            borderColor: checkOutDate != null
                ? AppColors.primary
                : AppColors.borderLight,
          ),
        ),
      ],
    );
  }
}

class _DateCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final DateTime? date;
  final String Function(DateTime) getDayName;
  final String Function(DateTime) getDateString;
  final Color borderColor;

  const _DateCard({
    required this.icon,
    required this.label,
    required this.date,
    required this.getDayName,
    required this.getDateString,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      height: 140 * scale,
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 12 * scale,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: borderColor, width: date != null ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              color: date != null
                  ? borderColor.withValues(alpha: 0.1)
                  : AppColors.borderLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            child: Icon(
              icon,
              size: 22 * scale,
              color: date != null ? borderColor : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            label,
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4 * scale),
          date != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      getDayName(date!),
                      style: AppTextStyles.arimo(
                        fontSize: 14 * scale,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      getDateString(date!),
                      style: AppTextStyles.arimo(
                        fontSize: 12 * scale,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : Text(
                  'Chưa chọn',
                  style: AppTextStyles.tinos(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
        ],
      ),
    );
  }
}
