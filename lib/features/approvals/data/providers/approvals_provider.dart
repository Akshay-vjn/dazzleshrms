import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/applied_leave_model.dart';
import '../repo/approvals_repo.dart';


final leaveApprovalRepositoryProvider =
Provider<LeaveApprovalRepository>((ref) {
  return LeaveApprovalRepository();
});

final leaveApprovalProvider =
StateNotifierProvider<LeaveApprovalNotifier, AsyncValue<AppliedLeaveData?>>(
      (ref) => LeaveApprovalNotifier(ref.read(leaveApprovalRepositoryProvider)),
);

class LeaveApprovalNotifier
    extends StateNotifier<AsyncValue<AppliedLeaveData?>> {
  final LeaveApprovalRepository _repo;

  LeaveApprovalNotifier(this._repo)
      : super(const AsyncValue.loading());

  Future<void> loadAppliedLeaves({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final data =
      await _repo.fetchAppliedLeaves(page: page, limit: limit);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
