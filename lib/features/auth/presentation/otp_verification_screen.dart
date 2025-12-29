import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import 'package:dazzleshrms/core/storage/session_storage.dart';
import 'package:dazzleshrms/core/permissions/permission_provider.dart';
import '../data/providers/verify_otp_provider.dart';
import '../data/providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String mobileNumber;

  const OtpVerificationScreen({super.key, required this.mobileNumber});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends ConsumerState<OtpVerificationScreen> {
  static const int otpLength = 6;

  final List<TextEditingController> _controllers =
  List.generate(otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(otpLength, (_) => FocusNode());

  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      }
    });
  }

  void _resendOtp() {
    if (!_canResend) return;

    ref.read(sendOtpProvider.notifier).sendOtp(widget.mobileNumber);
    _startTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("OTP Resent Successfully")),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onVerify() {
    final otp = _controllers.map((e) => e.text).join();

    if (otp.length != otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a valid $otpLength-digit code"),
        ),
      );
      return;
    }

    ref.read(verifyOtpProvider.notifier).verifyOtp(
      mobileNumber: widget.mobileNumber,
      otp: otp,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verifyState = ref.watch(verifyOtpProvider);

    /// ✅ HANDLE OTP RESULT
    ref.listen(verifyOtpProvider, (previous, next) {
      next.whenOrNull(
        data: (res) async {
          if (res == null || res.error) return;

          /// 🔥 SAVE SESSION + PERMISSIONS
          await SessionStorage.saveSession(
            token: res.data.token,
            refreshToken: res.data.refreshToken,
            employeeId: res.data.employee.employeeId,
            employeeName: res.data.employee.employeeName,
            storeId: res.data.employee.storeId,
            permissions: res.data.permissions, // ✅ IMPORTANT
          );

          /// 🔥 UPDATE PERMISSIONS IMMEDIATELY
          ref.read(permissionProvider.notifier).setPermissions(res.data.permissions);

          if (!mounted) return;
          context.goNamed('home');
        },
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err.toString())),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: AppTheme.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Text(
                "Verification Code",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "We have sent the verification code to\n${widget.mobileNumber}",
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 48),

              /// OTP INPUTS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(otpLength, (index) {
                  return SizedBox(
                    width: 52,
                    height: 60,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.PrimaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (value.isNotEmpty && index < otpLength - 1) {
                          FocusScope.of(context)
                              .requestFocus(_focusNodes[index + 1]);
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context)
                              .requestFocus(_focusNodes[index - 1]);
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 40),

              /// VERIFY BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: verifyState.isLoading ? null : _onVerify,
                  child: verifyState.isLoading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    "Verify",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Didn't receive code? ",
                            style: theme.textTheme.bodyMedium),
                        TextButton(
                          onPressed: _canResend ? _resendOtp : null,
                          child: Text(
                            "Resend",
                            style: TextStyle(
                              color: _canResend
                                  ? AppTheme.PrimaryColor
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!_canResend)
                      Text(
                        "Resend code in 00:${_secondsRemaining.toString().padLeft(2, '0')}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
