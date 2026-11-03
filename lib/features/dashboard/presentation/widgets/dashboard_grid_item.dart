import 'package:dazzleshrms/core/app_theme/glass_surface.dart';
import 'package:flutter/material.dart';
import 'fade_slide_item.dart';
import '../../../../core/app_theme/app_visuals.dart';

class DashboardGridItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final AnimationController animation;
  final double intervalStart;
  final ActionTone tone;

  const DashboardGridItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    required this.animation,
    required this.intervalStart,
    required this.tone,
  });

  DashboardGridItem withIntervalStart(double value) {
    return DashboardGridItem(
      key: key,
      icon: icon,
      label: label,
      onTap: onTap,
      animation: animation,
      intervalStart: value,
      tone: tone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppVisuals.of(context);
    return FadeSlideItem(
      animation: animation,
      intervalStart: intervalStart,
      child: GlassSurface(
        radius: 24,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.actionSurface(tone),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      icon,
                      size: 24,
                      color: colors.actionColor(tone),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
