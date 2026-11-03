import 'package:dazzleshrms/core/app_theme/app_visuals.dart';
import 'package:dazzleshrms/core/app_theme/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dazzleshrms/core/app_theme/glass_surface.dart';

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

    ref.listen<AsyncValue<SendOtpModel?>>(sendOtpProvider, (previous, next) {
      next.when(
        data: (res) {
          if (res != null && res.error == false) {
            context.pushNamed('otp', extra: mobileCtrl.text.trim());
          }
        },
        loading: () {},
        error: (err, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(err.toString())));
        },
      );
    });

    final colors = AppVisuals.of(context);
    return AppScaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.maxHeight - 48).clamp(
                  0,
                  double.infinity,
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 24),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'DAZZLES',
                          style: TextStyle(
                            fontFamily: 'Dazzles',
                            fontSize: 48,
                            letterSpacing: 6,
                            color: colors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(height: 40),
                      GlassSurface(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Login to Dazzles HRMS',
                              style: TextStyle(color: colors.muted),
                            ),
                            const SizedBox(height: 28),
                            TextField(
                              controller: mobileCtrl,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) {
                                if (!otpState.isLoading) _onGetOtp();
                              },
                              maxLength: 10,
                              decoration: const InputDecoration(
                                labelText: 'Mobile Number',
                                prefixIcon: Icon(Icons.phone_android_rounded),
                                prefixText: '+91 ',
                                counterText: '',
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: otpState.isLoading
                                    ? null
                                    : _onGetOtp,
                                child: otpState.isLoading
                                    ? SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colors.muted,
                                        ),
                                      )
                                    : const Text('Get OTP'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    mobileCtrl.dispose();
    super.dispose();
  }
}
