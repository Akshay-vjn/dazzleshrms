import 'package:dazzleshrms/features/announcements/presentation/announcement_screen.dart';
import 'package:dazzleshrms/features/approvals/presentation/approval_screen.dart';
import 'package:dazzleshrms/features/attendance_scanner/presentation/attendance_qr_scanner.dart';
import 'package:dazzleshrms/features/employees/presentation/employees_list_screen.dart';
import 'package:dazzleshrms/features/employees/presentation/employee_dashboard_screen.dart';
import 'package:dazzleshrms/features/employees/presentation/employee_attendance_screen.dart';
import 'package:dazzleshrms/features/employees/presentation/employee_leave_screen.dart';
import 'package:dazzleshrms/features/employees/presentation/employee_pending_leaves_screen.dart';
import 'package:dazzleshrms/features/employees/presentation/team_employee_approvals_screen.dart';
import 'package:dazzleshrms/features/permissions_in_and_out/presentation/permisssion_screen.dart';
import 'package:dazzleshrms/features/permissions_in_and_out/presentation/permission_approvals_screen.dart';
import 'package:dazzleshrms/features/employees/presentation/employee_upcoming_leaves_screen.dart';
import 'package:dazzleshrms/features/employees/data/models/employee_model.dart';
import 'package:dazzleshrms/features/upcoming_leaves/presentation/upcoming_leaves_screen.dart';
import 'package:dazzleshrms/features/leave_management/presentation/leave_management_screen.dart';
import 'package:dazzleshrms/features/leave_management/presentation/approvals_screen.dart';
import 'package:dazzleshrms/features/break_time/presentation/break_dashboard_screen.dart';
import 'package:dazzleshrms/features/break_reports/presentation/break_reports_dashboardscreen.dart';
import 'package:dazzleshrms/core/widgets/no_internet_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:dazzleshrms/features/auth/presentation/login_screen.dart';
import 'package:dazzleshrms/features/auth/presentation/otp_verification_screen.dart';
import 'package:dazzleshrms/features/auth/presentation/splashscreen.dart';
import 'package:dazzleshrms/core/navigation/bottom_navigation.dart';
import 'package:dazzleshrms/core/navigation/navigation_keys.dart';

import '../../features/attendance/presentation/attendance_screen.dart';
import '../../features/leave/presentation/leave_apply_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) {
          final mobile = state.extra as String?;
          return OtpVerificationScreen(mobileNumber: mobile ?? '');
        },
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainNavigation(),
      ),
      GoRoute(
        path: '/store-qr',
        name: 'store_qr',
        builder: (context, state) => const AttendanceQrScan(),
      ),
      GoRoute(
        path: '/attendance',
        name: 'attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: '/apply-leave',
        name: 'apply_leave',
        builder: (context, state) => const ApplyLeaveScreen(),
      ),
      GoRoute(
        path: '/approvals',
        name: 'approvals',
        builder: (context, state) => const ApprovalsScreen(),
      ),
      GoRoute(
        path: '/leave-approvals',
        name: 'leave_approvals',
        builder: (context, state) => const ApprovalScreen(),
      ),
      GoRoute(
        path: '/upcoming',
        name: 'upcoming_leaves',
        builder: (context, state) => const UpcomingLeaveScreen(),
      ),
      GoRoute(
        path: '/leave-management',
        name: 'leave_management',
        builder: (context, state) => const LeaveManagementScreen(),
      ),
      GoRoute(
        path: '/break-dashboard',
        name: 'break_dashboard',
        builder: (context, state) => const BreakDashboardScreen(),
      ),
      GoRoute(
        path: '/break-reports',
        name: 'break_reports',
        builder: (context, state) => const BreakReportsDashboardScreen(),
      ),
      GoRoute(
        path: '/employee-approvals',
        name: 'employee_approvals',
        builder: (context, state) => const TeamEmployeeApprovalsScreen(),
      ),
      GoRoute(
        path: '/permissions',
        name: 'permissions',
        builder: (context, state) => const PermisssionScreen(),
      ),
      GoRoute(
        path: '/permission-approvals',
        name: 'permission_approvals',
        builder: (context, state) => const PermissionApprovalsScreen(),
      ),
      GoRoute(
        path: '/announcement',
        name: 'announcement',
        builder: (context, state) => const AnnouncementScreen(),
      ),
      GoRoute(
        path: '/employees',
        name: 'employees',
        builder: (context, state) => const EmployeesListScreen(),
        routes: [
          GoRoute(
            path: 'dashboard',
            name: 'employee_dashboard',
            builder: (context, state) {
              final employee = state.extra as Employee;
              return EmployeeDashboardScreen(employee: employee);
            },
          ),
          GoRoute(
            path: ':id/attendance',
            name: 'employee_attendance',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              final employee = state.extra as Employee;
              return EmployeeAttendanceScreen(
                employeeId: id,
                employeeName: employee.name,
              );
            },
          ),
          GoRoute(
            path: ':id/leaves',
            name: 'employee_leaves',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              final employee = state.extra as Employee;
              return EmployeeLeaveScreen(
                employeeId: id,
                employeeName: employee.name,
              );
            },
          ),
          GoRoute(
            path: ':id/pending-leaves',
            name: 'employee_pending_leaves',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              final employee = state.extra as Employee;
              return EmployeePendingLeavesScreen(
                employeeId: id,
                employeeName: employee.name,
              );
            },
          ),
          GoRoute(
            path: ':id/upcoming-leaves',
            name: 'employee_upcoming_leaves',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              final employee = state.extra as Employee;
              return EmployeeUpcomingLeavesScreen(
                employeeId: id,
                employeeName: employee.name,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/no-internet',
        name: 'no_internet',
        builder: (context, state) => const NoInternetScreen(),
      ),
    ],
  );
});
