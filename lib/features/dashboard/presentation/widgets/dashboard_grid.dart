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
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 4,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }
}
