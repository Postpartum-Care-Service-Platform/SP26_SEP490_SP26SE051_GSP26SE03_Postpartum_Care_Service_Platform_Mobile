import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/widgets/avatar_widget.dart';

/// Profile header widget displaying welcome message, user name and email
class ProfileHeader extends StatelessWidget {
  final String? userName;
  final String? userEmail;
  final String? avatarUrl;
  final bool isEmailVerified;
  final bool isLoading;

  const ProfileHeader({
    super.key,
    this.userName,
    this.userEmail,
    this.avatarUrl,
    this.isEmailVerified = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 32 * scale),
      child: Column(
        children: [
          Text(
            AppStrings.welcomeBack,
            style: AppTextStyles.arimo(
              fontSize: 16 * scale,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 16 * scale),
          if (isLoading)
            _buildSkeleton(context, scale)
          else
            Column(
              children: [
                // Avatar
                AvatarWidget(
                  imageUrl: avatarUrl,
                  displayName: userName,
                  size: 80,
                  showVerifiedBadge: true,
                  isVerified: isEmailVerified,
                  borderWidth: 3,
                ),
                SizedBox(height: 16 * scale),
                // Username with verified badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        userName ?? 'User',
                        style: AppTextStyles.tinos(
                          fontSize: 28 * scale,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isEmailVerified) ...[
                      SizedBox(width: 8 * scale),
                      Icon(
                        Icons.verified,
                        size: 24 * scale,
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
                if (userEmail != null) ...[
                  SizedBox(height: 8 * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 16 * scale,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 6 * scale),
                      Flexible(
                        child: Text(
                          userEmail!,
                          style: AppTextStyles.arimo(
                            fontSize: 14 * scale,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context, double scale) {
    return Column(
      children: [
        Container(
          width: 80 * scale,
          height: 80 * scale,
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: 16 * scale),
        Container(
          width: 120 * scale,
          height: 28 * scale,
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4 * scale),
          ),
        ),
        SizedBox(height: 8 * scale),
        Container(
          width: 200 * scale,
          height: 16 * scale,
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4 * scale),
          ),
        ),
      ],
    );
  }
}
