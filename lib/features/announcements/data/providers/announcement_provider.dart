import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/create_announcement_model.dart';
import '../models/store_model.dart';
import '../models/employee_model.dart';
import '../models/employee_announcement_model.dart';
import '../repo/announcement_repo.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepository();
});

final createAnnouncementProvider = StateNotifierProvider<
    CreateAnnouncementNotifier, AsyncValue<CreateAnnouncementResponse?>>(
      (ref) => CreateAnnouncementNotifier(ref.watch(announcementRepositoryProvider)),
);

final storesProvider = FutureProvider<List<Store>>((ref) async {
  final repo = ref.watch(announcementRepositoryProvider);
  return repo.fetchStores();
});

final employeesProvider = FutureProvider.family<List<Employee>, int>((ref, storeId) async {
  final repo = ref.watch(announcementRepositoryProvider);
  return repo.fetchEmployees(storeId);
});

final employeeAnnouncementsProvider = FutureProvider<EmployeeAnnouncementResponse>((ref) async {
  final repo = ref.watch(announcementRepositoryProvider);
  return repo.fetchEmployeeAnnouncements();
});

class CreateAnnouncementNotifier
    extends StateNotifier<AsyncValue<CreateAnnouncementResponse?>> {
  final AnnouncementRepository _repository;

  CreateAnnouncementNotifier(this._repository) : super(const AsyncData(null));

  Future<void> createAnnouncement({
    required String title,
    required String announcement,
    int? storeId,
    int? employeeId,
  }) async {
    state = const AsyncLoading();

    try {
      final response = await _repository.createAnnouncement(
        title: title,
        announcement: announcement,
        storeId: storeId,
        employeeId: employeeId,
      );

      state = AsyncData(response);
    } catch (e, st) {
      state = AsyncError(e.toString(), st);
    }
  }

  void reset() {
    state = const AsyncData(null);
  }
}
