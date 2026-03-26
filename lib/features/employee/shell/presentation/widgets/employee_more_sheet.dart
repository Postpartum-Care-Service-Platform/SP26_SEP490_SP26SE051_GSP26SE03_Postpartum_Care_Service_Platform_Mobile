// lib/features/employee/presentation/widgets/employee_more_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/routing/app_router.dart';
import '../../../../../core/routing/app_routes.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../features/employee/account/presentation/screens/employee_profile_screen.dart';
import '../../../../../features/employee/shell/presentation/widgets/employee_quick_menu.dart';

class EmployeeMoreSheet {
  EmployeeMoreSheet._();

  static void show(BuildContext context) {
    final authBloc = InjectionContainer.authBloc;
    final allItems = EmployeeQuickMenuPresets.allItems();

    // Chỉ lấy các extra actions (không phải bottom tab)
    final extraItems = allItems
        .where((item) => item.type == EmployeeQuickMenuItemType.extra)
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        final bottomInset = MediaQuery.of(bottomSheetContext).padding.bottom;
        final screenHeight = MediaQuery.of(bottomSheetContext).size.height;
        final maxHeight = screenHeight * 0.85;

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

                // Grid items với animation
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      padding: EdgeInsets.only(
                        bottom: bottomInset > 0 ? bottomInset + 8 : 16,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 125,
                          ),
                      itemCount: extraItems.length,
                      itemBuilder: (context, index) {
                        final item = extraItems[index];
                        return _ModernSheetItem(
                          item: item,
                          index: index,
                          onTap: () {
                            Navigator.of(bottomSheetContext).pop();
                            _handleAction(context, item.extraAction!, authBloc);
                          },
                        );
                      },
                    ),
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
    dynamic authBloc,
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
      case EmployeeQuickMenuExtraAction.checkInOut:
        AppRouter.push(context, AppRoutes.employeeCheckInOut);
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
      case EmployeeQuickMenuExtraAction.staffProfile:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: authBloc,
              child: const EmployeeProfileScreen(),
            ),
          ),
        );
        break;
      case EmployeeQuickMenuExtraAction.customerProfileQuickTest:
        _showCustomerProfileQuickTestDialog(context);
        break;
    }
  }

  static Future<void> _showCustomerProfileQuickTestDialog(
    BuildContext context,
  ) async {
    final customerIdController = TextEditingController();
    final customerNameController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Test Profile KH'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: customerIdController,
                decoration: const InputDecoration(
                  labelText: 'Customer ID',
                  hintText: 'Nhập customerId',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên khách (tuỳ chọn)',
                  hintText: 'VD: Nguyễn A',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Vào profile'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final customerId = customerIdController.text.trim();
    final customerName = customerNameController.text.trim();
    if (customerId.isEmpty) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập customerId.')),
      );
      return;
    }

    if (!context.mounted) {
      return;
    }

    AppRouter.push(
      context,
      AppRoutes.employeeCustomerFamilyProfile,
      arguments: {
        'customerId': customerId,
        'customerName': customerName.isEmpty ? null : customerName,
      },
    );
  }
}

class _ModernSheetItem extends StatefulWidget {
  final EmployeeQuickMenuItem item;
  final int index;
  final VoidCallback onTap;

  const _ModernSheetItem({
    required this.item,
    required this.index,
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
    // Màu đồng bộ cho mỗi item
    final itemColor = _getItemColor(widget.index);

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
            border: Border.all(
              color: AppColors.textSecondary.withValues(alpha: 0.1),
              width: 1,
            ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: itemColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: itemColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          widget.item.iconAsset,
                          width: 26,
                          height: 26,
                          colorFilter: ColorFilter.mode(
                            itemColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      child: Text(
                        widget.item.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.arimo(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
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

  Color _getItemColor(int index) {
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFFEC4899), // Pink
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEF4444), // Red
      const Color(0xFF14B8A6), // Teal
      const Color(0xFFF97316), // Orange
      const Color(0xFF6366F1), // Indigo
      const Color(0xFFEC4899), // Pink
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Yellow
      const Color(0xFF3B82F6), // Sky Blue
      const Color(0xFF8B5CF6), // Violet
    ];

    return colors[index % colors.length];
  }
}
