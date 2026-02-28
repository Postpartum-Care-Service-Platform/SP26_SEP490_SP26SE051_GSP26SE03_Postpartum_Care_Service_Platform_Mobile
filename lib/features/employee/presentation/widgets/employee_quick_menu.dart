import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_bottom_navigation_bar.dart';

/// Loại item trong menu nhanh nhân viên
enum EmployeeQuickMenuItemType { bottomTab, extra }

/// Các action mở rộng (ngoài bottom tab)
/// Tuỳ nghiệp vụ bạn có thể bổ sung thêm
enum EmployeeQuickMenuExtraAction {
  amenityService,
  amenityTicket,
  room,
  mealPlan,
  requests,
  tasks,
  checkInOut,
  staffProfile,
  familyProfile,
  createCustomer,
  transactions,
  contracts,
}

/// Model định nghĩa 1 item trong menu nhanh
class EmployeeQuickMenuItem {
  final String id; // id duy nhất phục vụ semantics / test
  final String label; // tiêu đề hiển thị
  final String iconAsset; // đường dẫn SVG icon
  final EmployeeQuickMenuItemType type; // loại item
  final AppBottomTab? bottomTab; // tab đích nếu là bottomTab
  final EmployeeQuickMenuExtraAction? extraAction; // action extra nếu là extra

  const EmployeeQuickMenuItem._({
    required this.id,
    required this.label,
    required this.iconAsset,
    required this.type,
    this.bottomTab,
    this.extraAction,
  });

  /// Tạo item map sang 1 tab của bottom navigation hiện tại
  factory EmployeeQuickMenuItem.bottom({
    required String id,
    required String label,
    required String iconAsset,
    required AppBottomTab tab,
  }) {
    return EmployeeQuickMenuItem._(
      id: id,
      label: label,
      iconAsset: iconAsset,
      type: EmployeeQuickMenuItemType.bottomTab,
      bottomTab: tab,
    );
  }

  /// Tạo item cho action mở rộng (không thuộc bottom tab)
  factory EmployeeQuickMenuItem.extra({
    required String id,
    required String label,
    required String iconAsset,
    required EmployeeQuickMenuExtraAction action,
  }) {
    return EmployeeQuickMenuItem._(
      id: id,
      label: label,
      iconAsset: iconAsset,
      type: EmployeeQuickMenuItemType.extra,
      extraAction: action,
    );
  }
}

/// Section menu nhanh kiểu MoMo đặt dưới phần thống kê / lịch làm việc
class EmployeeQuickMenuSection extends StatefulWidget {
  /// 4 item chính ở trạng thái thu gọn
  final List<EmployeeQuickMenuItem> primaryItems;

  /// Toàn bộ item ở trạng thái mở rộng
  final List<EmployeeQuickMenuItem> allItems;

  /// Tab hiện tại của bottom navigation (nếu cần highlight)
  final AppBottomTab currentTab;

  /// Callback tái sử dụng logic điều hướng của bottom nav
  final ValueChanged<AppBottomTab> onBottomTabSelected;

  /// Callback cho các action mở rộng (push sang màn khác)
  final ValueChanged<EmployeeQuickMenuExtraAction>? onExtraActionSelected;

  const EmployeeQuickMenuSection({
    super.key,
    required this.primaryItems,
    required this.allItems,
    required this.currentTab,
    required this.onBottomTabSelected,
    this.onExtraActionSelected,
  });

  @override
  State<EmployeeQuickMenuSection> createState() =>
      _EmployeeQuickMenuSectionState();
}

class _EmployeeQuickMenuSectionState extends State<EmployeeQuickMenuSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  late final AnimationController _controller;
  late final Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _iconRotation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _handleItemTap(EmployeeQuickMenuItem item) {
    switch (item.type) {
      case EmployeeQuickMenuItemType.bottomTab:
        if (item.bottomTab != null) {
          widget.onBottomTabSelected(item.bottomTab!);
        }
        break;
      case EmployeeQuickMenuItemType.extra:
        if (item.extraAction != null && widget.onExtraActionSelected != null) {
          widget.onExtraActionSelected!(item.extraAction!);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final horizontalPadding = 16.0 * scale;
    final verticalPadding = 12.0 * scale;

    return Container(
      margin: EdgeInsets.only(top: 16.0 * scale),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.0 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18.0 * scale,
            offset: Offset(0, 8.0 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          SizedBox(height: 12.0 * scale),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _isExpanded
                  ? _EmployeeQuickMenuExpandedGrid(
                      key: const ValueKey('expanded'),
                      items: widget.allItems,
                      onItemTap: _handleItemTap,
                      currentTab: widget.currentTab,
                    )
                  : _EmployeeQuickMenuCollapsedRow(
                      key: const ValueKey('collapsed'),
                      items: widget.primaryItems,
                      onItemTap: _handleItemTap,
                      currentTab: widget.currentTab,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Menu nhanh',
              style: AppTextStyles.arimo(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4 * scale),
            Text(
              _isExpanded
                  ? 'Tất cả tác vụ cho nhân viên'
                  : 'Một số tác vụ thường dùng',
              style: AppTextStyles.arimo(
                fontSize: 12 * scale,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: _toggleExpanded,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isExpanded ? 'Thu gọn' : 'Xem thêm',
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 4 * scale),
              RotationTransition(
                turns: _iconRotation,
                child: Icon(
                  Icons.expand_more,
                  size: 18 * scale,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmployeeQuickMenuCollapsedRow extends StatelessWidget {
  final List<EmployeeQuickMenuItem> items;
  final ValueChanged<EmployeeQuickMenuItem> onItemTap;
  final AppBottomTab currentTab;

  const _EmployeeQuickMenuCollapsedRow({
    super.key,
    required this.items,
    required this.onItemTap,
    required this.currentTab,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Row(
      children: [
        for (final item in items.take(4))
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0 * scale),
              child: _EmployeeQuickMenuIconTile(
                item: item,
                onTap: () => onItemTap(item),
                isActive:
                    item.type == EmployeeQuickMenuItemType.bottomTab &&
                    item.bottomTab == currentTab,
              ),
            ),
          ),
      ],
    );
  }
}

class _EmployeeQuickMenuExpandedGrid extends StatelessWidget {
  final List<EmployeeQuickMenuItem> items;
  final ValueChanged<EmployeeQuickMenuItem> onItemTap;
  final AppBottomTab currentTab;

  const _EmployeeQuickMenuExpandedGrid({
    super.key,
    required this.items,
    required this.onItemTap,
    required this.currentTab,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8.0 * scale,
        mainAxisSpacing: 12.0 * scale,
        mainAxisExtent: 82.0 * scale,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final isActive =
            item.type == EmployeeQuickMenuItemType.bottomTab &&
            item.bottomTab == currentTab;

        return _EmployeeQuickMenuIconTile(
          item: item,
          onTap: () => onItemTap(item),
          isActive: isActive,
        );
      },
    );
  }
}

class _EmployeeQuickMenuIconTile extends StatelessWidget {
  final EmployeeQuickMenuItem item;
  final VoidCallback onTap;
  final bool isActive;

  const _EmployeeQuickMenuIconTile({
    required this.item,
    required this.onTap,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    final Color bgColor;
    final Color iconColor;
    final Color textColor;

    if (isActive) {
      bgColor = AppColors.primary.withValues(alpha: 0.1);
      iconColor = AppColors.primary;
      textColor = AppColors.textPrimary;
    } else {
      bgColor = AppColors.background;
      iconColor = AppColors.third;
      textColor = AppColors.textSecondary;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0 * scale),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54.0 * scale,
            height: 54.0 * scale,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16.0 * scale),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              item.iconAsset,
              width: 26.0 * scale,
              height: 26.0 * scale,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
          SizedBox(height: 6.0 * scale),
          Text(
            item.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.arimo(
              fontSize: 11.0 * scale,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cấu hình default cho menu nhanh nhân viên.
/// Bạn có thể dùng trực tiếp hoặc custom lại trong screen.
class EmployeeQuickMenuPresets {
  static List<EmployeeQuickMenuItem> primaryItems() {
    return [
      EmployeeQuickMenuItem.bottom(
        id: 'schedule',
        label: 'Lịch làm việc',
        iconAsset: AppAssets.calendar,
        tab: AppBottomTab.appointment,
      ),
      EmployeeQuickMenuItem.bottom(
        id: 'services',
        label: 'Dịch vụ',
        iconAsset: AppAssets.appIconThird,
        tab: AppBottomTab.services,
      ),
      EmployeeQuickMenuItem.bottom(
        id: 'chat',
        label: 'Trao đổi',
        iconAsset: AppAssets.chatMessage,
        tab: AppBottomTab.chat,
      ),
      EmployeeQuickMenuItem.extra(
        id: 'staff_profile',
        label: 'Tài khoản',
        iconAsset: AppAssets.profile,
        action: EmployeeQuickMenuExtraAction.staffProfile,
      ),
    ];
  }

  static List<EmployeeQuickMenuItem> allItems() {
    return [
      // Các tab bottom navigation
      EmployeeQuickMenuItem.bottom(
        id: 'schedule',
        label: 'Lịch làm việc',
        iconAsset: AppAssets.calendar,
        tab: AppBottomTab.appointment,
      ),
      EmployeeQuickMenuItem.bottom(
        id: 'services',
        label: 'Dịch vụ',
        iconAsset: AppAssets.appIconThird,
        tab: AppBottomTab.services,
      ),
      EmployeeQuickMenuItem.bottom(
        id: 'chat',
        label: 'Trao đổi',
        iconAsset: AppAssets.chatMessage,
        tab: AppBottomTab.chat,
      ),
      EmployeeQuickMenuItem.extra(
        id: 'staff_profile',
        label: 'Tài khoản',
        iconAsset: AppAssets.profile,
        action: EmployeeQuickMenuExtraAction.staffProfile,
      ),
      EmployeeQuickMenuItem.extra(
        id: 'create_customer',
        label: 'Tạo KH',
        iconAsset: AppAssets.profile,
        action: EmployeeQuickMenuExtraAction.createCustomer,
      ),

      // Một số action extra mẫu dành cho nhân viên
      EmployeeQuickMenuItem.extra(
        id: 'amenity_service',
        label: 'Tiện ích',
        iconAsset: AppAssets.serviceAmenity,
        action: EmployeeQuickMenuExtraAction.amenityService,
      ),
      EmployeeQuickMenuItem.extra(
        id: 'amenity_ticket',
        label: 'Phiếu DV',
        iconAsset: AppAssets.menuFirst,
        action: EmployeeQuickMenuExtraAction.amenityTicket,
      ),
      EmployeeQuickMenuItem.extra(
        id: 'room',
        label: 'Phòng ở',
        iconAsset: AppAssets.family,
        action: EmployeeQuickMenuExtraAction.room,
      ),
      EmployeeQuickMenuItem.extra(
        id: 'family_profile',
        label: 'Gia đình',
        iconAsset: AppAssets.family,
        action: EmployeeQuickMenuExtraAction.familyProfile,
      ),
      EmployeeQuickMenuItem.extra(
        id: 'tasks',
        label: 'Công việc',
        iconAsset: AppAssets.menuFirst,
        action: EmployeeQuickMenuExtraAction.tasks,
      ),
      EmployeeQuickMenuItem.extra(
        id: 'check_in_out',
        label: 'Check-in/out',
        iconAsset: AppAssets.calendarBold,
        action: EmployeeQuickMenuExtraAction.checkInOut,
      ),
      EmployeeQuickMenuItem.extra(
        id: 'meal_plan',
        label: 'Suất ăn',
        iconAsset: AppAssets.menuSecond,
        action: EmployeeQuickMenuExtraAction.mealPlan,
      ),
      EmployeeQuickMenuItem.extra(
        id: 'requests',
        label: 'Yêu cầu',
        iconAsset: AppAssets.menuThird,
        action: EmployeeQuickMenuExtraAction.requests,
      ),
      EmployeeQuickMenuItem.extra(
        id: 'transactions',
        label: 'Giao dịch',
        iconAsset: AppAssets.menuThird,
        action: EmployeeQuickMenuExtraAction.transactions,
      ),
      EmployeeQuickMenuItem.extra(
        id: 'contracts',
        label: 'Hợp đồng',
        iconAsset: AppAssets.menuThird,
        action: EmployeeQuickMenuExtraAction.contracts,
      ),
    ];
  }
}
