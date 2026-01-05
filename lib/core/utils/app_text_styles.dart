import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Text Styles - Centralized text styles using Google Fonts
/// Following clean architecture principles for code reusability
class AppTextStyles {
  AppTextStyles._(); // Private constructor to prevent instantiation

  /// Tinos font - Used for app name and titles
  static TextStyle tinos({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return GoogleFonts.tinos(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// Arimo font - Used for body text, buttons, labels
  static TextStyle arimo({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return GoogleFonts.arimo(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}

