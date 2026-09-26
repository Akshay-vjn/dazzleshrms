import 'dart:io';
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

  ProfileNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.fetchProfile();
      state = AsyncValue.data(response.data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refreshProfile() async {
    try {
      final response = await _repository.fetchProfile();
      state = AsyncValue.data(response.data);
    } catch (_) {
      // Keep the current profile visible if a silent refresh fails.
    }
  }

  Future<String> updateProfileImage(File imageFile) async {
    try {
      final newImagePath = await _repository.updateProfileImage(imageFile);

      final currentData = state.valueOrNull;
      if (currentData != null) {
        state = AsyncValue.data(
          currentData.copyWith(profileImage: newImagePath),
        );
      }

      // The profile endpoint is the source of truth for future changes.
      await refreshProfile();
      return newImagePath;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> requestProfileImageChange() async {
    final message = await _repository.requestProfileImageChange();
    await refreshProfile();
    return message;
  }
}
