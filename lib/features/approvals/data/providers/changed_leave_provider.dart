
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/modified_leaves_model.dart';
import '../repo/modified_leave_repo.dart';


final pendingLeaveRepositoryProvider =
Provider<PendingLeaveRepository>((ref) {
  return PendingLeaveRepository();
});

final pendingLeaveProvider =
StateNotifierProvider<PendingLeaveNotifier, AsyncValue<PendingLeaveResponse?>>(
      (ref) => PendingLeaveNotifier(
    ref.read(pendingLeaveRepositoryProvider),
  ),
);

class PendingLeaveNotifier
    extends StateNotifier<AsyncValue<PendingLeaveResponse?>> {
  final PendingLeaveRepository _repo;

  PendingLeaveNotifier(this._repo)
      : super(const AsyncLoading());

  Future<void> loadPendingLeaves({
    int page = 1,
    int limit = 10,
    int? designationId,
    int? storeId,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await _repo.fetchPendingLeaves(
        page: page,
        limit: limit,
        designationId: designationId,
        storeId: storeId,
      );
      state = AsyncData(res);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
