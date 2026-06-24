import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ---------------------------------------------------------------------------
/// COLORS — diambil langsung dari design tokens di Stitch
/// ---------------------------------------------------------------------------
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0F6E6E); // teal
  static const Color secondary = Color(0xFFFF7A50); // orange
  static const Color tertiary = Color(0xFFDFF4F2); // mint / light teal
  static const Color neutral = Color(0xFF5C6B73); // slate gray

  // Variasi turunan (tint/shade) — dipakai untuk state hover/disabled/border
  static const Color primaryDark = Color(0xFF0A4F4F);
  static const Color primaryLight = Color(0xFF4FA8A8);

  static const Color secondaryDark = Color(0xFFCC5A33);
  static const Color secondaryLight = Color(0xFFFFB199);

  static const Color surface = Colors.white;
  static const Color background = Color(0xFFF7FAFA);

  static const Color textPrimary = Color(0xFF1A2627);
  static const Color textSecondary = neutral;
  static const Color border = Color(0xFFD9E4E3);
  static const Color danger = Color(0xFFE74C3C);
}

/// ---------------------------------------------------------------------------
/// TYPOGRAPHY — font: Plus Jakarta Sans
/// Sesuai kategori di Stitch: Headline / Body / Label
/// ---------------------------------------------------------------------------
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.plusJakartaSans();

  // Headline — besar, bold (sesuai contoh "Aa" besar di card Headline)
  static TextStyle headlineLarge = _base.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle headlineMedium = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  // Body
  static TextStyle bodyLarge = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Label — dipakai di button, chip, badge
  static TextStyle label = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );
}

/// ---------------------------------------------------------------------------
/// BUTTON STYLES — sesuai variant di Stitch: Primary / Secondary / Inverted / Outlined
/// ThemeData hanya bisa pegang 1 default style, jadi sisanya disediakan sebagai
/// ButtonStyle siap pakai → AppButtonStyles.secondary, dst.
/// ---------------------------------------------------------------------------
class AppButtonStyles {
  AppButtonStyles._();

  static ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    textStyle: AppTextStyles.label.copyWith(color: Colors.white),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 0,
  );

  static ButtonStyle secondary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.tertiary,
    foregroundColor: AppColors.textPrimary,
    textStyle: AppTextStyles.label,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 0,
  );

  static ButtonStyle inverted = ElevatedButton.styleFrom(
    backgroundColor: AppColors.textPrimary,
    foregroundColor: Colors.white,
    textStyle: AppTextStyles.label.copyWith(color: Colors.white),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 0,
  );

  static ButtonStyle outlined = OutlinedButton.styleFrom(
    foregroundColor: AppColors.textPrimary,
    textStyle: AppTextStyles.label,
    side: const BorderSide(color: AppColors.border, width: 1.2),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  // Khusus tombol "Label" kecil berwarna teal solid (lihat card Label di Stitch)
  static ButtonStyle labelTag = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    textStyle: AppTextStyles.label.copyWith(color: Colors.white, fontSize: 13),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 0,
  );
}

/// ---------------------------------------------------------------------------
/// MAIN THEME
/// ---------------------------------------------------------------------------
class AppTheme {
  AppTheme._();

  static ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.danger,
      brightness: Brightness.light,
    ),

    textTheme: TextTheme(
      headlineLarge: AppTextStyles.headlineLarge,
      headlineMedium: AppTextStyles.headlineMedium,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      labelLarge: AppTextStyles.label,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: false,
      foregroundColor: AppColors.textPrimary,
      titleTextStyle: AppTextStyles.headlineMedium,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(style: AppButtonStyles.primary),
    outlinedButtonTheme: OutlinedButtonThemeData(style: AppButtonStyles.outlined),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTextStyles.label,
      ),
    ),

    // Search bar (sesuai card "Search" di Stitch)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.tertiary.withOpacity(0.5),
      hintStyle: AppTextStyles.bodyMedium,
      prefixIconColor: AppColors.neutral,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),

    // Bottom nav (ikon Home / Search / Profile di card Stitch)
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.neutral,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.tertiary,
      labelStyle: AppTextStyles.label,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
    ),
  );
}