import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/app_theme/app_theme.dart';
import '../../dashboard/data/models/attendance_qr_response.dart';
import '../data/models/break_status_response.dart';
import '../data/repo/breakqr_repo.dart';

class BreakQR {
  static final BreakqrRepo _repository = BreakqrRepo();
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> _playSuccessSound() async {
    try {
      final soundPath = 'audio/notification.mp3';
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (_) {}
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.statusError,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Future<void> handleBreakIconClick(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final BreakStatusResponse statusResponse = await _repository.getBreakStatus();
      final String currentAction = statusResponse.data.currentAction;
      final bool isBreakOut = currentAction == 'BREAK_OUT';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (context.mounted) {
            Navigator.pop(context);
            _showError(context, 'Location permission is required');
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          Navigator.pop(context);
          _showError(context,
              'Location permission is permanently denied. Please enable it in settings.');
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final qrResponse = await _repository.generateQr(
        method: currentAction,
        lat: position.latitude,
        lng: position.longitude,
        accuracy: position.accuracy,
      );

      if (context.mounted) {
        Navigator.pop(context);

        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => _QrDialog(
            isBreakOut: isBreakOut,
            qrResponse: qrResponse,
            onSuccess: () {
              _playSuccessSound();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isBreakOut
                        ? "✓ Break started successfully"
                        : "✓ Break ended successfully",
                  ),
                  backgroundColor: AppTheme.statusSuccess,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        _showError(context, e.toString());
      }
    }
  }
}

class _QrDialog extends StatefulWidget {
  final bool isBreakOut;
  final AttendanceQrResponse qrResponse;
  final VoidCallback onSuccess;

  const _QrDialog({
    required this.isBreakOut,
    required this.qrResponse,
    required this.onSuccess,
  });

  @override
  State<_QrDialog> createState() => _QrDialogState();
}

class _QrDialogState extends State<_QrDialog> {
  late Timer _countdownTimer;
  Timer? _statusTimer;
  late int _secondsLeft;
  late final Uint8List _imageBytes;
  final BreakqrRepo _repo = BreakqrRepo();

  @override
  void initState() {
    super.initState();

    final qrImageBase64 = widget.qrResponse.data.qrImage;
    final base64String = qrImageBase64.split(',').last;
    _imageBytes = base64Decode(base64String);

    final expiresAt = widget.qrResponse.data.expiresAt;
    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = (expiresAt - now) / 1000;
    _secondsLeft = remaining > 0 ? remaining.ceil() : 60;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('QR code expired. Please try again.'),
              backgroundColor: AppTheme.statusError,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });

    _statusTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final BreakStatusResponse resp = await _repo.getBreakStatus();

        if (!mounted) return;

        if (!resp.error) {
          final expectedIsOnBreak = widget.isBreakOut;
          if (resp.data.isOnBreak == expectedIsOnBreak) {
            _statusTimer?.cancel();
            _countdownTimer.cancel();

            if (mounted) {
              widget.onSuccess();
            }
          }
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    _statusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.PrimaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.isBreakOut ? Icons.free_breakfast : Icons.check_circle,
                    color: AppTheme.PrimaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isBreakOut ? "Break Out" : "Break In",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Show QR to scanner",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // QR Code
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.memory(
                _imageBytes,
                width: 220,
                height: 220,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            ),
            const SizedBox(height: 16),
            // Session PIN
            if (widget.qrResponse.data.sessionPin != null) ...[
              Text(
                'PIN : ${widget.qrResponse.data.sessionPin}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Timer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _secondsLeft <= 10
                    ? AppTheme.statusError.withOpacity(0.1)
                    : AppTheme.PrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: _secondsLeft <= 10
                        ? AppTheme.statusError
                        : AppTheme.PrimaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Expires in $_secondsLeft seconds',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _secondsLeft <= 10
                          ? AppTheme.statusError
                          : AppTheme.PrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
