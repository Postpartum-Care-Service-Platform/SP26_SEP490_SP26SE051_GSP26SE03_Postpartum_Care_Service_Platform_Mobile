import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';

/// Booking Step Indicator Widget
/// Displays a horizontal progress indicator for booking steps
/// Shows completed steps with green checkmarks and pending steps with numbers
class BookingStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const BookingStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  }) : assert(currentStep >= 0 && currentStep < totalSteps,
            'currentStep must be between 0 and totalSteps-1');

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final circleSize = 40.0 * scale;
    final circleRadius = circleSize / 2; // 20 * scale
    final lineHeight = 2.0 * scale;
    final paddingTop = 16.0 * scale;
    final paddingBottom = 12.0 * scale;
    
    return Container(
      padding: EdgeInsets.only(
        left: 24 * scale,
        right: 24 * scale,
        top: paddingTop,
        bottom: paddingBottom,
      ),
      color: AppColors.background,
      child: Column(
        children: [
          // Row with circles and connecting lines
          SizedBox(
            height: circleSize,
            child: Stack(
              children: [
                // Connecting lines layer (behind circles)
                // Single continuous line connecting all circles
                Positioned(
                  left: circleRadius + 4, // Start from right edge of first circle
                  right: circleRadius + 4, // End at left edge of last circle
                  top: circleRadius - lineHeight / 2, // Center vertically at circle center
                  height: lineHeight,
                  child: Row(
                    children: List.generate(totalSteps - 1, (index) {
                      return Expanded(
                        child: _buildConnectingLine(index, index < currentStep, scale),
                      );
                    }),
                  ),
                ),
                // Steps layer (each step has circle)
                Row(
                  children: List.generate(totalSteps, (index) {
                    return Expanded(
                      child: Center(
                        child: _buildStepCircle(index, index < currentStep, index == currentStep, scale),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          SizedBox(height: 4 * scale),
          // Row with labels
          Row(
            children: List.generate(totalSteps, (index) {
              return Expanded(
                child: _buildStepLabel(
                  index,
                  index < currentStep,
                  index == currentStep,
                  scale,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(
    int index,
    bool isCompleted,
    bool isCurrent,
    double scale,
  ) {
    final size = 40.0 * scale;
    
    if (isCompleted) {
      // Completed step: Green circle with white checkmark
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.appointmentCompleted, // Green
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          color: AppColors.white,
          size: 20 * scale,
        ),
      );
    } else {
      // Pending/Current step: Gray outlined circle with number
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.textSecondary,
            width: 2 * scale,
          ),
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: AppTextStyles.arimo(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildConnectingLine(int index, bool isCompleted, double scale) {
    return Container(
      width: double.infinity, // Fill available width
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.appointmentCompleted // Green for completed
            : AppColors.textSecondary.withValues(alpha: 0.3), // Light gray for incomplete
        borderRadius: BorderRadius.circular(1 * scale),
      ),
    );
  }

  Widget _buildStepLabel(
    int index,
    bool isCompleted,
    bool isCurrent,
    double scale,
  ) {
    final label = _getStepLabel(index);
    
    return Text(
      label,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.arimo(
        fontSize: 12 * scale,
        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
        color: isCompleted || isCurrent
            ? AppColors.textPrimary
            : AppColors.textSecondary,
      ),
    );
  }

  String _getStepLabel(int index) {
    switch (index) {
      case 0:
        return AppStrings.bookingStep1;
      case 1:
        return AppStrings.bookingStep2;
      case 2:
        return AppStrings.bookingStep3;
      case 3:
        return AppStrings.bookingStep4;
      default:
        return 'Bước ${index + 1}';
    }
  }
}
