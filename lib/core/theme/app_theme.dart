import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimens.dart';

class AppTheme {
  static ThemeData get light => _getAppTheme(Brightness.light);
  static ThemeData get dark => _getAppTheme(Brightness.dark);

  static ThemeData _getAppTheme(Brightness b) {
    final isLight = b == Brightness.light;

    final background = isLight ? LightColors.background : DarkColors.background;
    final surface = isLight ? LightColors.surface : DarkColors.surface;
    final card = isLight ? LightColors.card : DarkColors.card;
    final surfaceAlt = isLight ? LightColors.surfaceAlt : DarkColors.surfaceAlt;
    final textPrimary = isLight ? LightColors.textPrimary : DarkColors.textPrimary;
    final textSecondary = isLight ? LightColors.textSecondary : DarkColors.textSecondary;
    final border = isLight ? LightColors.border : DarkColors.border;
    final error = isLight ? LightColors.error : DarkColors.error;

    final scheme = ColorScheme(brightness: b, primary: BrandColors.primary, onPrimary: Colors.white, secondary: BrandColors.accentMint, onSecondary: Colors.black, surface: surface, onSurface: textPrimary, error: error, onError: Colors.white);

    final textTheme = _textTheme(textPrimary, textSecondary, isLight);

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      dividerColor: border,
      appBarTheme: AppBarTheme(backgroundColor: background, foregroundColor: textPrimary, elevation: 0, centerTitle: false, titleTextStyle: textTheme.titleLarge),
      cardTheme: CardThemeData(
        color: card,
        elevation: 1.5,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BrandColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: BrandColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: error),
        ),
      ),
      switchTheme: SwitchThemeData(thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : null), trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? BrandColors.primary : (isLight ? LightColors.border : DarkColors.border))),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: BrandColors.primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: BrandColors.primary, foregroundColor: Colors.white),
      dividerTheme: DividerThemeData(color: isLight ? LightColors.divider : DarkColors.divider, thickness: 1, space: 0),
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary, bool isLight) {
    return TextTheme(
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: primary),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: primary),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
      bodyLarge: TextStyle(fontSize: 15, color: primary),
      bodyMedium: TextStyle(fontSize: 14, color: isLight ? LightColors.grey : DarkColors.grey),
      bodySmall: TextStyle(fontSize: 12, color: isLight ? LightColors.grey : DarkColors.grey),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
    );
  }
}
