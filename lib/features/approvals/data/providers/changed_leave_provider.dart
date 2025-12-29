
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/changed_leaves_model.dart';
import '../repo/changed_leave_repo.dart';


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
  }) async {
    state = const AsyncLoading();
    try {
      final res = await _repo.fetchPendingLeaves(
        page: page,
        limit: limit,
      );
      state = AsyncData(res);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
