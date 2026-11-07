import 'package:flutter/material.dart';

/// Single source of truth for colour.
///
/// The brand palette sits deliberately outside the red/amber/green of the report
/// status scale, so a brand element can never be read as a status.
class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF2A5C6B);
  static const Color primaryDark = Color(0xFF1B3F4A);
  static const Color accent = Color(0xFFC75B39);
  static const Color background = Color(0xFFF5F7F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8EA);

  static const Color ink = Color(0xFF0E1A1F);
  static const Color muted = Color(0xFF6B7C84);

  static const Color danger = Color(0xFFB3392E);

  // Report status
  static const Color submittedFg = Color(0xFFA9701A);
  static const Color submittedBg = Color(0xFFFCF1DC);
  static const Color inProgressFg = Color(0xFF2A4BC4);
  static const Color inProgressBg = Color(0xFFE6ECFD);
  static const Color resolvedFg = Color(0xFF0F7A3D);
  static const Color resolvedBg = Color(0xFFE4F5EA);

  // Report category
  static const Color facilitiesFg = Color(0xFF2A5C6B);
  static const Color facilitiesBg = Color(0xFFE4EEF1);
  static const Color waterFg = Color(0xFF0E6E8C);
  static const Color waterBg = Color(0xFFE1F1F6);
  static const Color electricityFg = Color(0xFFA9701A);
  static const Color electricityBg = Color(0xFFFCF1DC);
  static const Color safetyFg = Color(0xFFB3392E);
  static const Color safetyBg = Color(0xFFFBE8E5);
  static const Color sanitationFg = Color(0xFF2C7A6F);
  static const Color sanitationBg = Color(0xFFE1F2EF);
}
