import 'package:flutter/material.dart';
import 'dashboard_grid_item.dart';

class DashboardGrid extends StatelessWidget {
  final List<DashboardGridItem> items;
  final double? staggerStart;
  final double staggerStep;

  const DashboardGrid({
    super.key,
    required this.items,
    this.staggerStart,
    this.staggerStep = 0.05,
  });

  @override
  Widget build(BuildContext context) {
    final scaledFontSize = MediaQuery.textScalerOf(context).scale(13);
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            MediaQuery.sizeOf(context).width < 350 || scaledFontSize > 18
            ? 2
            : 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
        mainAxisExtent: 127 + (scaledFontSize - 13) * 4,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final staggerStart = this.staggerStart;
        if (staggerStart == null) return items[index];

        return items[index].withIntervalStart(
          staggeredGridInterval(
            visibleIndex: index,
            start: staggerStart,
            step: staggerStep,
          ),
        );
      },
    );
  }
}

double staggeredGridInterval({
  required int visibleIndex,
  required double start,
  required double step,
}) {
  assert(visibleIndex >= 0);
  assert(start >= 0 && start <= 1);
  assert(step >= 0);

  // FadeSlideItem animates for 20% of the controller duration, so keep enough
  // room for the final visible item to complete its transition.
  return (start + (visibleIndex * step)).clamp(0.0, 0.8).toDouble();
}
