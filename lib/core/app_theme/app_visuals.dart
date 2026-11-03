import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppVisuals {
  final bool dark;
  const AppVisuals(this.dark);
  factory AppVisuals.of(BuildContext context) =>
      AppVisuals(Theme.of(context).brightness == Brightness.dark);
  Color get background => dark ? AppColors.bgDark : AppColors.bgLight;
  Color get surface => dark ? AppColors.surfaceDark : AppColors.canvasLight;
  Color get inset => dark
      ? AppColors.surfaceDarkVariant.withValues(alpha: .30)
      : AppColors.insetLight;
  Color get text => dark ? AppColors.textBodyDark : AppColors.textPrimaryLight;
  Color get muted => dark ? AppColors.textMutedDark : AppColors.textMutedLight;
  Color get border => dark ? AppColors.borderDark : AppColors.borderLight;
  Color get accent => dark ? AppColors.primary : AppColors.primaryOnLight;
  Color get accentSurface =>
      dark ? AppColors.accentSurfaceDark : AppColors.accentSurfaceLight;
  Color get green => dark ? AppColors.successDark : AppColors.successLight;
  Color get red => dark ? AppColors.errorDark : AppColors.errorLight;

  Color actionColor(ActionTone tone) => dark ? tone.darkColor : tone.lightColor;
  Color actionSurface(ActionTone tone) =>
      dark ? tone.darkSurface : tone.lightSurface;

  List<BoxShadow> get shadows => [
    BoxShadow(
      color: Colors.black.withValues(alpha: dark ? .10 : .035),
      blurRadius: 24,
      offset: const Offset(0, 6),
    ),
  ];
  BoxDecoration panel({Color? backgroundColor}) => BoxDecoration(
    color: backgroundColor,
    gradient: backgroundColor != null
        ? null
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              surface.withValues(alpha: dark ? .38 : .96),
              surface.withValues(alpha: dark ? .24 : .90),
            ],
          ),
    borderRadius: BorderRadius.circular(26),
    border: Border.all(color: border),
    boxShadow: shadows,
  );

  BoxDecoration get sheet => BoxDecoration(
    color: surface,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
  );

  BoxDecoration get insetPanel => BoxDecoration(
    color: inset,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: border),
  );
  BoxDecoration get backdrop => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: dark
          ? [
              const Color(0xFF431C14),
              background,
              background,
              const Color(0xFF2D1510),
            ]
          : [
              const Color(0xFFF9DCD3),
              background,
              background,
              const Color(0xFFF9DFD7),
            ],
      stops: const [0, .35, .72, 1],
    ),
  );
}

enum ActionTone {
  blue(
    Color(0xFF216DE1),
    Color(0xFF79ACFF),
    Color(0xFFEDF2FF),
    Color(0xFF242F45),
  ),
  teal(
    Color(0xFF008A80),
    Color(0xFF16D5C5),
    Color(0xFFE6F5F2),
    Color(0xFF193A37),
  ),
  purple(
    Color(0xFF7944D5),
    Color(0xFFC09AFF),
    Color(0xFFF2EBFF),
    Color(0xFF382A49),
  ),
  orange(
    Color(0xFFD85800),
    Color(0xFFFFA461),
    Color(0xFFFFEEDF),
    Color(0xFF492D1D),
  ),
  pink(
    Color(0xFFCB2275),
    Color(0xFFFF83BA),
    Color(0xFFFFEAF1),
    Color(0xFF472331),
  ),
  green(
    Color(0xFF008447),
    Color(0xFF00D98B),
    Color(0xFFE6F6ED),
    Color(0xFF193C2B),
  );

  const ActionTone(
    this.lightColor,
    this.darkColor,
    this.lightSurface,
    this.darkSurface,
  );

  final Color lightColor;
  final Color darkColor;
  final Color lightSurface;
  final Color darkSurface;
}
