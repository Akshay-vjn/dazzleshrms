import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import 'package:dazzleshrms/core/permissions/permission.dart';
import 'package:dazzleshrms/core/permissions/permission_provider.dart';
import '../../dashboard/presentation/widgets/fade_slide_item.dart';
import '../../dashboard/presentation/widgets/dashboard_grid.dart';
import '../../dashboard/presentation/widgets/dashboard_grid_item.dart';

class LeavesScreen extends ConsumerStatefulWidget {
  const LeavesScreen({super.key});

  @override
  ConsumerState<LeavesScreen> createState() => _LeavesScreenState();
}

class _LeavesScreenState extends ConsumerState<LeavesScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
        ),
      ),
      child: FadeSlideItem(
        animation: _controller,
        intervalStart: 0.0,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: theme.iconTheme.color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "Leaves",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(Set<String> permissions) {
    return DashboardGrid(
      animation: _controller,
      items: [
        if (permissions.contains(Permissions.viewApplyLeave))
          DashboardGridItem(
            icon: Icons.calendar_month_rounded,
            label: "Apply Leave",
            onTap: () => context.pushNamed('apply_leave'),
            animation: _controller,
            intervalStart: 0.15,
            gradientStart: AppTheme.gridGradient2Start,
            gradientEnd: AppTheme.gridGradient2End,
            iconColor: AppTheme.gridIconColor,
          ),
        if (permissions.contains(Permissions.viewUpcomingLeaves))
          DashboardGridItem(
            icon: Icons.upcoming,
            label: "Upcoming Leaves",
            onTap: () => context.pushNamed('upcoming_leaves'),
            animation: _controller,
            intervalStart: 0.2,
            gradientStart: AppTheme.gridGradient2Start,
            gradientEnd: AppTheme.gridGradient3End,
            iconColor: AppTheme.gridIconColor,
          ),
        if (permissions.contains(Permissions.viewApprovals))
          DashboardGridItem(
            icon: Icons.check_circle_outline_rounded,
            label: "Approvals",
            onTap: () => context.pushNamed('approvals'),
            animation: _controller,
            intervalStart: 0.25,
            gradientStart: AppTheme.gridGradient3Start,
            gradientEnd: AppTheme.gridGradient3End,
            iconColor: AppTheme.gridIconColor,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final permissionState = ref.watch(permissionProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildGrid(permissionState),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
