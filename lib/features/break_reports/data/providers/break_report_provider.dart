import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/break_report_response.dart';
import '../repo/break_report_repo.dart';

final breakReportRepoProvider = Provider<BreakReportRepo>((ref) {
  return BreakReportRepo();
});

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
  }) async {
    state = const AsyncValue.loading();
    try {
      final data = await _repo.getBreakReport(
        page: page,
        limit: limit,
        date: date,
        storeId: storeId,
        designationId: designationId,
        employeeId: employeeId,
      );
      state = AsyncValue.data(data);
    } catch (e, st) {
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
  }) =>
      loadBreakReports(
        page: page,
        limit: limit,
        date: date,
        storeId: storeId,
        designationId: designationId,
        employeeId: employeeId,
      );
}
