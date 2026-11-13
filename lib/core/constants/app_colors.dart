import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette
  static const Color primary = Color(0xFF5B50E5);
  static const Color primaryLight = Color(0xFF7F76F0);
  static const Color primaryDark = Color(0xFF3F35C7);
  static const Color accent = Color(0xFF6C63FF);

  // Backgrounds & Surface
  static const Color background = Color(0xFFF7F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E202B);
  static const Color textSecondary = Color(0xFF7E8494);
  static const Color textMuted = Color(0xFFA5ABC0);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Priority Colors
  static const Color priorityHigh = Color(0xFFFF5252);
  static const Color priorityHighBg = Color(0xFFFFEBEE);
  
  static const Color priorityMedium = Color(0xFFFF9800);
  static const Color priorityMediumBg = Color(0xFFFFF3E0);
  
  static const Color priorityLow = Color(0xFF00C853);
  static const Color priorityLowBg = Color(0xFFE8F5E9);

  // Status & State
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF29B6F6);

  // Borders & Dividers
  static const Color border = Color(0xFFE4E7F0);
  static const Color divider = Color(0xFFEEF0F6);

  // Shadow
  static Color shadow = const Color(0xFF1E202B).withValues(alpha: 0.06);
  static Color shadowHeavy = const Color(0xFF5B50E5).withValues(alpha: 0.25);
}
