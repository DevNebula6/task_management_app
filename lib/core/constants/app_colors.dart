import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Indigo / Violet Modern Palette
  static const Color primary = Color(0xFF4F46E5); // Modern Vibrant Indigo
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color primaryLighter = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color accent = Color(0xFF7C3AED); // Electric Violet

  // Gradients
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4338CA),
      Color(0xFF4F46E5),
      Color(0xFF6366F1),
    ],
  );

  static const LinearGradient fabGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6366F1),
      Color(0xFF4F46E5),
      Color(0xFF4338CA),
    ],
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFBFBFE),
    ],
  );

  // Backgrounds & Surface
  static const Color background = Color(0xFFF8FAFC); // Slate-50 off-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color chipBg = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate-900 high contrast
  static const Color textSecondary = Color(0xFF64748B); // Slate-500
  static const Color textMuted = Color(0xFF94A3B8); // Slate-400
  static const Color textWhite = Color(0xFFFFFFFF);

  // Priority Colors (Modern Tailored Badges)
  static const Color priorityHigh = Color(0xFFEF4444); // Red-500
  static const Color priorityHighBg = Color(0xFFFEF2F2); // Red-50
  static const Color priorityHighBorder = Color(0xFFFECACA);

  static const Color priorityMedium = Color(0xFFF59E0B); // Amber-500
  static const Color priorityMediumBg = Color(0xFFFFFBEB); // Amber-50
  static const Color priorityMediumBorder = Color(0xFFFDE68A);

  static const Color priorityLow = Color(0xFF10B981); // Emerald-500
  static const Color priorityLowBg = Color(0xFFECFDF5); // Emerald-50
  static const Color priorityLowBorder = Color(0xFFA7F3D0);

  // Status & Utility
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF06B6D4);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0); // Slate-200
  static const Color borderSubtle = Color(0xFFF1F5F9); // Slate-100
  static const Color divider = Color(0xFFF1F5F9);

  // Modern Shadows
  static Color shadow = const Color(0xFF0F172A).withValues(alpha: 0.04);
  static Color shadowMedium = const Color(0xFF0F172A).withValues(alpha: 0.08);
  static Color shadowHeavy = const Color(0xFF4F46E5).withValues(alpha: 0.28);
}
