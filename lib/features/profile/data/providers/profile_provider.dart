import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile_response.dart';
import '../repo/profile_repo.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<ProfileData?>>(
  (ref) => ProfileNotifier(ref.read(profileRepositoryProvider)),
);

class ProfileNotifier extends StateNotifier<AsyncValue<ProfileData?>> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository)
      : super(const AsyncValue.loading());

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.fetchProfile();
      state = AsyncValue.data(response.data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}


