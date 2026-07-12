import 'package:flutter/material.dart';

/// Brand-fixed colors (same across light & dark).
class BrandColors {
  static const primary = Color(0xFF0C9084); // FieldTrack teal
  static const primaryDark = Color(0xFF0A7A70); // pressed/hover
  static const accentMint = Color(0xFF2AD2BA); // radar ping / highlight
}

/// Light theme palette.
class LightColors {
  static const background = Color(0xFFF4F6F8);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF1F5F9); // input fill, subtle panels
  static const textPrimary = Color(0xFF131A24);
  // static const textSecondary = Color(0xFF64748B);
  static const textSecondary = Color(0xFF98A2B2);
  static const grey = Color(0xFF5C6675);
  static const border = Color(0xFFE2E8F0);
  static const success = Color(0xFF15A05A);
  static const warning = Color(0xFFD9920A);
  static const error = Color(0xFFE11D48);
  static const divider = Color(0xffEFF2F5);
  static const card = Color(0xFFFFFFFF);
  static const selectedCard = Color(0xFFF1F4F7);
}

/// Dark theme palette.
class DarkColors {
  static const background = Color(0xFF0E1521);
  static const surface = Color(0xFF1C2838);
  static const surfaceAlt = Color(0xFF162130);
  static const textPrimary = Color(0xFFEEF2F7);
  // static const textSecondary = Color(0xFF94A3B8);
  static const textSecondary = Color(0xFF5E6B7E);
  static const grey = Color(0xFF98A4B4);
  static const border = Color(0xFF2A3A4F);
  static const success = Color(0xFF34C77B);
  static const warning = Color(0xFFE0A93B);
  static const error = Color(0xFFFB7185);
  static const divider = Color(0xff283446);
  static const card = Color(0xFF18212F);
  static const selectedCard = Color(0xFF1F2A3A);
}
