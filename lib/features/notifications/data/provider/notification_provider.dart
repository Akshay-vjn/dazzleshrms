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

/// Controls whether the green notification dot is visible.
/// Set to true when unread notifications are detected, false when user opens notifications.
final showNotificationDotProvider = StateProvider<bool>((ref) => false);

/// Checks the API for unread notifications and updates the dot provider.
/// Only sets it to true if unread exist — never resets to false
/// (that only happens when the user taps the notification icon).
Future<void> checkUnreadNotifications(WidgetRef ref) async {
  try {
    final repo = ref.read(notificationRepositoryProvider);
    final data = await repo.fetchAllNotifications(page: 1, limit: 10);
    final hasUnread = data.records.any((item) => !item.isRead);
    if (hasUnread) {
      ref.read(showNotificationDotProvider.notifier).state = true;
    }
  } catch (_) {
    // Silently ignore — don't change the dot state on error
  }
}
