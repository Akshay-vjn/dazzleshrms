import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../data/models/attendance_qr_model.dart';
import '../data/repo/attendance_qr_repo.dart';

class AttendanceQrScan extends StatefulWidget {
  const AttendanceQrScan({super.key});
  @override
  State<AttendanceQrScan> createState() => _AttendanceQrScanState();
}
class _AttendanceQrScanState extends State<AttendanceQrScan> {
  bool _isProcessing = false;
  final MobileScannerController _controller =
  MobileScannerController(facing: CameraFacing.front);
  final AttendanceQrRepo _repository = AttendanceQrRepo();
  String _statusText = 'Align the QR code inside the frame';
  String? _lastScannedValue;
  DateTime? _lastScannedAt;
  static const Duration _scanCooldown = Duration(milliseconds: 700);
  bool _loadingDialogShown = false;
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

    _handleCheckIn(value);
  }

  Future<void> _handleCheckIn(String qrData) async {
    try {
      await _controller.stop();

      if (mounted) {
        _loadingDialogShown = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      final AttendanceQrResponse response =
          await _repository.scanQr(qrData: qrData);

      if (!mounted) return;
      if (_loadingDialogShown && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _loadingDialogShown = false;

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
        if (_loadingDialogShown && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        _loadingDialogShown = false;

        final String message = e is DioException &&
                e.response?.data is Map &&
                (e.response!.data as Map)['message'] != null
            ? (e.response!.data as Map)['message'].toString()
            : 'Scan failed. Please try again.';

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
        await _controller.start();
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
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.white.withOpacity(0.85)),
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
                            math.min(constraints.maxWidth, constraints.maxHeight) * 0.7;
                        final left =
                            (constraints.maxWidth - size) / 2;
                        final top =
                            (constraints.maxHeight - size) / 2;

                        return Stack(
                          children: [
                            Container(
                              color: Colors.black.withOpacity(0.45),
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
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

