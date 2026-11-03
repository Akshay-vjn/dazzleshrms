import 'package:dazzleshrms/core/app_theme/app_surface.dart';
import 'package:dazzleshrms/core/app_theme/app_visuals.dart';
import 'package:flutter/material.dart';

class LeaveFormSurface extends StatelessWidget {
  final double height;
  final Widget child;

  const LeaveFormSurface({
    super.key,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppVisuals.of(context);
    final border = BorderSide(
      color: colors.muted.withValues(alpha: .25),
      width: .5,
    );
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: border,
    );

    return AppSurface(
      height: height,
      sheet: true,
      child: DecoratedBox(
        decoration: colors.backdrop,
        child: Theme(
          data: theme.copyWith(
            inputDecorationTheme: theme.inputDecorationTheme.copyWith(
              fillColor: colors.inset,
              border: fieldBorder,
              enabledBorder: fieldBorder,
              focusedBorder: fieldBorder.copyWith(
                borderSide: BorderSide(color: colors.accent),
              ),
              hintStyle: TextStyle(color: colors.muted),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.accent,
                backgroundColor: colors.inset,
                side: border,
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
