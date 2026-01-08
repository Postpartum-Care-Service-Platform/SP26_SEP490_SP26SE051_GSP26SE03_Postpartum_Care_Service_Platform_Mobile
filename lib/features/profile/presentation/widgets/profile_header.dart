import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';

/// Profile header widget displaying welcome message, user name and email
class ProfileHeader extends StatelessWidget {
  final String? userName;
  final String? userEmail;
  final bool isLoading;

  const ProfileHeader({
    super.key,
    this.userName,
    this.userEmail,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Text(
            AppStrings.welcomeBack,
            style: AppTextStyles.arimo(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          if (isLoading)
            _buildSkeleton(context)
          else
            Column(
              children: [
                Text(
                  userName ?? 'User',
                  style: AppTextStyles.tinos(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (userEmail != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    userEmail!,
                    style: AppTextStyles.arimo(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 200,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
