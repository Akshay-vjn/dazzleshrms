import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_visuals.dart';

ThemeData buildAppTheme(Brightness brightness) {
  final colors = AppVisuals(brightness == Brightness.dark);
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16),
      bodySmall: TextStyle(fontSize: 12),
    ),
  );
  final text = base.textTheme.apply(
    fontFamily: 'Outfit',
    bodyColor: colors.text,
    displayColor: colors.text,
  );
  final scheme = base.colorScheme.copyWith(
    primary: colors.accent,
    onPrimary: colors.dark ? colors.background : Colors.white,
    primaryContainer: colors.accentSurface,
    onPrimaryContainer: colors.accent,
    secondary: colors.accent,
    surface: colors.surface,
    onSurface: colors.text,
    onSurfaceVariant: colors.muted,
    outlineVariant: colors.border,
    surfaceContainer: colors.inset,
    surfaceContainerHigh: colors.inset,
    surfaceContainerHighest: colors.inset,
    surfaceContainerLow: colors.surface,
    surfaceContainerLowest: colors.background,
  );
  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.background,
    cardColor: colors.surface,
    dividerColor: colors.border,
    hintColor: colors.muted,
    textTheme: text,
    iconTheme: IconThemeData(color: colors.dark ? colors.muted : colors.text),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: colors.dark ? colors.muted : colors.text,
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      iconTheme: IconThemeData(
        color: colors.dark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight,
      ),
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
      foregroundColor: colors.text,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    ),
    cardTheme: CardThemeData(
      color: colors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: BorderSide(color: colors.border),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.accent,
        foregroundColor: scheme.onPrimary,
        overlayColor: Colors.black,
        disabledBackgroundColor: colors.text.withValues(alpha: .12),
        disabledForegroundColor: colors.muted,
        minimumSize: const Size(0, 48),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.accent,
        foregroundColor: scheme.onPrimary,
        disabledBackgroundColor: colors.text.withValues(alpha: .12),
        disabledForegroundColor: colors.muted,
        minimumSize: const Size(0, 48),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.accent,
        minimumSize: const Size(0, 48),
        side: BorderSide(color: colors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.accent,
      foregroundColor: scheme.onPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: colors.accent,
      unselectedLabelColor: colors.muted,
      labelStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      unselectedLabelStyle: text.labelLarge,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        color: colors.accentSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      indicatorColor: Colors.transparent,
      dividerColor: Colors.transparent,
      indicatorAnimation: TabIndicatorAnimation.linear,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: colors.accent,
      textColor: colors.text,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: colors.accent),
    ),
    inputDecorationTheme: _inputTheme(colors),
  );
}

InputDecorationTheme _inputTheme(AppVisuals colors) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide.none,
  );
  final iconColor = colors.dark
      ? AppColors.textMutedDark
      : AppColors.textMutedLight;
  return InputDecorationTheme(
    filled: true,
    fillColor: colors.inset,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: BorderSide(color: colors.accent, width: 1.5),
    ),
    labelStyle: TextStyle(color: colors.muted),
    prefixIconColor: iconColor,
    suffixIconColor: iconColor,
  );
}
