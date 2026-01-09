import 'package:dazzleshrms/features/announcements/presentation/announcement_screen.dart';
import 'package:dazzleshrms/features/approvals/presentation/approval_screen.dart';
import 'package:dazzleshrms/features/upcoming_leaves/presentation/upcoming_leaves_screen.dart';
import 'package:dazzleshrms/features/leave_management/presentation/leave_management_screen.dart';
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
          return OtpVerificationScreen(
            mobileNumber: mobile ?? '',
          );
        },
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainNavigation(),
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
        path: '/announcement',
        name: 'announcement',
        builder: (context, state) => const AnnouncementScreen(),
      ),
    ],
  );
});


