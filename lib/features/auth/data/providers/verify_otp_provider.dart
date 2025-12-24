import 'package:dazzleshrms/features/auth/data/models/verify_otp_model.dart';
import 'package:dazzleshrms/features/auth/data/providers/auth_provider.dart';
import 'package:dazzleshrms/features/auth/data/repo/auth_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final verifyOtpProvider =
StateNotifierProvider<VerifyOtpNotifier, AsyncValue<VerifyOtpModel?>>(
  (ref) => VerifyOtpNotifier(ref.read(authRepositoryProvider)),
);

class VerifyOtpNotifier
    extends StateNotifier<AsyncValue<VerifyOtpModel?>> {
  final AuthRepository _repo;

  VerifyOtpNotifier(this._repo) : super(const AsyncData(null));

  Future<void> verifyOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    state = const AsyncLoading();
    try {
      final response = await _repo.verifyOtp(
        mobileNumber: mobileNumber,
        otp: otp,
      );
      state = AsyncData(response);
    } catch (e, st) {
      state = AsyncError(e.toString(), st);
    }
  }
}
