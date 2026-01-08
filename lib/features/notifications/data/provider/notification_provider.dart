import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../repo/notification_repo.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

class NotificationNotifier extends StateNotifier<AsyncValue<NotificationData?>> {
  final NotificationRepository _repo;
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isLoadingMore = false;

  NotificationNotifier(this._repo)
      : super(const AsyncValue.loading());

  Future<void> loadNotifications({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasNextPage = true;
    }

    if ((state.isLoading || _isLoadingMore || !_hasNextPage) && !isRefresh) return;

    try {
      if (_currentPage == 1) {
        state = const AsyncValue.loading();
      } else {
        _isLoadingMore = true;
      }
      
      final newData = await _repo.fetchAllNotifications(page: _currentPage);
          
      if (_currentPage == 1) {
        state = AsyncValue.data(newData);
      } else {
        final currentData = state.value;
        if (currentData != null) {
          state = AsyncValue.data(NotificationData(
            totalItems: newData.totalItems,
            totalPages: newData.totalPages,
            currentPage: newData.currentPage,
            records: [...currentData.records, ...newData.records],
          ));
        }
      }

      _hasNextPage = _currentPage < newData.totalPages;
      if (_hasNextPage) _currentPage++;
      
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      _isLoadingMore = false;
    }
  }

  bool get hasNextPage => _hasNextPage;
  bool get isLoadingMore => _isLoadingMore;
}

final allNotificationsProvider =
    StateNotifierProvider<NotificationNotifier, AsyncValue<NotificationData?>>(
  (ref) => NotificationNotifier(ref.read(notificationRepositoryProvider)),
);
