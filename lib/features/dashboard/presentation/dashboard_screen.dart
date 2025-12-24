import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';

import 'package:dazzleshrms/features/profile/profile_screen/profile_screen.dart';
import '../../notifications/notification_screen.dart';
import 'widgets/fade_slide_item.dart';
import 'widgets/dashboard_grid.dart';
import 'widgets/dashboard_grid_item.dart';
import '../data/providers/dashboard_provider.dart';
import '../data/models/dashboard_response.dart';

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

  Widget _buildHeader(ThemeData theme, DashboardData data) {
    final avatarLetter =
        (data.name.isNotEmpty ? data.name[0] : '?').toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.15),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: FadeSlideItem(
        animation: _controller,
        intervalStart: 0.0,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
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
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
                decoration: const BoxDecoration(
                  color: AppTheme.PrimaryColor,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.notifications_outlined,
                  color: AppTheme.iconColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(ThemeData theme, DashboardData data) {
    return FadeSlideItem(
      animation: _controller,
      intervalStart: 0.1,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.PrimaryColor,
              AppTheme.PrimaryColor.withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.PrimaryColor.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.role.isNotEmpty ? data.role : "N/A",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "Store :",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.black.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              data.store.isNotEmpty ? data.store : 'N/A',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.black.withOpacity(0.85),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Divider
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Leave Statistics Section
            Text(
              "Leave Balance",
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.black.withOpacity(0.8),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildLeaveStatCard(
                    theme,
                    "Total",
                    data.totalLeaves.toString(),
                    Icons.calendar_today_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildLeaveStatCard(
                    theme,
                    "Used",
                    data.usedLeaves.toString(),
                    Icons.event_busy_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildLeaveStatCard(
                    theme,
                    "Available",
                    data.availableLeaves.toString(),
                    Icons.event_available_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveStatCard(
      ThemeData theme,
      String label,
      String value,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.black.withOpacity(0.85),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.black.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildGrid() {
    return DashboardGrid(
      animation: _controller,
      items: [
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dashboardState = ref.watch(dashboardProvider);

    return Scaffold(
      body: SafeArea(
        child: dashboardState.when(
          data: (data) {
            if (data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("No dashboard data available"),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          ref.read(dashboardProvider.notifier).loadDashboard(),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                _buildHeader(theme, data),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildJobCard(theme, data),
                        const SizedBox(height: 24),
                        _buildGrid(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      ref.read(dashboardProvider.notifier).loadDashboard(),
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
