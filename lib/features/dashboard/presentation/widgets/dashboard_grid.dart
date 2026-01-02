import 'package:flutter/material.dart';
import 'dashboard_grid_item.dart';

class DashboardGrid extends StatelessWidget {
  final AnimationController animation;
  final List<DashboardGridItem> items;

  const DashboardGrid({
    super.key,
    required this.animation,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 🔥 3 grids per row
        crossAxisSpacing: 20,
        mainAxisSpacing: 5,
        childAspectRatio: 0.85, // 🔥 Adjusted for 3-column layout
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }
}
