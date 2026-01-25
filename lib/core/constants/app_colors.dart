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

  // Family Portal Colors
  static const Color familyPrimary = Color.fromARGB(255, 251, 131, 19);
  static const Color familyBackground = Color(0xFFF2F2F7);

  // Loading Colors
   static const Color loadingBackground = Color(0x33FFFFFF); // highlight

   static const Color logout = Color.fromARGB(255, 255, 0, 0); // red
   static const Color verified = Color.fromARGB(255, 0, 128, 0); // green
   static const Color red = Color.fromARGB(255, 255, 0, 0); // red

  // Package Colors
  static const Color packageVip = Color(0xFFFF8C00); // Gold for VIP packages
  static const Color packagePro = Color(0xFF9C27B0); // Purple for PRO packages

  // Appointment Status Colors
  static const Color appointmentScheduled = Color(0xFF2196F3); // Blue
  static const Color appointmentRescheduled = Color(0xFF2196F3); // Blue
  static const Color appointmentCompleted = Color(0xFF4CAF50); // Green
  static const Color appointmentPending = Color(0xFFFF8C00); // Amber
  static const Color appointmentCancelled = Color(0xFFF44336); // Red
}

