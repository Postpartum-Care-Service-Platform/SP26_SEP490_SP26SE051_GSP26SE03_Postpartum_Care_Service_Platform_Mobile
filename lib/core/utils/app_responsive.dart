import 'package:flutter/material.dart';

class AppResponsive {
  AppResponsive._();

  static const double tabletBp = 600;
  static const double desktopBp = 1024;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBp;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopBp;

  /// Max width for content (forms/auth) on larger screens.
  static double maxContentWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= desktopBp) return 480;
    if (w >= tabletBp) return 420;
    return w; // mobile: allow full width
  }

  /// Horizontal padding that scales a bit, but stays within a sane range.
  static EdgeInsets pagePadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    // Example: 16 on mobile, 24 on tablet, 32 on desktop
    final horizontal = (w >= desktopBp)
        ? 32.0
        : (w >= tabletBp)
            ? 24.0
            : 16.0;

    return EdgeInsets.symmetric(horizontal: horizontal);
  }

  /// Top spacing that reduces when keyboard is open.
  static double topSpacing(BuildContext context) {
    final mq = MediaQuery.of(context);
    final h = mq.size.height;
    final keyboardOpen = mq.viewInsets.bottom > 0;

    if (keyboardOpen) return 16;

    if (h < 650) return 24;
    if (h < 800) return 48;
    return 90;
  }
}


