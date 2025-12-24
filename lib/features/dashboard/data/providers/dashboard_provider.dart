import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dashboard_response.dart';
import '../repo/dashboard_repo.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, AsyncValue<DashboardData?>>(
  (ref) => DashboardNotifier(ref.read(dashboardRepositoryProvider)),
);

class DashboardNotifier
    extends StateNotifier<AsyncValue<DashboardData?>> {
  final DashboardRepository _repository;

  DashboardNotifier(this._repository)
      : super(const AsyncValue.loading());

  Future<void> loadDashboard() async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.fetchDashboard();
      state = AsyncValue.data(response.data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}


