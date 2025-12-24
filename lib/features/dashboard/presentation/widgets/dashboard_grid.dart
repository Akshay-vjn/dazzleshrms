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
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 12,
      childAspectRatio: 0.75,
      children: items,
    );
  }
}
