
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
    if (state.isLoading && !forceRefresh) {
      return;
    }

    _currentCancelToken?.cancel('New request initiated');
    _currentCancelToken = CancelToken();

    state = const AsyncValue.loading();
    try {
      final response = await _repository.fetchLeaves(
        page: page,
        limit: limit,
        cancelToken: _currentCancelToken,
      );
      
      if (!(_currentCancelToken?.isCancelled ?? false)) {
        state = AsyncValue.data(response.data);
      }
    } on DioException catch (e) {
      if (e.type != DioExceptionType.cancel) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    } catch (e, st) {
      if (!(_currentCancelToken?.isCancelled ?? false)) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  void reset() {
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
