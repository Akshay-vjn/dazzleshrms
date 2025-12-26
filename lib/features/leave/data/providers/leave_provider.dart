
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leave_model.dart';
import '../repo/leave_repo.dart';

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  return LeaveRepository();
});

final leaveProvider =
StateNotifierProvider<LeaveNotifier, AsyncValue<LeaveData?>>(
      (ref) => LeaveNotifier(ref.read(leaveRepositoryProvider)),
);

class LeaveNotifier extends StateNotifier<AsyncValue<LeaveData?>> {
  final LeaveRepository _repository;
  CancelToken? _currentCancelToken;

  LeaveNotifier(this._repository)
      : super(const AsyncValue.loading());

  Future<void> loadLeaves({
    int page = 1,
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    // If already loading and not forcing refresh, don't make duplicate request
    if (state.isLoading && !forceRefresh) {
      return;
    }

    // Cancel previous request if exists
    _currentCancelToken?.cancel('New request initiated');
    _currentCancelToken = CancelToken();

    state = const AsyncValue.loading();
    try {
      final response = await _repository.fetchLeaves(
        page: page,
        limit: limit,
        cancelToken: _currentCancelToken,
      );
      
      // Only update state if not cancelled
      if (!(_currentCancelToken?.isCancelled ?? false)) {
        state = AsyncValue.data(response.data);
      }
    } on DioException catch (e) {
      // Don't update state if request was cancelled
      if (e.type != DioExceptionType.cancel) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    } catch (e, st) {
      // Don't update state if request was cancelled
      if (!(_currentCancelToken?.isCancelled ?? false)) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  /// Reset state to initial loading state
  void reset() {
    // Cancel any ongoing request
    _currentCancelToken?.cancel('State reset');
    _currentCancelToken = null;
    state = const AsyncValue.loading();
  }

  @override
  void dispose() {
    _currentCancelToken?.cancel('Notifier disposed');
    super.dispose();
  }
}
