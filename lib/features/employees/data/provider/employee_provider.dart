import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/employee_model.dart';
import '../repo/employee_repo.dart';

final employeeRepositoryProvider = Provider((ref) => EmployeeRepository());

final employeesProvider = StateNotifierProvider<EmployeesNotifier, AsyncValue<EmployeeListResponse?>>(
  (ref) => EmployeesNotifier(ref),
);

class EmployeesNotifier extends StateNotifier<AsyncValue<EmployeeListResponse?>> {
  final Ref ref;
  EmployeesNotifier(this.ref) : super(const AsyncLoading());

  Future<void> loadEmployees({int page = 1, int limit = 10}) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(employeeRepositoryProvider);
      final data = await repository.getTeamEmployees(page: page, limit: limit);
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
