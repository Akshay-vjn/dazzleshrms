import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/break_dashboard_employee_response.dart';
import '../models/break_report_response.dart';
import '../models/employee_dashboard_attendance_response.dart';
import '../models/employee_dashboard_breaks_response.dart';
import '../models/employee_dashboard_summary_response.dart';
import '../repo/break_report_repo.dart';

final breakReportRepoProvider = Provider<BreakReportRepo>((ref) {
  return BreakReportRepo();
});

final breakDashboardEmployeesProvider = StateNotifierProvider<
    BreakDashboardEmployeesNotifier,
    AsyncValue<BreakDashboardEmployeeData?>>(
  (ref) => BreakDashboardEmployeesNotifier(ref.read(breakReportRepoProvider)),
);

class BreakDashboardEmployeesNotifier
    extends StateNotifier<AsyncValue<BreakDashboardEmployeeData?>> {
  final BreakReportRepo _repo;
  int _requestVersion = 0;

  BreakDashboardEmployeesNotifier(this._repo)
      : super(const AsyncValue.loading());

  Future<void> fetchEmployees({
    required int storeId,
    required int designationId,
    int page = 1,
    int limit = 10,
    bool append = false,
    String? fromDate,
    String? toDate,
  }) async {
    // A filter change starts a new request generation. Responses from earlier
    // stores/designations must not replace the currently selected result.
    final requestVersion = append ? _requestVersion : ++_requestVersion;
    if (!append) {
      state = const AsyncValue.loading();
    }
    try {
      final data = await _repo.getDashboardEmployees(
        storeId: storeId,
        designationId: designationId,
        page: page,
        limit: limit,
        fromDate: fromDate,
        toDate: toDate,
      );
      if (requestVersion != _requestVersion) return;
      int totalPages = data.totalPages;
      if (totalPages <= 0) {
        if (data.totalItems > 0) {
          totalPages = (data.totalItems / limit).ceil();
        } else if (data.data.length >= limit) {
          totalPages = page + 1;
        } else {
          totalPages = page;
        }
      }
      final normalizedData = BreakDashboardEmployeeData(
        totalItems: data.totalItems > 0 ? data.totalItems : data.data.length,
        totalPages: totalPages,
        currentPage: data.currentPage > 0 ? data.currentPage : page,
        data: data.data,
      );

      if (append) {
        final existing = state.valueOrNull;
        if (existing != null) {
          final seen = existing.data.map((e) => e.employeeId).toSet();
          final merged = [
            ...existing.data,
            ...normalizedData.data.where((e) => seen.add(e.employeeId)),
          ];
          state = AsyncValue.data(
            BreakDashboardEmployeeData(
              totalItems: normalizedData.totalItems,
              totalPages: normalizedData.totalPages,
              currentPage: normalizedData.currentPage,
              data: merged,
            ),
          );
          return;
        }
      }
      state = AsyncValue.data(normalizedData);
    } catch (e, st) {
      if (requestVersion != _requestVersion) return;
      if (append && state.valueOrNull != null) return;
      state = AsyncValue.error(e, st);
    }
  }
}

final employeeDashboardSummaryProvider = StateNotifierProvider.autoDispose
    .family<
        EmployeeDashboardSummaryNotifier,
        AsyncValue<EmployeeDashboardSummaryData?>,
        int>((ref, employeeId) {
  return EmployeeDashboardSummaryNotifier(
    ref.read(breakReportRepoProvider),
    employeeId,
  );
});

class EmployeeDashboardSummaryNotifier
    extends StateNotifier<AsyncValue<EmployeeDashboardSummaryData?>> {
  final BreakReportRepo _repo;
  final int employeeId;

  EmployeeDashboardSummaryNotifier(this._repo, this.employeeId)
      : super(const AsyncValue.loading());

  Future<void> fetchSummary({
    String? fromDate,
    String? toDate,
  }) async {
    state = const AsyncValue.loading();
    try {
      final data = await _repo.getEmployeeDashboardSummary(
        employeeId: employeeId,
        fromDate: fromDate,
        toDate: toDate,
      );
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final employeeDashboardAttendanceProvider = StateNotifierProvider.autoDispose
    .family<
        EmployeeDashboardAttendanceNotifier,
        AsyncValue<EmployeeDashboardAttendancePage?>,
        int>((ref, employeeId) {
  return EmployeeDashboardAttendanceNotifier(
    ref.read(breakReportRepoProvider),
    employeeId,
  );
});

class EmployeeDashboardAttendanceNotifier
    extends StateNotifier<AsyncValue<EmployeeDashboardAttendancePage?>> {
  final BreakReportRepo _repo;
  final int employeeId;

  EmployeeDashboardAttendanceNotifier(this._repo, this.employeeId)
      : super(const AsyncValue.loading());

  Future<void> fetchAttendance({
    int page = 1,
    int limit = 10,
    String? fromDate,
    String? toDate,
    bool append = false,
  }) async {
    if (!append) {
      state = const AsyncValue.loading();
    }
    try {
      final data = await _repo.getEmployeeDashboardAttendance(
        employeeId: employeeId,
        page: page,
        limit: limit,
        fromDate: fromDate,
        toDate: toDate,
      );
      if (append) {
        final existing = state.valueOrNull;
        if (existing != null) {
          final seen = existing.data.map((e) => e.attendanceId).toSet();
          state = AsyncValue.data(
            EmployeeDashboardAttendancePage(
              totalItems: data.totalItems,
              totalPages: data.totalPages,
              currentPage: data.currentPage,
              data: [
                ...existing.data,
                ...data.data.where((e) => seen.add(e.attendanceId)),
              ],
            ),
          );
          return;
        }
      }
      state = AsyncValue.data(data);
    } catch (e, st) {
      if (append && state.valueOrNull != null) return;
      state = AsyncValue.error(e, st);
    }
  }
}

final employeeDashboardBreaksProvider = StateNotifierProvider.autoDispose
    .family<
        EmployeeDashboardBreaksNotifier,
        AsyncValue<EmployeeDashboardBreaksPage?>,
        int>((ref, employeeId) {
  return EmployeeDashboardBreaksNotifier(
    ref.read(breakReportRepoProvider),
    employeeId,
  );
});

class EmployeeDashboardBreaksNotifier
    extends StateNotifier<AsyncValue<EmployeeDashboardBreaksPage?>> {
  final BreakReportRepo _repo;
  final int employeeId;

  EmployeeDashboardBreaksNotifier(this._repo, this.employeeId)
      : super(const AsyncValue.loading());

  Future<void> fetchBreaks({
    int page = 1,
    int limit = 10,
    String? fromDate,
    String? toDate,
    bool append = false,
  }) async {
    if (!append) {
      state = const AsyncValue.loading();
    }
    try {
      final data = await _repo.getEmployeeDashboardBreaks(
        employeeId: employeeId,
        page: page,
        limit: limit,
        fromDate: fromDate,
        toDate: toDate,
      );
      if (append) {
        final existing = state.valueOrNull;
        if (existing != null) {
          final seen = existing.data.map((e) => e.date).toSet();
          state = AsyncValue.data(
            EmployeeDashboardBreaksPage(
              totalItems: data.totalItems,
              totalPages: data.totalPages,
              currentPage: data.currentPage,
              data: [
                ...existing.data,
                ...data.data.where((e) => seen.add(e.date)),
              ],
            ),
          );
          return;
        }
      }
      state = AsyncValue.data(data);
    } catch (e, st) {
      if (append && state.valueOrNull != null) return;
      state = AsyncValue.error(e, st);
    }
  }
}

final breakReportProvider =
    StateNotifierProvider<BreakReportNotifier, AsyncValue<BreakReportPaginatedData?>>(
  (ref) => BreakReportNotifier(ref.read(breakReportRepoProvider)),
);

class BreakReportNotifier
    extends StateNotifier<AsyncValue<BreakReportPaginatedData?>> {
  final BreakReportRepo _repo;

  BreakReportNotifier(this._repo) : super(const AsyncValue.loading());

  Future<void> loadBreakReports({
    required int page,
    required int limit,
    required String date,
    int? storeId,
    int? designationId,
    int? employeeId,
    bool append = false,
  }) async {
    if (!append) {
      state = const AsyncValue.loading();
    }
    try {
      final data = await _repo.getBreakReport(
        page: page,
        limit: limit,
        date: date,
        storeId: storeId,
        designationId: designationId,
        employeeId: employeeId,
      );

      int totalPages = data.totalPages;
      if (totalPages <= 0) {
        if (data.totalItems > 0) {
          totalPages = (data.totalItems / limit).ceil();
        } else if (data.records.length >= limit) {
          totalPages = page + 1;
        } else {
          totalPages = page;
        }
      }

      final normalizedData = BreakReportPaginatedData(
        totalItems: data.totalItems > 0 ? data.totalItems : data.records.length,
        totalPages: totalPages,
        currentPage: data.currentPage > 0 ? data.currentPage : page,
        records: data.records,
      );

      if (append) {
        final existing = state.valueOrNull;
        if (existing != null) {
          final seen = existing.records.map((e) => e.employeeBreakId).toSet();
          final merged = [
            ...existing.records,
            ...normalizedData.records.where((e) => seen.add(e.employeeBreakId)),
          ];
          state = AsyncValue.data(
            BreakReportPaginatedData(
              totalItems: normalizedData.totalItems,
              totalPages: normalizedData.totalPages,
              currentPage: normalizedData.currentPage,
              records: merged,
            ),
          );
          return;
        }
      }
      state = AsyncValue.data(normalizedData);
    } catch (e, st) {
      if (append && state.valueOrNull != null) return;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadBreakReport({
    required int page,
    required int limit,
    required String date,
    int? storeId,
    int? designationId,
    int? employeeId,
    bool append = false,
  }) =>
      loadBreakReports(
        page: page,
        limit: limit,
        date: date,
        storeId: storeId,
        designationId: designationId,
        employeeId: employeeId,
        append: append,
      );
}
