import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../leave/data/models/used_leave_model.dart';
import '../models/employee_leave_model.dart';
import '../models/employee_pending_leave_model.dart';
import '../models/employee_upcoming_leave_model.dart';
import '../repo/employee_leave_repo.dart';

final employeeLeaveRepositoryProvider = Provider((ref) => EmployeeLeaveRepository());

// Leave Provider
final employeeLeavesProvider = StateNotifierProvider.family<EmployeeLeavesNotifier, AsyncValue<EmployeeLeaveResponse?>, int>(
  (ref, employeeId) => EmployeeLeavesNotifier(ref, employeeId),
);

class EmployeeLeavesNotifier extends StateNotifier<AsyncValue<EmployeeLeaveResponse?>> {
  final Ref ref;
  final int employeeId;
  EmployeeLeavesNotifier(this.ref, this.employeeId) : super(const AsyncLoading());

  Future<void> loadLeaves({int page = 1, int limit = 10}) async {
    if (page == 1) {
      state = const AsyncLoading();
    }
    try {
      final repository = ref.read(employeeLeaveRepositoryProvider);
      final data = await repository.getEmployeeLeaves(employeeId, page: page, limit: limit);
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// Used Leaves Family Provider
final usedLeavesFamilyProvider = FutureProvider.family<UsedLeaveResponse, int>((ref, employeeId) async {
  return ref.read(employeeLeaveRepositoryProvider).getEmployeeUsedLeaves(employeeId);
});

// Apply Leave Provider
final applyEmployeeLeaveProvider = StateNotifierProvider.family<ApplyEmployeeLeaveNotifier, AsyncValue<void>, int>(
  (ref, employeeId) => ApplyEmployeeLeaveNotifier(ref, employeeId),
);

class ApplyEmployeeLeaveNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  final int employeeId;
  ApplyEmployeeLeaveNotifier(this.ref, this.employeeId) : super(const AsyncData(null));

  Future<void> applyLeave({
    required int leaveTypeId,
    required String fromDate,
    required String toDate,
    required String note,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(employeeLeaveRepositoryProvider).applyEmployeeLeave(
        employeeId,
        leaveTypeId: leaveTypeId,
        fromDate: fromDate,
        toDate: toDate,
        note: note,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// Pending Leaves Provider
final employeePendingLeavesProvider = StateNotifierProvider.family<EmployeePendingLeavesNotifier, AsyncValue<EmployeePendingLeaveResponse?>, int>(
  (ref, employeeId) => EmployeePendingLeavesNotifier(ref, employeeId),
);

class EmployeePendingLeavesNotifier extends StateNotifier<AsyncValue<EmployeePendingLeaveResponse?>> {
  final Ref ref;
  final int employeeId;
  EmployeePendingLeavesNotifier(this.ref, this.employeeId) : super(const AsyncLoading());

  Future<void> loadPendingLeaves({int page = 1, int limit = 10}) async {
    if (page == 1) {
      state = const AsyncLoading();
    }
    try {
      final repository = ref.read(employeeLeaveRepositoryProvider);
      final data = await repository.getEmployeePendingLeaves(employeeId, page: page, limit: limit);
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// Approval Provider
final employeeLeaveApprovalProvider = StateNotifierProvider<EmployeeLeaveApprovalNotifier, AsyncValue<void>>(
  (ref) => EmployeeLeaveApprovalNotifier(ref),
);

class EmployeeLeaveApprovalNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  EmployeeLeaveApprovalNotifier(this.ref) : super(const AsyncData(null));

  Future<void> approveLeave({
    required int leaveRoasterId,
    required List<Map<String, dynamic>> decisions,
    String? rejectReason,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(employeeLeaveRepositoryProvider).approveEmployeeLeave(
        leaveRoasterId: leaveRoasterId,
        decisions: decisions,
        rejectReason: rejectReason,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> rejectLeave({
    required int leaveRoasterId,
    required String rejectReason,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(employeeLeaveRepositoryProvider).rejectEmployeeLeave(
        leaveRoasterId: leaveRoasterId,
        rejectReason: rejectReason,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// Upcoming Leaves Provider
final employeeUpcomingLeavesProvider = StateNotifierProvider.family<EmployeeUpcomingLeavesNotifier, AsyncValue<EmployeeUpcomingLeaveResponse?>, int>(
  (ref, employeeId) => EmployeeUpcomingLeavesNotifier(ref, employeeId),
);

class EmployeeUpcomingLeavesNotifier extends StateNotifier<AsyncValue<EmployeeUpcomingLeaveResponse?>> {
  final Ref ref;
  final int employeeId;
  EmployeeUpcomingLeavesNotifier(this.ref, this.employeeId) : super(const AsyncLoading());

  Future<void> loadUpcomingLeaves({int page = 1, int limit = 10}) async {
    if (page == 1) {
      state = const AsyncLoading();
    }
    try {
      final repository = ref.read(employeeLeaveRepositoryProvider);
      final data = await repository.getEmployeeUpcomingLeaves(employeeId, page: page, limit: limit);
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
