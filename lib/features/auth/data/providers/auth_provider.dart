import 'package:dazzleshrms/features/auth/data/models/send_otp_model.dart';
import 'package:dazzleshrms/features/auth/data/repo/auth_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final sendOtpProvider =
StateNotifierProvider<SendOtpNotifier, AsyncValue<SendOtpModel?>>(
  (ref) => SendOtpNotifier(ref.read(authRepositoryProvider)),
);

class SendOtpNotifier extends StateNotifier<AsyncValue<SendOtpModel?>> {
  final AuthRepository _repository;

  SendOtpNotifier(this._repository)
      : super(const AsyncData(null));

  Future<void> sendOtp(String mobileNumber) async {
    state = const AsyncLoading();
    try {
      final response =
          await _repository.sendOtp(mobileNumber: mobileNumber);
      state = AsyncData(response);
    } catch (e, st) {
      state = AsyncError(e.toString(), st);
    }
  }
}
