import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/employee_attendance_model.dart';
import '../repo/employee_attendance_repo.dart';

final employeeAttendanceRepositoryProvider = Provider((ref) => EmployeeAttendanceRepository());

final employeeAttendanceProvider = StateNotifierProvider.family<EmployeeAttendanceNotifier, AsyncValue<EmployeeAttendanceResponse?>, int>(
  (ref, employeeId) => EmployeeAttendanceNotifier(ref, employeeId),
);

class EmployeeAttendanceNotifier extends StateNotifier<AsyncValue<EmployeeAttendanceResponse?>> {
  final Ref ref;
  final int employeeId;
  EmployeeAttendanceNotifier(this.ref, this.employeeId) : super(const AsyncLoading());

  Future<void> loadAttendance({int page = 1, int limit = 10}) async {
    if (page == 1) {
      state = const AsyncLoading();
    }
    try {
      final repository = ref.read(employeeAttendanceRepositoryProvider);
      final data = await repository.getEmployeeAttendance(employeeId, page: page, limit: limit);
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
