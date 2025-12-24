import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';

import '../data/models/send_otp_model.dart';
import '../data/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final mobileCtrl = TextEditingController();

  void _onGetOtp() {
    final mobile = mobileCtrl.text.trim();

    if (mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid 10-digit mobile number"),
        ),
      );
      return;
    }

    ref.read(sendOtpProvider.notifier).sendOtp(mobile);
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(sendOtpProvider);

    ref.listen<AsyncValue<SendOtpModel?>>(
      sendOtpProvider,
          (previous, next) {
        next.when(
          data: (res) {
            if (res != null && res.error == false) {
              context.pushNamed(
                'otp',
                extra: mobileCtrl.text.trim(),
              );
            }
          },
          loading: () {},
          error: (err, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(err.toString())),
            );
          },
        );
      },
    );

    return Scaffold(
      body: Column(
        children: [
          // TOP
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "DAZZLES",
                      style: TextStyle(
                        fontFamily: 'Dazzles',
                        fontSize: 48,
                        letterSpacing: 6,
                        color: AppTheme.PrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "MYSORE | BANGALORE",
                      style: TextStyle(
                        fontFamily: 'Dazzles',
                        fontSize: 12,
                        letterSpacing: 4,
                        color: AppTheme.PrimaryColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // BOTTOM
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back",
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Login to Dazzles HRMS",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),

                  TextField(
                    controller: mobileCtrl,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: const InputDecoration(
                      labelText: "Mobile Number",
                      prefixIcon: Icon(Icons.phone_android_rounded),
                      prefixText: "+91 ",
                      counterText: "",
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: otpState.isLoading ? null : _onGetOtp,
                      style: FilledButton.styleFrom(
                        // Use black text in dark theme as you requested earlier
                        foregroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.black
                                : null,
                      ),
                      child: otpState.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Get OTP",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
