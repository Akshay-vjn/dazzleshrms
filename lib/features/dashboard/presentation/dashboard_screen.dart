import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import 'package:dazzleshrms/core/storage/session_storage.dart';
import 'package:dazzleshrms/core/permissions/permission.dart';

import '../../notifications/notification_screen.dart';
import '../../profile/profile_screen/profile_screen.dart';
import '../data/providers/dashboard_provider.dart';
import '../data/models/dashboard_response.dart';
import 'widgets/fade_slide_item.dart';
import 'widgets/dashboard_grid.dart';
import 'widgets/dashboard_grid_item.dart';

import 'package:dazzleshrms/core/permissions/permission_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadDashboard();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    _controller.reset();
    _controller.forward();

    /// 🔥 VERY IMPORTANT
    ref.invalidate(permissionProvider);

    await ref.read(dashboardProvider.notifier).loadDashboard();
  }

  String formatLeave(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  // ================= HEADER =================
  Widget _buildHeader(ThemeData theme, DashboardData data) {
    final avatarLetter =
    (data.name.isNotEmpty ? data.name[0] : '?').toUpperCase();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.15),
          ),
        ),
      ),
      child: FadeSlideItem(
        animation: _controller,
        intervalStart: 0.0,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.PrimaryColor.withOpacity(0.15),
                child: Text(
                  avatarLetter,
                  style: TextStyle(
                    color: AppTheme.PrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi, ${data.name}",
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Welcome back to Dazzles !",
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationScreen(),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppTheme.PrimaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= JOB CARD (ORIGINAL UI) =================
  Widget _buildJobCard(ThemeData theme, DashboardData data) {
    final isDark = theme.brightness == Brightness.dark;

    final cardGradientStart =
    isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A);
    final cardGradientEnd =
    isDark ? const Color(0xFF334155) : const Color(0xFF1E293B);

    final textColor = Colors.white;
    final dividerColor = Colors.white.withOpacity(0.15);
    final statBg = Colors.white.withOpacity(0.15);

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
              color: Colors.black.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: AppTheme.PrimaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.role,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Store : ${data.store}",
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: textColor.withOpacity(0.85)),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(height: 1, color: dividerColor),

            const SizedBox(height: 20),

            Text(
              "Leave Balance",
              style: theme.textTheme.labelLarge?.copyWith(
                color: textColor.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                _leaveStatCard("Total", data.totalLeaves, statBg),
                _leaveStatCard("Used", data.usedLeaves, statBg),
                _leaveStatCard("Available", data.availableLeaves, statBg),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _leaveStatCard(String label, double value, Color bg) {
    return Expanded(
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
    );
  }

  // ================= GRID (PERMISSION BASED) =================
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
            intervalStart: 0.2,
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
            intervalStart: 0.25,
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
            intervalStart: 0.3,
            gradientStart: AppTheme.gridGradient3Start,
            gradientEnd: AppTheme.gridGradient3End,
            iconColor: AppTheme.gridIconColor,
          ),
      ],
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final permissionState = ref.watch(permissionProvider);

    return Scaffold(
      body: SafeArea(
        child: dashboardState.when(
          loading: () =>
          const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (data) {
            if (data == null) {
              return const Center(child: Text("No dashboard data"));
            }

            return Column(
              children: [
                _buildHeader(Theme.of(context), data),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildJobCard(Theme.of(context), data),
                          const SizedBox(height: 24),
                          _buildGrid(permissionState),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
