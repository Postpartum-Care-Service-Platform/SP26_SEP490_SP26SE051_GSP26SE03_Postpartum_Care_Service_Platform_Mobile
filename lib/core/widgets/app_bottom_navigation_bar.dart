import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../utils/app_responsive.dart';

enum AppBottomTab {
  home,
  services,
  schedule,
  profile,
}

extension AppBottomTabX on AppBottomTab {
  IconData get icon {
    switch (this) {
      case AppBottomTab.home:
        return Icons.home_rounded;
      case AppBottomTab.services:
        return Icons.account_balance_wallet_outlined;
      case AppBottomTab.schedule:
        return Icons.show_chart_rounded;
      case AppBottomTab.profile:
        return Icons.person_outline_rounded;
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
    final barHeight = 88 * scale;

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset == 0 ? 12 * scale : 0),
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
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  int _indexOf(AppBottomTab tab) => AppBottomTab.values.indexOf(tab);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _PillBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentTab != widget.currentTab) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    const itemCount = 4;
    final scale = AppResponsive.scaleFactor(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final outerHPadding = 18.0 * scale;
        final barHeight = 71.0 * scale;
        final selectedPillWidth = 57.0 * scale;
        final selectedPillTop = 8.0 * scale;
        final selectedPillBottom = -8.0 * scale;
        final borderRadius = 71.0 * scale;
        final selectedBorderRadius = 39.0 * scale;
        final shadowBlur = 18.0 * scale;
        final shadowOffsetY = 8.0 * scale;
        final selectedShadowOffsetY = 10.0 * scale;
        
        final availableWidth = constraints.maxWidth;
        final barWidth = availableWidth.isFinite ? availableWidth : 360.0 * scale;

        final itemWidth = (barWidth - outerHPadding * 2) / itemCount;
        final selectedIndex = _indexOf(widget.currentTab);

        final selectedLeft =
            outerHPadding + itemWidth * selectedIndex + (itemWidth - selectedPillWidth) / 2;

        return SizedBox(
          width: barWidth,
          height: barHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: shadowBlur,
                        offset: Offset(0, shadowOffsetY),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                left: selectedLeft,
                top: selectedPillTop,
                bottom: selectedPillBottom,
                width: selectedPillWidth,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: widget.selectedColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(selectedBorderRadius),
                        topRight: Radius.circular(selectedBorderRadius),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.selectedColor.withValues(alpha: 0.18),
                          blurRadius: shadowBlur,
                          offset: Offset(0, selectedShadowOffsetY),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: outerHPadding),
                  child: Row(
                    children: [
                      for (final tab in AppBottomTab.values)
                        Expanded(
                          child: _NavIconButton(
                            icon: tab.icon,
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
  final IconData icon;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;
  final double scale;

  const _NavIconButton({
    required this.icon,
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
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _backgroundController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _backgroundController.reverse();
  }

  void _handleTapCancel() {
    _backgroundController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.isSelected ? widget.selectedColor : widget.unselectedColor;
    final iconSize = 24.0 * widget.scale;
    final backgroundSize = 40.0 * widget.scale;
    final verticalPadding = 8.0 * widget.scale;
    final horizontalPadding = 4.0 * widget.scale;
    final iconTopPadding = widget.isSelected ? 0.0 : 4.0 * widget.scale;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: verticalPadding,
          horizontal: horizontalPadding,
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              FadeTransition(
                opacity: _backgroundAnimation,
                child: Container(
                  width: backgroundSize,
                  height: backgroundSize,
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? widget.selectedColor.withValues(alpha: 0.2)
                        : widget.unselectedColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: iconTopPadding),
                child: Icon(widget.icon, size: iconSize, color: iconColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

