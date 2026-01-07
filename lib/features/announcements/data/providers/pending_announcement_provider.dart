import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/announcement_model.dart';
import '../repo/get_announcement_repo.dart';
import 'announcement_provider.dart';

final pendingAnnouncementsProvider =
StateNotifierProvider<PendingAnnouncementsNotifier,
    AsyncValue<AnnouncementResponse?>>(
      (ref) => PendingAnnouncementsNotifier(ref),
);

class PendingAnnouncementsNotifier
    extends StateNotifier<AsyncValue<AnnouncementResponse?>> {
  final Ref ref;
  PendingAnnouncementsNotifier(this.ref) : super(const AsyncLoading());

  final _getRepo = GetAnnouncementRepository();

  Future<void> loadPending() async {
    state = const AsyncLoading();
    try {
      final data = await _getRepo.getPendingAnnouncements();
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> approve(int id) async {
    try {
      await ref.read(announcementRepositoryProvider).approveAnnouncement(id);
      await loadPending();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reject(int id) async {
    try {
      await ref.read(announcementRepositoryProvider).rejectAnnouncement(id);
      await loadPending();
    } catch (e) {
      rethrow;
    }
  }
}
