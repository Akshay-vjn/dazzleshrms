import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/attendance_permission_pending_model.dart';
import '../repo/attendance_permission_repo.dart';

final attendancePermissionRepositoryProvider =
    Provider<AttendancePermissionRepository>((ref) {
  return AttendancePermissionRepository();
});

final attendancePermissionPendingProvider =
    FutureProvider.autoDispose
        .family<AttendancePermissionPendingResponse, PermissionApprovalType>(
            (ref, approvalType) async {
  final repo = ref.watch(attendancePermissionRepositoryProvider);
  return repo.fetchPending(
    page: 1,
    limit: 10,
    approvalType: approvalType,
  );
});
