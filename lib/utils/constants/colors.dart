import 'package:flutter/material.dart';

class TColors {
  // Brand palette (more colorful)
  static const Color primary = Color(0xFF6C63FF);     // Vibrant violet
  static const Color secondary = Color(0xFF00BFA6);   // Teal accent
  static const Color accent = Color(0xFFFF8A65);      // Warm coral

  // Text colors
  static const Color textPrimary = Color(0xFF1F2937);   // Slate 800
  static const Color textSecondary = Color(0xFF5B6B7A); // Muted slate
  static const Color textWhite = Colors.white;

  // Background colors
  static const Color light = Color(0xFFF7F8FC);
  static const Color dark = Color(0xFF111827);
  static const Color primaryBackground = Color(0xFFEDEBFF); // subtle violet tint

  // Background Container colors
  static const Color lightContainer = Color(0xFFF6F6F6);
  static Color darkContainer = TColors.white.withOpacity(0.1);

  // Button colors
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = secondary;
  static const Color buttonDisabled = Color(0xFFC4C4C4);

  // Border colors
  static const Color borderPrimary = Color(0xFFE5E7EB);
  static const Color borderSecondary = Color(0xFFF1F5F9);

  // Error and validation colors
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF1E88E5);

  // Neutral Shades
  static const Color black = Color(0xFF0B0F14);
  static const Color darkerGrey = Color(0xFF374151);
  static const Color darkGrey = Color(0xFF9CA3AF);
  static const Color grey = Color(0xFFE5E7EB);
  static const Color softGrey = Color(0xFFF3F4F6);
  static const Color lightGrey = Color(0xFFF9FAFB);
  static const Color white = Color(0xFFFFFFFF);
}
