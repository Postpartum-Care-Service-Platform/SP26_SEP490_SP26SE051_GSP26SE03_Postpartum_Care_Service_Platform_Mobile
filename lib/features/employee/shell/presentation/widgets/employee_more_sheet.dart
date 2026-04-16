// lib/features/employee/presentation/widgets/employee_more_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routing/app_router.dart';
import '../../../../../core/routing/app_routes.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../../features/employee/account/presentation/screens/employee_profile_screen.dart';
import '../../../../../features/employee/shell/presentation/widgets/employee_quick_menu.dart';

class EmployeeMoreSheet {
  EmployeeMoreSheet._();

  static void show(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;
    String? memberType;
    if (authState is AuthCurrentAccountLoaded) {
      final account = authState.account;
      memberType = (account as dynamic).memberType;

      // Resilience: check ownerProfile if memberType is null at root
      if (memberType == null) {
        try {
          memberType = (account as dynamic).ownerProfile?.memberTypeName;
        } catch (_) {}
      }
    }
    final allItems = EmployeeQuickMenuPresets.allItems(memberType);

    // Chỉ lấy các extra actions (không phải bottom tab)
    final extraItems = allItems
        .where((item) => item.type == EmployeeQuickMenuItemType.extra)
        .toList();
    final groupedItems = _buildGroupedItems(extraItems);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        final bottomInset = MediaQuery.of(bottomSheetContext).padding.bottom;
        final screenHeight = MediaQuery.of(bottomSheetContext).size.height;
        final maxHeight = screenHeight * 0.82;

        return Container(
          height: maxHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.white,
                AppColors.white,
                AppColors.background.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar với gradient
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.3),
                          AppColors.primary.withValues(alpha: 0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),

                // Header với icon và gradient background
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.apps_rounded,
                          color: AppColors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tiện ích cho nhân viên',
                              style: AppTextStyles.arimo(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Truy cập nhanh các chức năng thường dùng',
                              style: AppTextStyles.arimo(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Grid items theo nhóm nghiệp vụ
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      bottomInset > 0 ? bottomInset + 8 : 16,
                    ),
                    itemCount: groupedItems.length,
                    itemBuilder: (context, groupIndex) {
                      final group = groupedItems[groupIndex];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: _GroupSection(
                          group: group,
                          initiallyExpanded: groupIndex == 0,
                          onItemTap: (item) {
                            Navigator.of(bottomSheetContext).pop();
                            _handleAction(context, item.extraAction!, authBloc);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _handleAction(
    BuildContext context,
    EmployeeQuickMenuExtraAction action,
    AuthBloc authBloc,
  ) {
    switch (action) {
      case EmployeeQuickMenuExtraAction.appointments:
        AppRouter.push(context, AppRoutes.employeeAppointmentList);
        break;
      case EmployeeQuickMenuExtraAction.amenityService:
        AppRouter.push(context, AppRoutes.serviceBooking);
        break;
      case EmployeeQuickMenuExtraAction.amenityTicket:
        AppRouter.push(context, AppRoutes.staffAmenityTicketList);
        break;
      case EmployeeQuickMenuExtraAction.room:
        AppRouter.push(context, AppRoutes.employeeRooms);
        break;
      case EmployeeQuickMenuExtraAction.mealPlan:
        AppRouter.push(context, AppRoutes.employeeMealPlan);
        break;
      case EmployeeQuickMenuExtraAction.requests:
        AppRouter.push(context, AppRoutes.employeeRequests);
        break;
      case EmployeeQuickMenuExtraAction.tasks:
        AppRouter.push(context, AppRoutes.employeeTasks);
        break;
      case EmployeeQuickMenuExtraAction.familyProfile:
        AppRouter.push(context, AppRoutes.employeeAssignedFamilies);
        break;
      case EmployeeQuickMenuExtraAction.createCustomer:
        AppRouter.push(context, AppRoutes.employeeCreateCustomer);
        break;
      case EmployeeQuickMenuExtraAction.transactions:
        AppRouter.push(context, AppRoutes.staffTransactionList);
        break;
      case EmployeeQuickMenuExtraAction.contracts:
        AppRouter.push(context, AppRoutes.staffContractList);
        break;
      case EmployeeQuickMenuExtraAction.bookings:
        AppRouter.push(context, AppRoutes.staffBookingList);
        break;
      case EmployeeQuickMenuExtraAction.staffProfile:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider<AuthBloc>.value(
              value: authBloc,
              child: const EmployeeProfileScreen(),
            ),
          ),
        );
        break;
      case EmployeeQuickMenuExtraAction.wallet:
        AppRouter.push(context, AppRoutes.employeeWallet);
        break;
      case EmployeeQuickMenuExtraAction.myBookings:
        AppRouter.push(context, AppRoutes.employeeMyBookings);
        break;
      case EmployeeQuickMenuExtraAction.supportRequests:
        AppRouter.push(context, AppRoutes.employeeSupportRequests);
        break;
      case EmployeeQuickMenuExtraAction.feedbacks:
        AppRouter.push(context, AppRoutes.staffFeedbackList);
        break;
    }
  }

}

class _MenuGroup {
  final String title;
  final Color color;
  final List<EmployeeQuickMenuItem> items;

  const _MenuGroup({
    required this.title,
    required this.color,
    required this.items,
  });
}

List<_MenuGroup> _buildGroupedItems(List<EmployeeQuickMenuItem> items) {
  final group1 = <EmployeeQuickMenuItem>[];
  final group2 = <EmployeeQuickMenuItem>[];

  for (final item in items) {
    switch (item.extraAction) {
      case EmployeeQuickMenuExtraAction.tasks:
      case EmployeeQuickMenuExtraAction.appointments:
      case EmployeeQuickMenuExtraAction.room:
      case EmployeeQuickMenuExtraAction.requests:
      case EmployeeQuickMenuExtraAction.bookings:
      case EmployeeQuickMenuExtraAction.amenityService:
      case EmployeeQuickMenuExtraAction.amenityTicket:
      case EmployeeQuickMenuExtraAction.mealPlan:
      case EmployeeQuickMenuExtraAction.familyProfile:
      case EmployeeQuickMenuExtraAction.createCustomer:
      case EmployeeQuickMenuExtraAction.myBookings:
      case EmployeeQuickMenuExtraAction.supportRequests:
      case EmployeeQuickMenuExtraAction.feedbacks:
        group1.add(item);
        break;
      case EmployeeQuickMenuExtraAction.transactions:
      case EmployeeQuickMenuExtraAction.contracts:
      case EmployeeQuickMenuExtraAction.wallet:
      case EmployeeQuickMenuExtraAction.staffProfile:
        group2.add(item);
        break;
      case null:
        break;
    }
  }

  return [
    _MenuGroup(
      title: 'Công việc & Dịch vụ',
      color: AppColors.textPrimary,
      items: group1,
    ),
    _MenuGroup(
      title: 'Hồ sơ & Tài chính',
      color: AppColors.textPrimary,
      items: group2,
    ),
  ].where((group) => group.items.isNotEmpty).toList();
}

class _GroupSection extends StatefulWidget {
  final _MenuGroup group;
  final bool initiallyExpanded;
  final ValueChanged<EmployeeQuickMenuItem> onItemTap;

  const _GroupSection({
    required this.group,
    required this.initiallyExpanded,
    required this.onItemTap,
  });

  @override
  State<_GroupSection> createState() => _GroupSectionState();
}

class _GroupSectionState extends State<_GroupSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _toggleExpanded,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    group.title,
                    style: AppTextStyles.arimo(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
                Text(
                  '${group.items.length}',
                  style: AppTextStyles.arimo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more,
                    color: Colors.black87,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 124,
              ),
              itemCount: group.items.length,
              itemBuilder: (context, index) {
                final item = group.items[index];
                final isPriority =
                    item.extraAction == EmployeeQuickMenuExtraAction.tasks;
                return _ModernSheetItem(
                  item: item,
                  groupColor: AppColors.primary,
                  isPriority: isPriority,
                  onTap: () => widget.onItemTap(item),
                );
              },
            ),
          ),
          crossFadeState:
              _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 220),
        ),
      ],
    );
  }
}

class _ModernSheetItem extends StatefulWidget {
  final EmployeeQuickMenuItem item;
  final Color groupColor;
  final bool isPriority;
  final VoidCallback onTap;

  const _ModernSheetItem({
    required this.item,
    required this.groupColor,
    required this.isPriority,
    required this.onTap,
  });

  @override
  State<_ModernSheetItem> createState() => _ModernSheetItemState();
}

class _ModernSheetItemState extends State<_ModernSheetItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final itemColor = widget.groupColor;
    final borderColor = widget.isPriority
        ? itemColor.withValues(alpha: 0.45)
        : AppColors.textSecondary.withValues(alpha: 0.12);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: widget.isPriority ? 1.4 : 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isPriority ? 12 : 10,
                  vertical: widget.isPriority ? 12 : 10,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: widget.isPriority ? 54 : 48,
                      height: widget.isPriority ? 54 : 48,
                      decoration: BoxDecoration(
                        color: itemColor.withValues(alpha: widget.isPriority ? 0.16 : 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: itemColor.withValues(alpha: widget.isPriority ? 0.5 : 0.3),
                          width: widget.isPriority ? 2.2 : 2,
                        ),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          widget.item.iconAsset,
                          width: widget.isPriority ? 24 : 22,
                          height: widget.isPriority ? 24 : 22,
                          colorFilter: ColorFilter.mode(
                            itemColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        widget.item.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.arimo(
                          fontSize: widget.isPriority ? 11.5 : 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
