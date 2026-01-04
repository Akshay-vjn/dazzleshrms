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
  final bool enabled;

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
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeSlideItem(
      animation: animation,
      intervalStart: intervalStart,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.4,
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [gradientStart, gradientEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(1.4),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF020617)
                            : Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(16.6),
                      ),
                      child: Stack(
                        children: [
                          // Positioned(
                          //   top: -25,
                          //   left: -40,
                          //   child: Container(
                          //     width: 95,
                          //     height: 75,
                          //     decoration: BoxDecoration(
                          //       shape: BoxShape.circle,
                          //       color: gradientStart.withOpacity(0.18),
                          //     ),
                          //   ),
                          // ),
                          // Positioned(
                          //   bottom: -30,
                          //   right: -40,
                          //   child: Container(
                          //     width: 95,
                          //     height: 75,
                          //     decoration: BoxDecoration(
                          //       shape: BoxShape.circle,
                          //       color: gradientEnd.withOpacity(0.16),
                          //     ),
                          //   ),
                          // ),
                          Center(
                            child: Container(
                              width: 60,
                              height: 60,
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
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              SizedBox(
                height: 34,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}