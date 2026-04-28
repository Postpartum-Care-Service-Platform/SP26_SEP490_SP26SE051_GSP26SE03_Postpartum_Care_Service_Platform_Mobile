import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/family_profile_entity.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

/// Family member card widget
class FamilyMemberCard extends StatelessWidget {
  final FamilyProfileEntity member;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String? memberTypeName;
  final bool showActions;

  const FamilyMemberCard({
    super.key,
    required this.member,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.memberTypeName,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 6 * scale),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(
                color: member.isOwner
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.borderLight,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8 * scale,
                  offset: Offset(0, 2 * scale),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16 * scale),
              child: Slidable(
                key: ValueKey('slidable_family_member_${member.id}'),
                enabled: !member.isOwner && onDelete != null,
                endActionPane: ActionPane(
                  motion: const BehindMotion(),
                  extentRatio: 0.2,
                  children: [
                    CustomSlidableAction(
                      onPressed: (context) {
                        if (onDelete != null) onDelete!();
                      },
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                        size: 24 * scale,
                      ),
                    ),
                  ],
                ),
                child: Material(
                  color: AppColors.white,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16 * scale),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16 * scale,
                    16 * scale,
                    (memberTypeName != null || member.isOwner)
                        ? 88 * scale
                        : 16 * scale,
                    16 * scale,
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 56 * scale,
                        height: 56 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: member.isOwner
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.textSecondary.withValues(alpha: 0.08),
                          border: Border.all(
                            color: member.isOwner
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : AppColors.borderLight,
                            width: 1.5,
                          ),
                        ),
                        child: Container(
                          margin: EdgeInsets.all(2 * scale),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white,
                          ),
                          child: member.avatarUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    member.avatarUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        _buildDefaultAvatar(scale),
                                  ),
                                )
                              : _buildDefaultAvatar(scale),
                        ),
                      ),
                      SizedBox(width: 16 * scale),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    member.fullName,
                                    style: AppTextStyles.tinos(
                                      fontSize: 19 * scale,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ).copyWith(height: 1.2),
                                  ),
                                ),

                              ],
                            ),
                            SizedBox(height: 4 * scale),
                            if (member.phoneNumber != null) ...[
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    size: 13 * scale,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(width: 6 * scale),
                                  Text(
                                    member.phoneNumber!,
                                    style: AppTextStyles.arimo(
                                      fontSize: 13 * scale,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              if (member.dateOfBirth != null) SizedBox(height: 3 * scale),
                            ],
                            if (member.isOwner && member.address != null) ...[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 13 * scale,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(width: 6 * scale),
                                  Expanded(
                                    child: Text(
                                      member.address!,
                                      style: AppTextStyles.arimo(
                                        fontSize: 12 * scale,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4 * scale),
                            ],
                            if (member.dateOfBirth != null)
                              Row(
                                children: [
                                  Icon(
                                    Icons.cake_outlined,
                                    size: 13 * scale,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(width: 6 * scale),
                                  Text(
                                    _formatDate(member.dateOfBirth!),
                                    style: AppTextStyles.arimo(
                                      fontSize: 12 * scale,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ),
          ),
          if (member.isOwner)
            Positioned(
              top: 10 * scale,
              right: memberTypeName != null ? 22 * scale : 10 * scale,
              child: AppWidgets.pillBadge(
                context,
                text: AppStrings.owner,
                icon: Icons.verified_rounded,
                background: AppColors.primary.withValues(alpha: 0.12),
                textColor: AppColors.primary,
                borderColor: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
          if (memberTypeName != null)
            Positioned(
              right: -10 * scale,
              top: 0,
              bottom: 0,
              child: Center(
                child: RotatedBox(
                  quarterTurns: 1,
                  child: AppWidgets.pillBadge(
                    context,
                    text: _translateMemberType(memberTypeName!),
                    background: AppColors.textSecondary.withValues(alpha: 0.44),
                    borderColor: AppColors.borderLight,
                    textColor: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(double scale) {
    return Icon(
      Icons.person_rounded,
      size: 28 * scale,
      color: member.isOwner
          ? AppColors.primary
          : AppColors.textSecondary,
    );
  }

  String _translateMemberType(String value) {
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'head of family':
        return 'Giám hộ';
      case 'mom':
        return 'Mẹ';
      case 'baby':
        return 'Bé';
      default:
        return value;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
