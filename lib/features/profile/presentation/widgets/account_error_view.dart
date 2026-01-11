import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';

/// Error view widget for account details screen
class AccountErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AccountErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: AppTextStyles.arimo(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AppWidgets.primaryButton(
            text: AppStrings.retry,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
