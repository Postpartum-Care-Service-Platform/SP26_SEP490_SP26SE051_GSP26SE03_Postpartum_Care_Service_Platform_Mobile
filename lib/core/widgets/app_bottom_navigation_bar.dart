import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_assets.dart';
import '../utils/app_responsive.dart';

enum AppBottomTab { home, appointment, services, chat, profile }

extension AppBottomTabX on AppBottomTab {
  IconData? get icon {
    switch (this) {
      case AppBottomTab.home:
        return null; // Use SVG instead
      case AppBottomTab.appointment:
        return null; // Use SVG instead
      case AppBottomTab.services:
        return null; // Use SVG instead
      case AppBottomTab.chat:
        return null; // Use SVG instead
      case AppBottomTab.profile:
        return null;
    }
  }

  String? get svgIcon {
    switch (this) {
      case AppBottomTab.home:
        return AppAssets.home;
      case AppBottomTab.appointment:
        return AppAssets.calendar;
      case AppBottomTab.services:
        return AppAssets.appIconThird;
      case AppBottomTab.chat:
        return AppAssets.chatMessage;
      case AppBottomTab.profile:
        return AppAssets.profile;
    }
  }

  String get label {
    switch (this) {
      case AppBottomTab.home:
        return AppStrings.bottomNavHome;
      case AppBottomTab.appointment:
        return AppStrings.bottomNavSchedule;
      case AppBottomTab.services:
        return AppStrings.bottomNavServices;
      case AppBottomTab.chat:
        return AppStrings.bottomNavChat;
      case AppBottomTab.profile:
        return AppStrings.bottomNavProfile;
    }
  }
}

class AppBottomNavigationBar extends StatelessWidget {
  final AppBottomTab currentTab;
  final ValueChanged<AppBottomTab> onTabSelected;

  const AppBottomNavigationBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final scale = AppResponsive.scaleFactor(context);

    final selectedColor = AppColors.primary;
    final unselectedColor = AppColors.third;
    final barHeight = 80 * scale;

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset == 0 ? 8 * scale : 0),
        child: SizedBox(
          height: barHeight,
          child: _PillBottomNav(
            currentTab: currentTab,
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
            onTabSelected: onTabSelected,
          ),
        ),
      ),
    );
  }
}

class _PillBottomNav extends StatefulWidget {
  final AppBottomTab currentTab;
  final Color selectedColor;
  final Color unselectedColor;
  final ValueChanged<AppBottomTab> onTabSelected;

  const _PillBottomNav({
    required this.currentTab,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTabSelected,
  });

  @override
  State<_PillBottomNav> createState() => _PillBottomNavState();
}

class _PillBottomNavState extends State<_PillBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  int _indexOf(AppBottomTab tab) => AppBottomTab.values.indexOf(tab);

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));

    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _PillBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentTab != widget.currentTab) {
      _slideController.reset();
      _scaleController.reset();
      _slideController.forward();
      _scaleController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    const itemCount = 5; // số lượng tab hiện tại
    final scale = AppResponsive.scaleFactor(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final outerHPadding = 16.0 * scale;
        final barHeight = 72.0 * scale;
        final selectedPillWidth = 52.0 * scale;
        final selectedPillTop = 6.0 * scale;
        final selectedPillBottom = -6.0 * scale;
        final selectedBorderRadius = 26.0 * scale;
        final topBorderRadius = 20.0 * scale;
        final shadowBlur = 20.0 * scale;
        final shadowOffsetY = 4.0 * scale;
        final selectedShadowBlur = 16.0 * scale;
        final selectedShadowOffsetY = 0.0;

        final availableWidth = constraints.maxWidth;
        final barWidth = availableWidth.isFinite
            ? availableWidth
            : 360.0 * scale;

        final itemWidth = (barWidth - outerHPadding * 2) / itemCount;
        final selectedIndex = _indexOf(widget.currentTab);

        final selectedLeft =
            outerHPadding +
            itemWidth * selectedIndex +
            (itemWidth - selectedPillWidth) / 2;

        return SizedBox(
          width: barWidth,
          height: barHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Background with enhanced shadow and border
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(topBorderRadius),
                      topRight: Radius.circular(topBorderRadius),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: Colors.black.withValues(alpha: 0.12),
                        width: 1.0 * scale,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: shadowBlur,
                        offset: Offset(0, shadowOffsetY),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: shadowBlur * 0.5,
                        offset: Offset(0, shadowOffsetY * 0.5),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),

              // Selected indicator pill with smooth animation
              Positioned(
                left: selectedLeft,
                top: selectedPillTop,
                bottom: selectedPillBottom,
                width: selectedPillWidth,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: widget.selectedColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(selectedBorderRadius),
                          topRight: Radius.circular(selectedBorderRadius),
                          bottomLeft: Radius.zero,
                          bottomRight: Radius.zero,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.selectedColor.withValues(alpha: 0.25),
                            blurRadius: selectedShadowBlur,
                            offset: Offset(0, selectedShadowOffsetY),
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Navigation icons
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: outerHPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (final tab in AppBottomTab.values)
                        Expanded(
                          child: _NavIconButton(
                            icon: tab.icon,
                            svgIcon: tab.svgIcon,
                            label: tab.label,
                            isSelected: tab == widget.currentTab,
                            selectedColor: AppColors.white,
                            unselectedColor: widget.unselectedColor,
                            onTap: () => widget.onTabSelected(tab),
                            scale: scale,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavIconButton extends StatefulWidget {
  final IconData? icon;
  final String? svgIcon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;
  final double scale;

  const _NavIconButton({
    this.icon,
    this.svgIcon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
    required this.scale,
  });

  @override
  State<_NavIconButton> createState() => _NavIconButtonState();
}

class _NavIconButtonState extends State<_NavIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    if (widget.isSelected) {
      _scaleController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _NavIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _scaleController.forward().then((_) => _scaleController.reverse());
      }
    }
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.isSelected
        ? widget.selectedColor
        : widget.unselectedColor;
    final textColor = widget.isSelected
        ? widget.selectedColor
        : widget.unselectedColor;
    final iconSize = 22.0 * widget.scale;
    final selectedIconSize = 24.0 * widget.scale;
    final fontSize = 10.0 * widget.scale;
    final selectedFontSize = 11.0 * widget.scale;
    final spacing = 4.0 * widget.scale;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 6.0 * widget.scale),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: widget.isSelected ? 1.0 : 0.95,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: widget.svgIcon != null
                    ? SvgPicture.asset(
                        widget.svgIcon!,
                        width: widget.isSelected ? selectedIconSize : iconSize,
                        height: widget.isSelected ? selectedIconSize : iconSize,
                        colorFilter: ColorFilter.mode(
                          iconColor,
                          BlendMode.srcIn,
                        ),
                      )
                    : Icon(
                        widget.icon,
                        size: widget.isSelected ? selectedIconSize : iconSize,
                        color: iconColor,
                      ),
              ),
            ),
            SizedBox(height: spacing),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: widget.isSelected ? selectedFontSize : fontSize,
                fontWeight: widget.isSelected
                    ? FontWeight.w600
                    : FontWeight.w500,
                color: textColor,
                height: 1.2,
              ),
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
