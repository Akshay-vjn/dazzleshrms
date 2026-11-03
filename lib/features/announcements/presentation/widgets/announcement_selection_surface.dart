import 'dart:math' as math;

import 'package:dazzleshrms/core/app_theme/app_surface.dart';
import 'package:dazzleshrms/core/app_theme/app_visuals.dart';
import 'package:flutter/material.dart';

class AnnouncementSelectionSurface extends StatelessWidget {
  final Widget child;
  final double heightFraction;

  const AnnouncementSelectionSurface({
    super.key,
    required this.child,
    this.heightFraction = .7,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppVisuals.of(context);
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final border = BorderSide(
      color: colors.muted.withValues(alpha: .25),
      width: .5,
    );
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: border,
    );

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: AppSurface(
        sheet: true,
        height: math.min(
          media.size.height * heightFraction,
          math.max(
            0,
            media.size.height - media.viewInsets.bottom - media.padding.top,
          ),
        ),
        child: DecoratedBox(
          decoration: colors.backdrop,
          child: Theme(
            data: theme.copyWith(
              inputDecorationTheme: theme.inputDecorationTheme.copyWith(
                fillColor: colors.inset,
                enabledBorder: fieldBorder,
                border: fieldBorder,
                focusedBorder: fieldBorder.copyWith(
                  borderSide: BorderSide(color: colors.accent),
                ),
              ),
              listTileTheme: theme.listTileTheme.copyWith(
                selectedColor: colors.accent,
                selectedTileColor: colors.accentSurface,
              ),
              checkboxTheme: theme.checkboxTheme.copyWith(
                side: BorderSide(color: colors.muted, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.muted.withValues(alpha: .4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
