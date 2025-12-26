import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/apply_leave_model.dart';
import '../repo/apply_leave_repo.dart';

final applyLeaveRepositoryProvider =
Provider<ApplyLeaveRepository>((ref) {
  return ApplyLeaveRepository();
});

final applyLeaveProvider =
StateNotifierProvider<ApplyLeaveNotifier, AsyncValue<ApplyLeaveResponse?>>(
      (ref) => ApplyLeaveNotifier(ref.read(applyLeaveRepositoryProvider)),
);

class ApplyLeaveNotifier
    extends StateNotifier<AsyncValue<ApplyLeaveResponse?>> {
  final ApplyLeaveRepository _repository;

  ApplyLeaveNotifier(this._repository)
      : super(const AsyncData(null));

  /// ✅ THIS METHOD WAS MISSING
  Future<void> applyLeave({
    required int leaveTypeId,
    required String fromDate,
    required String toDate,
    required String note,
  }) async {
    state = const AsyncLoading();

    try {
      final response = await _repository.applyLeave(
        leaveTypeId: leaveTypeId,
        fromDate: fromDate,
        toDate: toDate,
        note: note,
      );

      state = AsyncData(response);
    } catch (e, st) {
      state = AsyncError(e.toString(), st);
    }
  }

  /// Optional but recommended
  void reset() {
    state = const AsyncData(null);
  }
}
