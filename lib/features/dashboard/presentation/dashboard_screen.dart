import 'package:dazzleshrms/features/announcements/presentation/announcement_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';

import '../../notifications/presentation/notification_screen.dart';
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


  Widget _buildJobtitleCard(ThemeData theme, DashboardData data) {
    return FadeSlideItem(
      animation: _controller,
      intervalStart: 0.1,
      child: _JobTitleCard(
        role: data.role,
        store: data.store,
        theme: theme,
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
        DashboardGridItem(
          icon: Icons.campaign_rounded,
          label: "Announcements",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AnnouncementScreen()),
          ),
          animation: _controller,
          intervalStart: 0.2,
          gradientStart: AppTheme.gridGradient2Start,
          gradientEnd: AppTheme.gridGradient2End,
          iconColor: AppTheme.gridIconColor,
        ),
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
          loading: () => const Center(child: CircularProgressIndicator()),
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
                          _buildJobtitleCard(theme, data),
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


class _JobTitleCard extends StatefulWidget {
  final String role;
  final String store;
  final ThemeData theme;

  const _JobTitleCard({
    required this.role,
    required this.store,
    required this.theme,
  });

  @override
  State<_JobTitleCard> createState() => _JobTitleCardState();
}

class _JobTitleCardState extends State<_JobTitleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.theme.brightness == Brightness.dark;

    final surfaceColor =
    isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;

    final textColor =
    isDark ? Colors.white : Colors.black.withValues(alpha: 0.85);

    final borderColor = AppTheme.PrimaryColor.withValues(
      alpha: isDark ? 0.35 : 0.18,
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),

        onTapDown: (_) {
          setState(() => _pressed = true);

          Future.delayed(const Duration(milliseconds: 90), () {
            if (mounted) {
              setState(() => _pressed = false);
            }
          });
        },

        onTap: () {},

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.identity()
            ..translate(0.0, _pressed ? 4.0 : -6.0)
            ..scale(_pressed ? 0.98 : 1.0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.15),
                blurRadius: _pressed ? 8 : 18,
                offset: Offset(0, _pressed ? 4 : 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.PrimaryColor.withValues(alpha: 0.12),
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
                      widget.role,
                      style: widget.theme.textTheme.headlineSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Store : ${widget.store}",
                      style: widget.theme.textTheme.bodyMedium?.copyWith(
                        color: textColor.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
