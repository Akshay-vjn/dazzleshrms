import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/create_announcement_model.dart';
import '../repo/announcement_repo.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepository();
});

final createAnnouncementProvider = StateNotifierProvider<
    CreateAnnouncementNotifier, AsyncValue<CreateAnnouncementResponse?>>(
      (ref) => CreateAnnouncementNotifier(ref.read(announcementRepositoryProvider)),
);

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
