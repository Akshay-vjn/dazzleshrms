import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_visuals.dart';

class GlassSurface extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassSurface({
    super.key,
    required this.child,
    this.radius = 26,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppVisuals.of(context);
    final highContrast = MediaQuery.highContrastOf(context);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: colors.shadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.surface.withValues(
                    alpha: highContrast
                        ? .96
                        : colors.dark
                        ? .40
                        : .88,
                  ),
                  colors.surface.withValues(
                    alpha: highContrast
                        ? .96
                        : colors.dark
                        ? .24
                        : .74,
                  ),
                ],
              ),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                width: colors.dark ? 1 : 0.5,
                color: colors.dark
                    ? Colors.white.withValues(alpha: .12)
                    : colors.muted.withValues(alpha: .25),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
