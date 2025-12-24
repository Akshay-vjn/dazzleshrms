import 'package:flutter/material.dart';

class FadeSlideItem extends StatelessWidget {
  final AnimationController animation;
  final double intervalStart;
  final Widget child;

  const FadeSlideItem({
    super.key,
    required this.animation,
    required this.intervalStart,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final intervalEnd = (intervalStart + 0.2).clamp(0.0, 1.0);
        final curve = CurvedAnimation(
          parent: animation,
          curve: Interval(intervalStart, intervalEnd, curve: Curves.easeOut),
        );

        return FadeTransition(
          opacity: curve,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(curve),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
