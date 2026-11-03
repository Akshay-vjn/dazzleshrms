import 'package:dazzleshrms/core/app_theme/app_page_bar.dart';
import 'package:dazzleshrms/core/app_theme/app_visuals.dart';
import 'package:dazzleshrms/core/app_theme/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dazzleshrms/core/permissions/permission.dart';
import 'package:dazzleshrms/core/permissions/permission_provider.dart';
import '../../dashboard/presentation/widgets/fade_slide_item.dart';
import '../../dashboard/presentation/widgets/dashboard_grid.dart';
import '../../dashboard/presentation/widgets/dashboard_grid_item.dart';

class ApprovalsScreen extends ConsumerStatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  ConsumerState<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends ConsumerState<ApprovalsScreen>
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

  Widget _buildHeader(ThemeData theme) => FadeSlideItem(
    animation: _controller,
    intervalStart: 0.0,
    child: const AppPageHeader(title: 'Approvals'),
  );

  Widget _buildGrid(Set<String> permissions) {
    return DashboardGrid(
      staggerStart: 0.15,
      staggerStep: 0.025,
      items: [
        if (permissions.contains(Permissions.viewApprovals))
          DashboardGridItem(
            icon: Icons.check_circle_outline_rounded,
            label: "Leave Approvals",
            tone: ActionTone.blue,
            onTap: () => context.pushNamed('leave_approvals'),
            animation: _controller,
            intervalStart: 0.15,
          ),
        if (permissions.contains(Permissions.viewImageApprovalIcon))
          DashboardGridItem(
            icon: Icons.add_a_photo_outlined,
            label: "Image Approval",
            tone: ActionTone.purple,
            onTap: () => context.pushNamed('image_approvals'),
            animation: _controller,
            intervalStart: 0.18,
          ),
        if (permissions.contains(Permissions.viewAllTeamApproval))
          DashboardGridItem(
            icon: Icons.groups_rounded,
            label: "Employee Approvals",
            tone: ActionTone.teal,
            onTap: () => context.pushNamed('employee_approvals'),
            animation: _controller,
            intervalStart: 0.2,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final permissionState = ref.watch(permissionProvider);

    return AppScaffold(
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
