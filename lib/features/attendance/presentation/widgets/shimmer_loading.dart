import 'package:dazzleshrms/core/app_theme/app_visuals.dart';
import 'package:dazzleshrms/core/app_theme/glass_surface.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class AttendanceShimmerItem extends StatelessWidget {
  const AttendanceShimmerItem({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppVisuals.of(context);
    final baseColor = colors.muted.withValues(alpha: colors.dark ? .24 : .16);

    return GlassSurface(
      child: Shimmer(
        duration: const Duration(seconds: 2),
        interval: const Duration(milliseconds: 500),
        color: colors.accent,
        colorOpacity: colors.dark ? .12 : .08,
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: baseColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _shimmerBox(width: 120, height: 16, color: baseColor),
                  ],
                ),
              ),
              _shimmerBox(width: 80, height: 12, color: baseColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    required Color color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
