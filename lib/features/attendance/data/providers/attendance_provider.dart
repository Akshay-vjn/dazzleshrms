import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/attendance_model.dart';
import '../repo/attendance_repo.dart';


// ================== REPOSITORY PROVIDER ==================
final attendanceRepositoryProvider =
Provider<AttendanceRepository>((ref) {
  return AttendanceRepository();
});


// ================== STATE PROVIDER ==================
final attendanceProvider =
StateNotifierProvider<AttendanceNotifier, AsyncValue<AttendanceData?>>(
      (ref) => AttendanceNotifier(ref.read(attendanceRepositoryProvider)),
);


// ================== NOTIFIER ==================
class AttendanceNotifier
    extends StateNotifier<AsyncValue<AttendanceData?>> {
  final AttendanceRepository _repository;

  CancelToken? _cancelToken;

  AttendanceNotifier(this._repository)
      : super(const AsyncValue.loading());

  /// 🔥 LOAD ATTENDANCE (INITIAL + PAGINATION)
  Future<void> loadAttendance({
    int page = 1,
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    // Cancel any previous request
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    /// ✅ SHOW LOADING ONLY FOR FIRST PAGE
    if (page == 1) {
      state = const AsyncValue.loading();
    }

    try {
      final response = await _repository.fetchAttendance(
        page: page,
        limit: limit,
        cancelToken: _cancelToken,
      );

      // Only update if request wasn't cancelled
      if (!(_cancelToken?.isCancelled ?? false)) {
        state = AsyncValue.data(response.data);
      }
    } on DioException catch (e) {
      if (e.type != DioExceptionType.cancel) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    } catch (e, st) {
      if (!(_cancelToken?.isCancelled ?? false)) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  /// 🔄 RESET STATE (WHEN LEAVING SCREEN)
  void reset() {
    _cancelToken?.cancel('Reset called');
    _cancelToken = null;
    state = const AsyncValue.loading();
  }

  @override
  void dispose() {
    _cancelToken?.cancel('Notifier disposed');
    super.dispose();
  }
}
