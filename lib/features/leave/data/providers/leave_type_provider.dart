import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leave_type_model.dart';
import '../repo/leave_type_repo.dart';

final leaveTypeRepositoryProvider =
Provider<LeaveTypeRepository>((ref) {
  return LeaveTypeRepository();
});

final leaveTypeProvider =
StateNotifierProvider.autoDispose<LeaveTypeNotifier, AsyncValue<List<LeaveType>>>(
      (ref) => LeaveTypeNotifier(ref.read(leaveTypeRepositoryProvider)),
);

class LeaveTypeNotifier extends StateNotifier<AsyncValue<List<LeaveType>>> {
  final LeaveTypeRepository _repository;

  LeaveTypeNotifier(this._repository) : super(const AsyncLoading());

  Future<void> loadLeaveTypes() async {
    try {
      final response = await _repository.fetchLeaveTypes();
      state = AsyncData(response.data);
    } catch (e, st) {
      state = AsyncError(e.toString(), st);
    }
  }
}
