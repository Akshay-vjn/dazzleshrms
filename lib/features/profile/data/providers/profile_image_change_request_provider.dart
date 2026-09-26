import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile_image_change_request.dart';
import '../repo/profile_image_change_request_repo.dart';

final profileImageChangeRequestRepositoryProvider =
    Provider<ProfileImageChangeRequestRepository>((ref) {
      return ProfileImageChangeRequestRepository();
    });

final profileImageChangeRequestsProvider =
    StateNotifierProvider<
      ProfileImageChangeRequestsNotifier,
      AsyncValue<List<ProfileImageChangeRequest>>
    >((ref) {
      return ProfileImageChangeRequestsNotifier(
        ref.read(profileImageChangeRequestRepositoryProvider),
      );
    });

class ProfileImageChangeRequestsNotifier
    extends StateNotifier<AsyncValue<List<ProfileImageChangeRequest>>> {
  ProfileImageChangeRequestsNotifier(this._repository)
    : super(const AsyncValue.loading());

  final ProfileImageChangeRequestRepository _repository;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _repository.fetchPendingRequests());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<String> approve(int requestId) async {
    final message = await _repository.approve(requestId);
    _removeRequest(requestId);
    return message;
  }

  Future<String> reject(int requestId) async {
    final message = await _repository.reject(requestId);
    _removeRequest(requestId);
    return message;
  }

  void _removeRequest(int requestId) {
    final requests = state.valueOrNull;
    if (requests == null) return;
    state = AsyncValue.data(
      requests.where((request) => request.requestId != requestId).toList(),
    );
  }
}
