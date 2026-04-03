import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';

/// Home Service Step Indicator Widget
class HomeServiceStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;

  const HomeServiceStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
  }) : assert(currentStep >= 0 && currentStep < totalSteps,
            'currentStep must be between 0 and totalSteps-1');

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final circleSize = 40.0 * scale;
    final circleRadius = circleSize / 2;
    final lineHeight = 2.0 * scale;
    final paddingTop = 0.0 * scale;
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
          SizedBox(
            height: circleSize,
            child: Stack(
              children: [
                Positioned(
                  left: circleRadius + 4,
                  right: circleRadius + 4,
                  top: circleRadius - lineHeight / 2,
                  height: lineHeight,
                  child: Row(
                    children: List.generate(totalSteps - 1, (index) {
                      return Expanded(
                        child: _buildConnectingLine(index, index < currentStep, scale),
                      );
                    }),
                  ),
                ),
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
          Row(
            children: List.generate(totalSteps, (index) {
              return Expanded(
                child: _buildStepLabel(
                  index < stepTitles.length
                      ? stepTitles[index]
                      : '${AppStrings.bookingStep1} ${index + 1}',
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
      // Completed step: Primary circle with white number
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: AppTextStyles.arimo(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      );
    } else {
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
      width: double.infinity,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.primary
            : AppColors.textSecondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(1 * scale),
      ),
    );
  }

  Widget _buildStepLabel(
    String label,
    bool isCompleted,
    bool isCurrent,
    double scale,
  ) {
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
}
