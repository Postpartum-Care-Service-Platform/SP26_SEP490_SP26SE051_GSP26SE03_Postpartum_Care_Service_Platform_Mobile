import 'package:flutter/material.dart';

/// App Colors - Centralized color definitions for the application
/// Following clean architecture principles for code reusability
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors
  static const Color primary = Color(0xFFFF8C00); // Orange - #ff8c00
  static const Color secondary = Color(0xFF000000); // Black
  static const Color third = Color(0xFF99A1AF); // Gray for placeholders - #99a1af

  // Background Colors
  static const Color background = Color(0xFFFFFBF5); // Light beige - #fffbf5
  static const Color white = Color(0xFFFFFFFF); // White

  // Text Colors
  static const Color textPrimary = Color(0xFF000000); // Black
  static const Color textSecondary = Color(0xFF99A1AF); // Gray
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White on primary background

  // Border Colors
  static const Color border = Color(0xFF000000); // Black border
  static const Color borderLight = Color(0x33000000); // Black with 20% opacity - rgba(0,0,0,0.2)

  // Google Button Colors
  static const Color googleButtonBackground = Color(0xFFFFFFFF); // White
  static const Color googleButtonBorder = Color(0xFF000000); // Black

  // Loading Colors
   static const Color loadingBackground = Color(0x33FFFFFF); // highlight
}

