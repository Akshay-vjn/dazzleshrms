import 'package:flutter/material.dart';
import 'fade_slide_item.dart';

class DashboardGridItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final AnimationController animation;
  final double intervalStart;
  final Color gradientStart;
  final Color gradientEnd;
  final Color? iconColor;
  final bool enabled; // 🔥 NEW

  const DashboardGridItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    required this.animation,
    required this.intervalStart,
    required this.gradientStart,
    required this.gradientEnd,
    this.iconColor,
    this.enabled = true, // 🔥 DEFAULT ENABLED
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeSlideItem(
      animation: animation,
      intervalStart: intervalStart,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4, // 🔥 VISUAL DISABLE
        child: GestureDetector(
          onTap: enabled ? onTap : null, // 🔥 BLOCK TAP
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [gradientStart, gradientEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(1.6),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF020617)
                            : Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -30,
                            left: -50,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: gradientStart.withOpacity(0.18),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -35,
                            right: -50,
                            child: Container(
                              width: 95,
                              height: 85,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: gradientEnd.withOpacity(0.16),
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (iconColor ?? Colors.white)
                                    .withOpacity(0.10),
                              ),
                            ),
                          ),
                          Center(
                            child: Icon(
                              icon,
                              color: iconColor,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
