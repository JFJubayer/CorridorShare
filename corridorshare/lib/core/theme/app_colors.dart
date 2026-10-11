import 'package:flutter/material.dart';

/// Centralised color tokens for the app.
///
/// Material 3 derives the rest of the color scheme from [seedColor] inside
/// [app_theme.dart]. These tokens are for places that need an exact value
/// (status pills, illustration accents, etc.).
class AppColors {
  const AppColors._();

  static const Color brand = Color(0xFF0F6E5C);
  static const Color brandDark = Color(0xFF0A5346);
  static const Color accent = Color(0xFFE8A33D);
  static const Color success = Color(0xFF1B7F4D);
  static const Color warning = Color(0xFFC97A0E);
  static const Color danger = Color(0xFFB3261E);
  static const Color surfaceMuted = Color(0xFFF1F4F2);
  static const Color outline = Color(0xFFCAD2CF);
}
