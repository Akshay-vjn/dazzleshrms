import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/announcement_model.dart';
import '../repo/get_announcement_repo.dart';

final approvedAnnouncementsProvider =
StateNotifierProvider<ApprovedAnnouncementsNotifier,
    AsyncValue<AnnouncementResponse?>>(
      (ref) => ApprovedAnnouncementsNotifier(),
);

class ApprovedAnnouncementsNotifier
    extends StateNotifier<AsyncValue<AnnouncementResponse?>> {
  ApprovedAnnouncementsNotifier() : super(const AsyncLoading());

  final _repo = GetAnnouncementRepository();

  Future<void> loadApproved() async {
    state = const AsyncLoading();
    try {
      final data = await _repo.getApprovedAnnouncements();
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
