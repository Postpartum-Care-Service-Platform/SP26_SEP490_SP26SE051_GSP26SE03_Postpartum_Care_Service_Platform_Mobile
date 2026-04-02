import 'package:flutter/material.dart';

/// App Text Styles - Centralized text styles using custom fonts
/// Following clean architecture principles for code reusability
class AppTextStyles {
  AppTextStyles._();

  static TextStyle tinos({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? letterSpacing,
    double? height,                
    List<Shadow>? shadows,          
  }) {
    return TextStyle(
      fontFamily: 'Queens',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,              
      shadows: shadows,             
    );
  }

  static TextStyle arimo({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? letterSpacing,
    double? height,               
    List<Shadow>? shadows,         
  }) {
    return TextStyle(
      fontFamily: 'ESRebondGrotesque',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,              
      shadows: shadows,            
    );
  }
}

