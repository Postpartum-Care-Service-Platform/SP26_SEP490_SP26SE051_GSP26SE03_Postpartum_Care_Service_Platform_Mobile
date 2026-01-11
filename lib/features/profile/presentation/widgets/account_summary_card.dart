import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../auth/data/models/current_account_model.dart';

/// Player card style account summary card
class AccountSummaryCard extends StatelessWidget {
  final CurrentAccountModel account;

  const AccountSummaryCard({
    super.key,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20 * scale,
            offset: Offset(0, 10 * scale),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30 * scale,
            right: -30 * scale,
            child: Container(
              width: 120 * scale,
              height: 120 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -20 * scale,
            left: -20 * scale,
            child: Container(
              width: 80 * scale,
              height: 80 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(24 * scale),
            child: Column(
              children: [
                // Avatar with border and verified badge
                AvatarWidget(
                  imageUrl: account.avatarUrl,
                  displayName: account.username,
                  size: 100,
                  showVerifiedBadge: true,
                  isVerified: account.isEmailVerified,
                  backgroundColor: AppColors.white,
                  borderWidth: 4,
                  borderColor: AppColors.white,
                ),
                SizedBox(height: 20 * scale),
                // Username with verified icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        account.username,
                        style: AppTextStyles.tinos(
                          fontSize: 24 * scale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (account.isEmailVerified) ...[
                      SizedBox(width: 8 * scale),
                      Icon(
                        Icons.verified,
                        size: 20 * scale,
                        color: AppColors.white,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 8 * scale),
                // Email
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 16 * scale,
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                    SizedBox(width: 6 * scale),
                    Flexible(
                      child: Text(
                        account.email,
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.normal,
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16 * scale),
                // Role badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale,
                    vertical: 8 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20 * scale),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    account.roleName.toUpperCase(),
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
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
