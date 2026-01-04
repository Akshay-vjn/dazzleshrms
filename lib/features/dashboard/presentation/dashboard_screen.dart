


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import '../../notifications/notification_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../data/providers/dashboard_provider.dart';
import '../data/models/dashboard_response.dart';
import 'widgets/fade_slide_item.dart';
import 'widgets/dashboard_grid.dart';
import 'widgets/dashboard_grid_item.dart';

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
    await ref.read(dashboardProvider.notifier).loadDashboard();
  }

  Widget _buildHeader(ThemeData theme, DashboardData data) {
    final avatarLetter =
    (data.name.isNotEmpty ? data.name[0] : '?').toUpperCase();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
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
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.PrimaryColor.withValues(alpha: 0.15),
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

  Widget _buildSJobtitleCard(ThemeData theme, DashboardData data) {
    final isDark = theme.brightness == Brightness.dark;
    final cardGradientStart =
    isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A);
    final cardGradientEnd =
    isDark ? const Color(0xFF334155) : const Color(0xFF1E293B);
    final textColor = Colors.white;

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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
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
                        ?.copyWith(color: textColor.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return DashboardGrid(
      animation: _controller,
      items: [
        DashboardGridItem(
          icon: Icons.event_note_rounded,
          label: "Leave Management",
          onTap: () => context.pushNamed('leave_management'),
          animation: _controller,
          intervalStart: 0.15,
          gradientStart: AppTheme.gridGradient1Start,
          gradientEnd: AppTheme.gridGradient1End,
          iconColor: AppTheme.gridIconColor,
        ),




        // Future groups/items can be added here
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final theme = Theme.of(context);

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
                _buildHeader(theme, data),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildSJobtitleCard(theme, data),
                          const SizedBox(height: 24),
                          _buildGrid(),
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
