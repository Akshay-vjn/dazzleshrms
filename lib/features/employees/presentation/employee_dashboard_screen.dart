import 'package:dazzleshrms/core/app_theme/app_page_bar.dart';
import 'package:dazzleshrms/core/app_theme/app_surface.dart';
import 'package:dazzleshrms/core/app_theme/app_visuals.dart';
import 'package:dazzleshrms/core/app_theme/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_theme/app_theme.dart';
import '../../../core/permissions/permission.dart';
import '../../../core/permissions/permission_provider.dart';
import '../../dashboard/presentation/widgets/dashboard_grid.dart';
import '../../dashboard/presentation/widgets/dashboard_grid_item.dart';
import '../data/models/employee_model.dart';

class EmployeeDashboardScreen extends ConsumerStatefulWidget {
  final Employee employee;
  const EmployeeDashboardScreen({super.key, required this.employee});

  @override
  ConsumerState<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState
    extends ConsumerState<EmployeeDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final permissions = ref.watch(permissionProvider);

    return AppScaffold(
      appBar: AppPageBar(title: 'Employee'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Simplified Profile Card
            AppSurface(
              padding: const EdgeInsets.all(20),

              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.PrimaryColor.withValues(
                      alpha: 0.1,
                    ),
                    child: Text(
                      widget.employee.name[0].toUpperCase(),
                      style: TextStyle(
                        color: AppVisuals.of(context).accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.employee.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.employee.designation,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          "ID: ${widget.employee.employeeCode}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppVisuals.of(context).accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Store: ${widget.employee.store}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppVisuals.of(context).accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            DashboardGrid(
              staggerStart: 0.1,
              staggerStep: 0.1,
              items: [
                if (permissions.contains(Permissions.viewEmployeeAttendance))
                  DashboardGridItem(
                    icon: Icons.calendar_today_rounded,
                    label: "Attendance",
                    tone: ActionTone.blue,
                    onTap: () => context.pushNamed(
                      'employee_attendance',
                      pathParameters: {
                        'id': widget.employee.employeeId.toString(),
                      },
                      extra: widget.employee,
                    ),
                    animation: _controller,
                    intervalStart: 0.1,
                  ),
                if (permissions.contains(Permissions.viewEmployeeLeaves))
                  DashboardGridItem(
                    icon: Icons.calendar_month,
                    label: "Leaves",
                    tone: ActionTone.teal,
                    onTap: () => context.pushNamed(
                      'employee_leaves',
                      pathParameters: {
                        'id': widget.employee.employeeId.toString(),
                      },
                      extra: widget.employee,
                    ),
                    animation: _controller,
                    intervalStart: 0.2,
                  ),
                if (permissions.contains(Permissions.viewEmployeeApprovals))
                  DashboardGridItem(
                    icon: Icons.fact_check_outlined,
                    label: "Approvals",
                    tone: ActionTone.purple,
                    onTap: () => context.pushNamed(
                      'employee_pending_leaves',
                      pathParameters: {
                        'id': widget.employee.employeeId.toString(),
                      },
                      extra: widget.employee,
                    ),
                    animation: _controller,
                    intervalStart: 0.3,
                  ),
                if (permissions.contains(Permissions.viewEmployeeUpcoming))
                  DashboardGridItem(
                    icon: Icons.next_plan_outlined,
                    label: "Upcoming Leaves",
                    tone: ActionTone.orange,
                    onTap: () => context.pushNamed(
                      'employee_upcoming_leaves',
                      pathParameters: {
                        'id': widget.employee.employeeId.toString(),
                      },
                      extra: widget.employee,
                    ),
                    animation: _controller,
                    intervalStart: 0.4,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
