import 'package:flutter/material.dart';

/// App Text Styles - Centralized text styles using custom fonts
/// Following clean architecture principles for code reusability
class AppTextStyles {
  AppTextStyles._(); // Private constructor to prevent instantiation

  /// Queens font - Used for app name and titles
  static TextStyle tinos({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'Queens',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  /// ES Rebond Grotesque font - Used for body text, buttons, labels
  static TextStyle arimo({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'ESRebondGrotesque',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}

