import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_theme_data.dart';

abstract final class AppTheme {
  static final ThemeData lightTheme = buildAppTheme(Brightness.light);
  static final ThemeData darkTheme = buildAppTheme(Brightness.dark);

  static const Color PrimaryColor = AppColors.primary;
  static const Color primaryOnLight = AppColors.primaryOnLight;
  static const Color surfaceLight = AppColors.surfaceLight;
  static const Color surfaceDark = AppColors.surfaceDark;
  static const Color surfaceBlack = AppColors.surfaceBlack;
  static const Color textPrimaryLight = AppColors.textPrimaryLight;
  static const Color textBodyLight = AppColors.textBodyLight;
  static const Color textMutedLight = AppColors.textMutedLight;
  static const Color textPrimaryDark = AppColors.textPrimaryDark;
  static const Color textMutedDark = AppColors.textMutedDark;
  static const Color dGreen = AppColors.dGreen;
  static const Color statusSuccess = AppColors.statusSuccess;
  static const Color statusError = AppColors.statusError;
  static const Color statusWarning = AppColors.statusWarning;
  static const Color statusInfo = AppColors.statusInfo;
  static const Color iconPrimary = AppColors.iconPrimary;
  static const Color navIconInactiveLight = AppColors.navIconInactiveLight;
  static const Color navIconInactiveDark = AppColors.navIconInactiveDark;

  static Color accent(bool isDark) =>
      isDark ? AppColors.primary : AppColors.primaryOnLight;
}
