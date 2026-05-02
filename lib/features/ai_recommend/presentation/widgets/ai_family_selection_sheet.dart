import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../family_profile/domain/entities/family_profile_entity.dart';
import '../../../../core/di/injection_container.dart';

class AiFamilySelectionSheet extends StatefulWidget {
  final List<FamilyProfileEntity> familyProfiles;
  final void Function(List<int> selectedIds) onConfirm;

  const AiFamilySelectionSheet({
    super.key,
    required this.familyProfiles,
    required this.onConfirm,
  });

  @override
  State<AiFamilySelectionSheet> createState() => _AiFamilySelectionSheetState();
}

class _AiFamilySelectionSheetState extends State<AiFamilySelectionSheet> {
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    // Auto-select Mom and Baby profiles
    for (final p in widget.familyProfiles) {
      if (p.memberTypeId == 2 || p.memberTypeId == 3) {
        _selectedIds.add(p.id);
      }
    }
  }

  String _translateMemberType(int? typeId) {
    switch (typeId) {
      case 1:
        return 'Giám hộ';
      case 2:
        return 'Mẹ';
      case 3:
        return 'Bé';
      default:
        return 'Thành viên';
    }
  }

  IconData _getMemberIcon(int? typeId) {
    switch (typeId) {
      case 2:
        return Icons.pregnant_woman_rounded;
      case 3:
        return Icons.child_care_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  Color _getMemberColor(int? typeId) {
    // Luôn sử dụng màu cam chủ đạo của ứng dụng cho tất cả đối tượng được chọn
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    // Only show Mom and Baby profiles (relevant for AI analysis)
    final relevantProfiles = widget.familyProfiles
        .where((p) => p.memberTypeId == 2 || p.memberTypeId == 3)
        .toList();

    return Container(
      padding: EdgeInsets.fromLTRB(20 * scale, 8 * scale, 20 * scale, 20 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28 * scale)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40 * scale,
            height: 4 * scale,
            margin: EdgeInsets.only(bottom: 16 * scale),
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(2 * scale),
            ),
          ),

          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10 * scale),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8C00), Color(0xFFE85D04)],
                  ),
                  borderRadius: BorderRadius.circular(14 * scale),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 22 * scale,
                ),
              ),
              SizedBox(width: 14 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Tư vấn gói dịch vụ',
                      style: AppTextStyles.tinos(
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      'Chọn thành viên để AI phân tích',
                      style: AppTextStyles.arimo(
                        fontSize: 13 * scale,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close_rounded, size: 22 * scale),
              ),
            ],
          ),

          SizedBox(height: 20 * scale),

          // Info banner
          Container(
            padding: EdgeInsets.all(12 * scale),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: const Color(0xFFFFCC80)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 20 * scale),
                SizedBox(width: 10 * scale),
                Expanded(
                  child: Text(
                    'AI sẽ dựa vào hồ sơ sức khoẻ để gợi ý gói phù hợp nhất',
                    style: AppTextStyles.arimo(
                      fontSize: 12.5 * scale,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16 * scale),

          // Member list
          if (relevantProfiles.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24 * scale),
              child: Text(
                'Chưa có hồ sơ mẹ và bé.\nVui lòng thêm thành viên trước.',
                style: AppTextStyles.arimo(
                  fontSize: 14 * scale,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...relevantProfiles.map((profile) {
              final isSelected = _selectedIds.contains(profile.id);
              final color = _getMemberColor(profile.memberTypeId);

              return Padding(
                padding: EdgeInsets.only(bottom: 10 * scale),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedIds.remove(profile.id);
                      } else {
                        _selectedIds.add(profile.id);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(16 * scale),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(14 * scale),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.08)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(16 * scale),
                      border: Border.all(
                        color: isSelected
                            ? color.withValues(alpha: 0.5)
                            : AppColors.borderLight,
                        width: isSelected ? 1.8 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        AvatarWidget(
                          imageUrl: profile.avatarUrl,
                          displayName: profile.fullName,
                          size: 44 * scale,
                          fallbackIcon: _getMemberIcon(profile.memberTypeId),
                        ),
                        SizedBox(width: 14 * scale),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.fullName,
                                style: AppTextStyles.arimo(
                                  fontSize: 15 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2 * scale),
                              Text(
                                _translateMemberType(profile.memberTypeId),
                                style: AppTextStyles.arimo(
                                  fontSize: 12.5 * scale,
                                  color: color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 28 * scale,
                          height: 28 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? color : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? color : AppColors.textSecondary,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Icon(Icons.check, size: 16 * scale, color: Colors.white)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

          SizedBox(height: 8 * scale),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 52 * scale,
            child: ElevatedButton(
              onPressed: _selectedIds.isEmpty
                  ? null
                  : () {
                      Navigator.pop(context);
                      widget.onConfirm(_selectedIds.toList());
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.borderLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16 * scale),
                ),
                elevation: _selectedIds.isEmpty ? 0 : 3,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, size: 20 * scale),
                  SizedBox(width: 10 * scale),
                  Text(
                    'Phân tích & Gợi ý',
                    style: AppTextStyles.arimo(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
        ],
      ),
    );
  }
}
