import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
   // BRAND
  static const Color PrimaryColor = Color(0xFFE3ADA6);
  static const Color SecondaryColor = Color(0xFF8B5CF6);

  /* ============================================================
   * BACKGROUNDS
   * ========================================================== */
  static const Color bgLight = Color(0xFFFAFAFA);
  static const Color bgDark = Color(0xFF1E1E1E);

  /* ============================================================
   * SURFACES (cards, sheets, containers)
   * ========================================================== */
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2C2C2C);
  static const Color surfaceDarkVariant = Color(0xFF1E293B);

  static const Color surfaceCardLight = surfaceLight;
  static const Color surfaceCardDark = surfaceDark;

  /* ============================================================
   * TEXT COLORS
   * ========================================================== */
  // Light
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF1E293B);
  static const Color textBodyLight = Color(0xFF334155);
  static const Color textMutedLight = Color(0xFF64748B);

  // Dark
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textBodyDark = Color(0xFFF1F5F9);
  static const Color textMutedDark = Color(0xFFCBD5E1);

  /* ============================================================
   * BORDERS & DIVIDERS
   * ========================================================== */
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);



  // ================== GRADIENT COLORS ==================

// 🔹 Dashboard / Grid gradients
  static const Color gridGradient1Start = Color(0xFF4F46E5); // Indigo
  static const Color gridGradient1End   = Color(0xFF22D3EE); // Cyan

  static const Color gridGradient2Start = Color(0xFFEC4899); // Pink
  static const Color gridGradient2End   = Color(0xFFF59E0B); // Amber

  static const Color gridGradient3Start = Color(0xFF7C3AED); // Purple
  static const Color gridGradient3End   = Color(0xFFA855F7); // Light Purple


  static const Color gridIconColor= Color(0xFFECFEFF);

  /* ============================================================
   * STATUS COLORS (VERY IMPORTANT)
   * ========================================================== */
  static const Color statusSuccess = Color(0xFF16A34A); // Present / Approved
  static const Color statusError = Color(0xFFDC2626);   // Absent / Rejected
  static const Color statusWarning = Color(0xFFF59E0B); // Pending / Half day
  static const Color statusInfo = Color(0xFF2563EB);    // Info states

  /* ============================================================
   * ICONS
   * ========================================================== */
  static const Color iconPrimary = PrimaryColor;
  static const Color iconBgLight = Color(0xFF94A3B8);
  static const Color iconBgDark = Color(0xFFCBD5E1);
  static const Color iconColor = Color(0xFF000307);


  /* ============================================================
   * SHADOWS
   * ========================================================== */
  static const Color shadowLight = Color(0xFF000000);
  static const Color shadowDark = Color(0xFF000000);

  /* ============================================================
   * BOTTOM NAVIGATION
   * ========================================================== */
  static const Color navBackgroundLight = surfaceLight;
  static const Color navBackgroundDark = surfaceDark;

  static const Color navIconSelected = PrimaryColor;
  static const Color navIconInactiveLight = textMutedLight;
  static const Color navIconInactiveDark = textMutedDark;

  /* ============================================================
   * UTILS
   * ========================================================== */
  static const Color transparent = Color(0x00000000);

  /* ============================================================
   * LIGHT THEME
   * ========================================================== */
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: bgLight,
    inputDecorationTheme: inputTheme(Brightness.light),

    colorScheme: ColorScheme.fromSeed(
      seedColor: PrimaryColor,
      brightness: Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
      ),
      iconTheme: const IconThemeData(color: textPrimaryLight),
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimaryLight,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textSecondaryLight,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16,
        color: textBodyLight,
      ),
      bodySmall: GoogleFonts.outfit(
        fontSize: 12,
        color: textMutedLight,
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceCardLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  /* ============================================================
   * DARK THEME
   * ========================================================== */
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    inputDecorationTheme: inputTheme(Brightness.dark),

    colorScheme: ColorScheme.fromSeed(
      seedColor: PrimaryColor,
      brightness: Brightness.dark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
      ),
      iconTheme: const IconThemeData(color: textPrimaryDark),
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimaryDark,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16,
        color: textBodyDark,
      ),
      bodySmall: GoogleFonts.outfit(
        fontSize: 12,
        color: textMutedDark,
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceCardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );


  static InputDecorationTheme inputTheme(Brightness brightness) {
    return InputDecorationTheme(
      filled: true,
      fillColor: brightness == Brightness.dark
          ? surfaceDarkVariant
          : surfaceLight,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),

      // No border by default
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),

      // 🔥 Brand color only on focus (PREVIOUS BEHAVIOR)
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: PrimaryColor,
          width: 2,
        ),
      ),

      labelStyle: TextStyle(
        color: brightness == Brightness.dark
            ? textMutedDark
            : textMutedLight,
      ),

      prefixIconColor: brightness == Brightness.dark
          ? iconBgDark
          : iconBgLight,

      suffixIconColor: brightness == Brightness.dark
          ? iconBgDark
          : iconBgLight,
    );
  }

}
