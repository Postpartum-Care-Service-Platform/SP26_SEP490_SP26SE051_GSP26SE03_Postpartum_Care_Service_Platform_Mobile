// lib/features/family/presentation/widgets/family_fab.dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';

/// Floating actions that match FamilyPortal.tsx floating menu.
enum FamilyFabAction {
  meals,
  services,
  chat,
  feedback,
}

extension FamilyFabActionX on FamilyFabAction {
  String get label {
    switch (this) {
      case FamilyFabAction.meals:
        return 'Thực đơn';
      case FamilyFabAction.services:
        return 'Dịch vụ';
      case FamilyFabAction.chat:
        return 'Nhắn tin';
      case FamilyFabAction.feedback:
        return 'Đánh giá';
    }
  }

  IconData get icon {
    switch (this) {
      case FamilyFabAction.meals:
        return Icons.restaurant_menu;
      case FamilyFabAction.services:
        return Icons.auto_awesome;
      case FamilyFabAction.chat:
        return Icons.chat_bubble_outline;
      case FamilyFabAction.feedback:
        return Icons.star_border;
    }
  }
}

class FamilyFab extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onToggle;
  final ValueChanged<FamilyFabAction> onSelectAction;

  const FamilyFab({
    super.key,
    required this.isOpen,
    required this.onToggle,
    required this.onSelectAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Menu.
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: isOpen
              ? _FamilyFabMenu(
                  onSelectAction: onSelectAction,
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 12),

        // Main FAB.
        GestureDetector(
          onTap: onToggle,
          child: AnimatedRotation(
            turns: isOpen ? 0.125 : 0.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.familyPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.add,
                color: AppColors.white,
                size: 30,
                weight: 700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FamilyFabMenu extends StatelessWidget {
  final ValueChanged<FamilyFabAction> onSelectAction;

  const _FamilyFabMenu({required this.onSelectAction});

  @override
  Widget build(BuildContext context) {
    final actions = <FamilyFabAction>[
      FamilyFabAction.meals,
      FamilyFabAction.services,
      FamilyFabAction.chat,
      FamilyFabAction.feedback,
    ];

    return Container(
      width: 176,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final action in actions)
            InkWell(
              onTap: () => onSelectAction(action),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      action.icon,
                      size: 20,
                      color: AppColors.familyPrimary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        action.label,
                        style: AppTextStyles.arimo(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
