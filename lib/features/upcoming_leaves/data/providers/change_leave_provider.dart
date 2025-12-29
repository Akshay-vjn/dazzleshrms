import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/change_leaverequest_model.dart';
import '../repo/change_leave_repo.dart';

final changeLeaveProvider =
StateNotifierProvider<ChangeLeaveNotifier, AsyncValue<ChangeLeaveResponse?>>(
        (ref) {
      return ChangeLeaveNotifier(ref.read(changeLeaveRepositoryProvider));
    });

class ChangeLeaveNotifier
    extends StateNotifier<AsyncValue<ChangeLeaveResponse?>> {
  final ChangeLeaveRepository _repo;

  ChangeLeaveNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<void> cancelLeave(int logId) async {
    state = const AsyncValue.loading();
    try {
      final res = await _repo.sendChangeRequest(logId: logId);
      state = AsyncValue.data(res);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> changeLeaveType({
    required int logId,
    required String newType,
    required int newTypeId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final res = await _repo.sendChangeRequest(
        logId: logId,
        newType: newType,
        newTypeId: newTypeId,
      );
      state = AsyncValue.data(res);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
