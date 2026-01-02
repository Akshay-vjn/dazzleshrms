import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../models/upcoming_leave_model.dart';
import '../repo/upcoming_leave_repo.dart';

final upcomingLeaveProvider = StateNotifierProvider<
    UpcomingLeaveNotifier, AsyncValue<UpcomingLeaveResponse?>>(
      (ref) => UpcomingLeaveNotifier(
    ref.read(upcomingLeaveRepositoryProvider),
  ),
);

class UpcomingLeaveNotifier
    extends StateNotifier<AsyncValue<UpcomingLeaveResponse?>> {
  final UpcomingLeaveRepository _repo;

  CancelToken? _cancelToken;

  UpcomingLeaveNotifier(this._repo) : super(const AsyncData(null));

  Future<void> loadUpcomingLeaves({
    int page = 1,
    int limit = 10,
  }) async {
    if (state.isLoading && page != 1) return;

    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    if (page == 1 && state.value == null) {
      state = const AsyncLoading();
    }

    try {
      log("Fetching upcoming leaves | page=$page", name: "UpcomingLeave");

      final response = await _repo.fetchUpcomingLeaves(
        page: page,
        limit: limit,
        cancelToken: _cancelToken,
      );

      state = AsyncData(response);
    } catch (e, st) {
      if (e is DioException && e.type == DioExceptionType.cancel) return;

      log(
        "Upcoming leave error: $e",
        name: "UpcomingLeave",
        error: e,
        stackTrace: st,
      );

      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncData(null);
    await loadUpcomingLeaves(page: 1);
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }
}
