import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';

import '../../../core/permissions/permission.dart';
import '../../notifications/data/provider/notification_provider.dart';
import '../../notifications/presentation/notification_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../data/providers/dashboard_provider.dart';
import '../data/models/dashboard_response.dart';
import 'widgets/fade_slide_item.dart';
import 'widgets/dashboard_grid.dart';
import 'widgets/dashboard_grid_item.dart';
import 'widgets/attendance_widget.dart';
import '../../../core/permissions/permission_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  String _currentAttendanceStatus = 'OFFLINE';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadDashboard();
      checkUnreadNotifications(ref);
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
    ref.read(showNotificationDotProvider.notifier).state = false;
    checkUnreadNotifications(ref);
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
              onTap: () {
                ref.read(showNotificationDotProvider.notifier).state = false;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationScreen(),
                  ),
                );
              },
              child: Stack(
                children: [
                  Container(
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
                  Consumer(
                    builder: (context, ref, _) {
                      final showDot = ref.watch(showNotificationDotProvider);
                      return showDot
                          ? Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Widget _buildJobtitleCard(ThemeData theme, DashboardData data) {
  //   return FadeSlideItem(
  //     animation: _controller,
  //     intervalStart: 0.1,
  //     child: _JobTitleCard(
  //       role: data.role,
  //       store: data.store,
  //       theme: theme,
  //     ),
  //   );
  // }


  Widget _buildGrid(Set<String> permissions) {
    final isCheckedIn = _currentAttendanceStatus.toUpperCase() == 'ACTIVE';
    return DashboardGrid(
      animation: _controller,
      items: [
        if (isCheckedIn)
        DashboardGridItem(
          icon: Icons.free_breakfast_rounded,
          label: "Break",
          onTap: () => context.pushNamed('break_dashboard'),
          animation: _controller,
          intervalStart: 0.35,
          gradientStart: AppTheme.gridGradient2Start,
          gradientEnd: AppTheme.dGrid1,
          iconColor: AppTheme.gridIconColor,
        ),
        if (permissions.contains(Permissions.viewLeaveManagement))
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
        if (permissions.contains(Permissions.viewAnnouncements))
          DashboardGridItem(
          icon: Icons.campaign_rounded,
          label: "Announcements",
          onTap: () => context.pushNamed('announcement'),
          animation: _controller,
          intervalStart: 0.2,
          gradientStart: AppTheme.dTeal,
          gradientEnd: AppTheme.dGreen,
          iconColor: AppTheme.gridIconColor,
        ),
        if (permissions.contains(Permissions.viewEmployees))
        DashboardGridItem(
          icon: Icons.people,
          label: "Employees",
          onTap: () => context.pushNamed('employees'),
          animation: _controller,
          intervalStart: 0.3,
          gradientStart: AppTheme.dGrid1,
          gradientEnd: AppTheme.dGrid1,
          iconColor: AppTheme.gridIconColor,
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final theme = Theme.of(context);
    final permissions = ref.watch(permissionProvider);

    return Scaffold(
      body: SafeArea(
        child: dashboardState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: AppTheme.statusError.withOpacity(0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Oops! Something went wrong",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        e.toString(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text("Try Again"),
                      ),
                    ],
                  ),
                ),
              ),
          data: (data) {
            if (data == null) {
              return const Center(child: Text("No dashboard data"));
            }

            // Sync local attendance status with backend data
            if (_currentAttendanceStatus != data.attendanceStatus.toUpperCase()) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _currentAttendanceStatus = data.attendanceStatus.toUpperCase();
                  });
                }
              });
            }

            final role = data.role.toLowerCase();
            if (role == 'store') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.goNamed('store_qr');
                }
              });
              return const SizedBox.shrink();
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
                          // _buildJobtitleCard(theme, data),
                          const SizedBox(height: 24),
                          AttendanceWidget(
                            animationController: _controller,
                            intervalStart: 0.15,
                            attendanceStatus: data.attendanceStatus,
                            onStatusChanged: (newStatus) {
                              setState(() {
                                _currentAttendanceStatus = newStatus;
                              });
                              ref
                                  .read(dashboardProvider.notifier)
                                  .updateAttendanceStatus(newStatus);
                              ref
                                  .read(dashboardProvider.notifier)
                                  .refreshSilently();
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildGrid(permissions),
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
