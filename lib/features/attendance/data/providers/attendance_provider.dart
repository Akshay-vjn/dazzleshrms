import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/attendance_model.dart';
import '../repo/attendance_repo.dart';



final attendanceRepositoryProvider =
Provider<AttendanceRepository>((ref) {
  return AttendanceRepository();
});

final attendanceProvider =
StateNotifierProvider<AttendanceNotifier, AsyncValue<AttendanceData?>>(
      (ref) => AttendanceNotifier(ref.read(attendanceRepositoryProvider)),
);

class AttendanceNotifier
    extends StateNotifier<AsyncValue<AttendanceData?>> {
  final AttendanceRepository _repository;

  AttendanceNotifier(this._repository)
      : super(const AsyncValue.loading());

  Future<void> loadAttendance({
    int page = 1,
    int limit = 10,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.fetchAttendance(
        page: page,
        limit: limit,
      );
      state = AsyncValue.data(response.data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
