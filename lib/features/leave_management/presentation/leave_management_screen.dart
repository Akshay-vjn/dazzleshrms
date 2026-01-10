import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import 'package:dazzleshrms/core/permissions/permission.dart';
import 'package:dazzleshrms/core/permissions/permission_provider.dart';
import '../../dashboard/data/providers/dashboard_provider.dart';
import '../../dashboard/data/models/dashboard_response.dart';
import '../../dashboard/presentation/widgets/fade_slide_item.dart';
import '../../dashboard/presentation/widgets/dashboard_grid.dart';
import '../../dashboard/presentation/widgets/dashboard_grid_item.dart';
import '../../leave/data/providers/leave_provider.dart';

class LeaveManagementScreen extends ConsumerStatefulWidget {
  const LeaveManagementScreen({super.key});

  @override
  ConsumerState<LeaveManagementScreen> createState() =>
      _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends ConsumerState<LeaveManagementScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  void _showUsedLeavesDialog() {
    // Invalidate the provider to force a fresh fetch when dialog opens
    ref.invalidate(usedLeavesProvider);
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 400),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Used Leaves",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final state = ref.watch(usedLeavesProvider);
                    return state.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (e, _) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Error: ${e.toString()}",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () {
                                ref.invalidate(usedLeavesProvider);
                              },
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      ),
                      data: (data) {
                        if (data.records.isEmpty) {
                          return Center(
                            child: Text(
                              "No used leaves found",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).hintColor,
                                  ),
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: data.records.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = data.records[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                item.leaveType,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(item.date),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.statusError.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${formatLeave(item.daysTaken)} Day${item.daysTaken > 1 ? 's' : ''}",
                                  style: const TextStyle(
                                    color: AppTheme.statusError,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Extended slightly
    );

    // Delay animation to allow screen transition to finish
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

  String formatLeave(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.15),
          ),
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
              "Leave Management",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(ThemeData theme, DashboardData data) {
    final isDark = theme.brightness == Brightness.dark;
    final cardGradientStart =
        isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A);
    final cardGradientEnd =
        isDark ? const Color(0xFF334155) : const Color(0xFF1E293B);
    final statBg = Colors.white.withValues(alpha: 0.15);

    return FadeSlideItem(
      animation: _controller,
      intervalStart: 0.1,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cardGradientStart, cardGradientEnd],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              "Leave Balance",
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _leaveStatCard("Total", data.totalLeaves, statBg),
                _leaveStatCard(
                  "Used",
                  data.usedLeaves,
                  statBg,
                  onTap: () => _showUsedLeavesDialog(),
                ),
                _leaveStatCard("Available", data.availableLeaves, statBg),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _leaveStatCard(
      String label,
      double value,
      Color bg, {
        VoidCallback? onTap,
      }) {
    return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(

        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),

        child: Column(
          children: [
            Text(
              formatLeave(value),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    )
    );
  }

  Widget _buildGrid(Set<String> permissions) {
    return DashboardGrid(
      animation: _controller,
      items: [
        if (permissions.contains(Permissions.viewAttendance))
          DashboardGridItem(
            icon: Icons.touch_app_rounded,
            label: "Attendance",
            onTap: () => context.pushNamed('attendance'),
            animation: _controller,
            intervalStart: 0.15,
            gradientStart: AppTheme.gridGradient1Start,
            gradientEnd: AppTheme.gridGradient1End,
            iconColor: AppTheme.gridIconColor,
          ),
        if (permissions.contains(Permissions.viewApplyLeave))
          DashboardGridItem(
            icon: Icons.calendar_month_rounded,
            label: "Apply Leave",
            onTap: () => context.pushNamed('apply_leave'),
            animation: _controller,
            intervalStart: 0.2,
            gradientStart: AppTheme.gridGradient2Start,
            gradientEnd: AppTheme.gridGradient2End,
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
        DashboardGridItem(
          icon: Icons.upcoming,
          label: "Upcoming Leaves",
          onTap: () => context.pushNamed('upcoming_leaves'),
          animation: _controller,
          intervalStart: 0.3,
          gradientStart: AppTheme.gridGradient2Start,
          gradientEnd: AppTheme.gridGradient3End,
          iconColor: AppTheme.gridIconColor,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dashboardState = ref.watch(dashboardProvider);
    final permissionState = ref.watch(permissionProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: dashboardState.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
                data: (data) {
                  if (data == null) {
                    return const Center(child: Text("No data"));
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(dashboardProvider.notifier)
                          .loadDashboard();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildBalanceCard(theme, data),
                          const SizedBox(height: 24),
                          _buildGrid(permissionState),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
