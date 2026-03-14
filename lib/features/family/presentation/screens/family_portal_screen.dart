// lib/features/family/presentation/screens/family_portal_screen.dart
// NOTE: Family portal main screen (ported from Familystay mobile FamilyPortal.tsx)
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../widgets/family_bottom_nav_bar.dart';
import '../widgets/family_fab.dart';
import 'family_meal_selection_screen.dart';
import 'family_chat_screen.dart';
import 'tabs/baby_care_tab.dart';
import 'tabs/family_overview_tab.dart';
import 'tabs/staff_info_tab.dart';

/// Enum to represent the currently selected family tab.
enum FamilyPortalTab { overview, schedule, babyCare, staff }

/// FamilyPortalScreen
/// - iOS-like header
/// - iOS-like blurred bottom tab bar
/// - Floating action menu (meals/services/chat/feedback)
class FamilyPortalScreen extends StatefulWidget {
  const FamilyPortalScreen({super.key});

  @override
  State<FamilyPortalScreen> createState() => _FamilyPortalScreenState();
}

class _FamilyPortalScreenState extends State<FamilyPortalScreen> {
  // Current selected bottom tab.
  FamilyPortalTab _currentTab = FamilyPortalTab.overview;

  // Floating menu visibility.
  bool _isFloatingMenuOpen = false;

  // Map tab to widget index.
  int get _currentIndex {
    switch (_currentTab) {
      case FamilyPortalTab.overview:
        return 0;
      case FamilyPortalTab.schedule:
        return 1;
      case FamilyPortalTab.babyCare:
        return 2;
      case FamilyPortalTab.staff:
        return 3;
    }
  }

  void _setTab(FamilyPortalTab tab) {
    // Close the floating menu when switching bottom tabs.
    setState(() {
      _currentTab = tab;
      _isFloatingMenuOpen = false;
    });
  }

  void _toggleFloatingMenu() {
    setState(() {
      _isFloatingMenuOpen = !_isFloatingMenuOpen;
    });
  }

  void _closeFloatingMenu() {
    setState(() {
      _isFloatingMenuOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use the same padding logic as other screens.
    final padding = AppResponsive.pagePadding(context);

    return Scaffold(
      backgroundColor: AppColors.familyBackground,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Main layout.
            Column(
              children: [
                // iOS-like header.
                _FamilyHeaderBar(padding: padding),

                // Main content.
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: const [
                      FamilyOverviewTab(),
                      _SchedulePlaceholderTab(),
                      BabyCareTab(),
                      StaffInfoTab(),
                    ],
                  ),
                ),

                // Bottom tab bar.
                FamilyBottomNavBar(
                  currentTab: _currentTab,
                  onTabSelected: _setTab,
                ),
              ],
            ),

            // Floating menu overlay.
            if (_isFloatingMenuOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closeFloatingMenu,
                  child: Container(color: Colors.black.withValues(alpha: 0.2)),
                ),
              ),

            // Floating button + menu.
            Positioned(
              right: padding.right,
              bottom: 96,
              child: FamilyFab(
                isOpen: _isFloatingMenuOpen,
                onToggle: _toggleFloatingMenu,
                onSelectAction: (action) {
                  // Close menu before routing.
                  _closeFloatingMenu();

                  // Route to feature screens.
                  if (action == FamilyFabAction.meals) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FamilyMealSelectionScreen(),
                      ),
                    );
                    return;
                  }

                  if (action == FamilyFabAction.services) {
                    AppRouter.push(context, AppRoutes.amenity);
                    return;
                  }

                  if (action == FamilyFabAction.chat) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FamilyChatScreen(),
                      ),
                    );
                    return;
                  }

                  if (action == FamilyFabAction.feedback) {
                    AppRouter.push(context, AppRoutes.feedback);
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đã chọn: ${action.label}',
                        style: AppTextStyles.arimo(color: AppColors.white),
                      ),
                      backgroundColor: AppColors.textPrimary,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilyHeaderBar extends StatelessWidget {
  final EdgeInsets padding;

  const _FamilyHeaderBar({required this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(padding.left, 12, padding.right, 12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.85),
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Portal Gia đình',
                  style: AppTextStyles.arimo(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Chăm sóc mẹ và bé',
                  style: AppTextStyles.arimo(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.familyPrimary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'GT',
              style: AppTextStyles.arimo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder tab thay thế CareScheduleTab (đã xóa vì dùng mock data).
/// Cho phép chuyển sang FamilyScheduleScreen (dùng API thật).
class _SchedulePlaceholderTab extends StatelessWidget {
  const _SchedulePlaceholderTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Lịch chăm sóc hàng ngày',
              style: AppTextStyles.arimo(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Xem lịch chi tiết theo ngày',
              style: AppTextStyles.arimo(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => AppRouter.push(context, AppRoutes.familySchedule),
              icon: const Icon(Icons.calendar_today, size: 18),
              label: const Text('Xem lịch'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.familyPrimary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
