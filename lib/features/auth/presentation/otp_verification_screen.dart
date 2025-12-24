import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import 'package:dazzleshrms/core/storage/session_storage.dart';
import '../data/providers/verify_otp_provider.dart';

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
  final List<TextEditingController> _controllers = List.generate(otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(otpLength, (_) => FocusNode());

  @override
  void dispose() {
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

    ref
        .read(verifyOtpProvider.notifier)
        .verifyOtp(mobileNumber: widget.mobileNumber, otp: otp);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verifyState = ref.watch(verifyOtpProvider);

    ref.listen(verifyOtpProvider, (previous, next) {
      next.when(
        data: (res) async {
          if (res != null && res.error == false) {
            await SessionStorage.saveSession(
              token: res.data.token,
              employeeId: res.data.employee.employeeId,
              employeeName: res.data.employee.employeeName,
              storeId: res.data.employee.storeId,
            );

            if (!mounted) return;

            context.goNamed('home');
          }
        },
        loading: () {},
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

              // OTP Inputs
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
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.dividerColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.dividerColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.PrimaryColor, width: 2),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          if (index < otpLength - 1) {
                            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                          } else {
                            // Last digit entered, hide keyboard or auto-submit
                            FocusScope.of(context).unfocus();
                          }
                        } else {
                          if (index > 0) {
                            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                          }
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: verifyState.isLoading ? null : _onVerify,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive code? ",
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Code resent!")),
                        );
                      },
                      child: const Text("Resend"),
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