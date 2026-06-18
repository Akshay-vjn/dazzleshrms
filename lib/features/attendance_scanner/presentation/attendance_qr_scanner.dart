import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pinput/pinput.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import 'package:dazzleshrms/core/storage/session_storage.dart';
import '../data/models/attendance_qr_model.dart';
import '../data/repo/attendance_qr_repo.dart';

class AttendanceQrScan extends StatefulWidget {
  const AttendanceQrScan({super.key});
  @override
  State<AttendanceQrScan> createState() => _AttendanceQrScanState();
}

class _AttendanceQrScanState extends State<AttendanceQrScan> {
  bool _isProcessing = false;
  final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.front,
  );
  final AttendanceQrRepo _repository = AttendanceQrRepo();
  String _statusText = 'Align the QR code inside the frame';
  String? _lastScannedValue;
  DateTime? _lastScannedAt;
  static const Duration _scanCooldown = Duration(milliseconds: 700);
  bool _loadingDialogShown = false;
  bool _controllerDisposed = false;

  Future<void> _stopScanner() async {
    if (_controllerDisposed) return;
    try {
      await _controller.stop();
    } on MobileScannerException catch (_) {
      // Ignore scanner lifecycle errors when the widget is being torn down.
    }
  }

  Future<void> _startScanner() async {
    if (!mounted || _controllerDisposed) return;
    try {
      await _controller.start();
    } on MobileScannerException catch (_) {
      // Ignore scanner lifecycle errors when the widget is no longer active.
    }
  }

  void _closeLoadingDialog() {
    if (!mounted || !_loadingDialogShown) return;
    Navigator.of(context, rootNavigator: true).pop();
    _loadingDialogShown = false;
  }

  String _resolveErrorMessage(Object error) {
    if (error is DioException) {
      final responseData = error.response?.data;
      if (responseData is Map && responseData['message'] != null) {
        return responseData['message'].toString();
      }

      if (error.message != null && error.message!.trim().isNotEmpty) {
        return error.message!.trim();
      }
    }

    return 'Failed. Please try again.';
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    if (capture.barcodes.isEmpty) return;
    final barcode = capture.barcodes.first;
    final value = barcode.rawValue;
    if (value == null || value.isEmpty) return;
    final now = DateTime.now();
    final lastAt = _lastScannedAt;
    if (_lastScannedValue == value &&
        lastAt != null &&
        now.difference(lastAt) < _scanCooldown) {
      return;
    }

    _lastScannedValue = value;
    _lastScannedAt = now;

    setState(() {
      _isProcessing = true;
      _statusText = 'Processing...';
    });

    _handleScan(qrData: value);
  }

  Future<void> _handleScan({String? qrData, int? sessionPin}) async {
    try {
      if (qrData != null) {
        await _stopScanner();
      }

      if (mounted) {
        _loadingDialogShown = true;
        showDialog(
          context: context,
          useRootNavigator: true,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
      }

      final AttendanceQrResponse response = await _repository.scanQr(
        qrData: qrData,
        sessionPin: sessionPin,
      );

      if (!mounted) return;
      _closeLoadingDialog();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: response.error ? Colors.red : Colors.green,
        ),
      );

      setState(() {
        _statusText = response.message;
      });
    } catch (e) {
      if (mounted) {
        _closeLoadingDialog();
        final String message = _resolveErrorMessage(e);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );

        setState(() {
          _statusText = message;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
        await Future<void>.delayed(_scanCooldown);
        if (mounted) {
          setState(() {
            _statusText = 'Align the QR code inside the frame';
          });
        }
        await _startScanner();
      }
    }
  }

  void _showPinEntry() async {
    await _stopScanner();
    if (!mounted) return;

    final pinController = TextEditingController();

    final String? pin = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _PinDialog(pinController: pinController),
    );

    if (pin != null && pin.length == 6) {
      final sessionPin = int.tryParse(pin);
      if (sessionPin != null) {
        setState(() {
          _isProcessing = true;
          _statusText = 'Processing...';
        });
        await _handleScan(sessionPin: sessionPin);
        return;
      }
    }

    // User cancelled or invalid — resume scanner
    if (mounted && !_isProcessing) {
      await _startScanner();
    }
  }

  void _showLogoutDialog() async {
    await _stopScanner();
    if (!mounted) return;

    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.statusError),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await SessionStorage.clearSession();
      if (!mounted) return;
      context.goNamed('login');
    } else {
      if (mounted) {
        await _startScanner();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Attendance Scanner',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Please show your attendance QR towards the camera.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Platform.isAndroid
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi),
                            child: MobileScanner(
                              controller: _controller,
                              fit: BoxFit.cover,
                              onDetect: _onDetect,
                            ),
                          )
                        : MobileScanner(
                            controller: _controller,
                            fit: BoxFit.cover,
                            onDetect: _onDetect,
                          ),
                  ),
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size =
                            math.min(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ) *
                            0.7;
                        final left = (constraints.maxWidth - size) / 2;
                        final top = (constraints.maxHeight - size) / 2;

                        return Stack(
                          children: [
                            Container(
                              color: Colors.black.withValues(alpha: 0.45),
                            ),
                            Positioned(
                              left: left,
                              top: top,
                              width: size,
                              height: size,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  // Status text
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 32,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _statusText,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_isProcessing)
                          const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Enter PIN button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: GestureDetector(
                onTap: _isProcessing ? null : _showPinEntry,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white38, width: 1.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.dialpad, color: Colors.white70, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Enter PIN',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controllerDisposed = true;
    _controller.dispose();
    super.dispose();
  }
}

// ─── PIN Entry Dialog ──────────────────────────────────────────────────────

class _PinDialog extends StatefulWidget {
  final TextEditingController pinController;

  const _PinDialog({required this.pinController});

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  static const int _pinLength = 6;

  @override
  void initState() {
    super.initState();
    widget.pinController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final pinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
    );

    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter Session PIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Type the PIN shown on the employee\'s screen',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 28),
            Pinput(
              controller: widget.pinController,
              length: _pinLength,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofocus: true,
              defaultPinTheme: pinTheme,
              focusedPinTheme: pinTheme.copyWith(
                decoration: pinTheme.decoration!.copyWith(
                  border: Border.all(color: AppTheme.PrimaryColor, width: 2),
                ),
              ),
              submittedPinTheme: pinTheme.copyWith(
                decoration: pinTheme.decoration!.copyWith(
                  color: AppTheme.PrimaryColor.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppTheme.PrimaryColor.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
              ),
              onCompleted: (pin) {
                Navigator.pop(context, pin);
              },
            ),
          ],
        ),
      ),
    );
  }
}
