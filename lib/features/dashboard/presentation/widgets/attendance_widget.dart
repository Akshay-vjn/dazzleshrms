import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import '../../data/repo/attendanceqr_repo.dart';
import '../../data/models/attendance_qr_response.dart';
import '../../data/models/attendance_qr_status_response.dart';

class AttendanceWidget extends StatefulWidget {
  final AnimationController animationController;
  final double intervalStart;
  final String? attendanceStatus;

  const AttendanceWidget({
    super.key,
    required this.animationController,
    this.intervalStart = 0.0,
    this.attendanceStatus,
  });

  @override
  State<AttendanceWidget> createState() => _AttendanceWidgetState();
}

class _AttendanceWidgetState extends State<AttendanceWidget> {
  final AttendanceqrRepo _repository = AttendanceqrRepo();
  late String _attendanceStatus;
  final AudioPlayer _audioPlayer = AudioPlayer();

  String _normalizeStatus(String? status) {
    final normalized = (status ?? '').trim().toUpperCase();
    return normalized.isEmpty ? 'OFFLINE' : normalized;
  }

  bool get _isActive => _attendanceStatus == 'ACTIVE';

  @override
  void initState() {
    super.initState();
    _attendanceStatus = _normalizeStatus(widget.attendanceStatus);
  }

  Future<void> _playSuccessSound(bool isCheckIn) async {
    try {
      final soundPath = 'audio/notification.mp3';
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (_) {
      // If sound fails, silently ignore so UI flow is not affected.
    }
  }

  @override
  void didUpdateWidget(covariant AttendanceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _normalizeStatus(widget.attendanceStatus);
    if (next != _attendanceStatus) {
      _attendanceStatus = next;
    }
  }

  Future<void> _handleAttendance(BuildContext context, bool isCheckIn) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

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
          _showError(context, 'Location permission is permanently denied. Please enable it in settings.');
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      debugPrint('📍 Current Location:');
      debugPrint('   Latitude:  ${position.latitude}');
      debugPrint('   Longitude: ${position.longitude}');
      debugPrint('   Accuracy:  ${position.accuracy} meters');

      final qrResponse = await _repository.generateQr(
        method: isCheckIn ? 'CHECKIN' : 'CHECKOUT',
        lat: position.latitude,
        lng: position.longitude,
        accuracy: position.accuracy,
      );

      if (context.mounted) {
        Navigator.pop(context);

        _showQrDialog(context, isCheckIn, qrResponse);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        _showError(context, e.toString());
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.statusError,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showQrDialog(
      BuildContext context,
      bool isCheckIn,
      AttendanceQrResponse qrResponse,
      ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _QrDialog(
        isCheckIn: isCheckIn,
        qrResponse: qrResponse,
        onSuccess: () {
          setState(() {
            _attendanceStatus = isCheckIn ? 'ACTIVE' : 'OFFLINE';
          });
          _playSuccessSound(isCheckIn);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isCheckIn
                    ? "✓ Checked in successfully"
                    : "✓ Checked out successfully",
              ),
              backgroundColor: AppTheme.statusSuccess,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final textColor = isDark ? Colors.white : Colors.black.withOpacity(0.85);

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: widget.animationController,
          curve: Interval(
            widget.intervalStart,
            widget.intervalStart + 0.1,
            curve: Curves.easeOut,
          ),
        ),
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: widget.animationController,
          curve: Interval(
            widget.intervalStart,
            widget.intervalStart + 0.1,
            curve: Curves.easeOut,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppTheme.PrimaryColor.withOpacity(isDark ? 0.35 : 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.45 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.PrimaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.fingerprint,
                      color: AppTheme.PrimaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Attendance",
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Text(
                        //   _attendanceStatus,
                        //   style: theme.textTheme.bodyMedium?.copyWith(
                        //     color: textColor.withOpacity(0.6),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  // Status Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: (_isActive
                          ? AppTheme.statusSuccess
                          : Colors.grey)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isActive
                                ? AppTheme.statusSuccess
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _attendanceStatus,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _isActive
                                ? AppTheme.statusSuccess
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Action Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _handleAttendance(context, !_isActive),
                  style: FilledButton.styleFrom(
                    backgroundColor: _isActive
                        ? AppTheme.statusError
                        : AppTheme.statusSuccess,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(
                    _isActive ? Icons.logout_rounded : Icons.qr_code_2,
                    size: 20,
                  ),
                  label: Text(
                    _isActive ? "Check Out" : "Check In",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

class _QrDialog extends StatefulWidget {
  final bool isCheckIn;
  final AttendanceQrResponse qrResponse;
  final VoidCallback onSuccess;

  const _QrDialog({
    required this.isCheckIn,
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
  final AttendanceqrRepo _repo = AttendanceqrRepo();

  @override
  void initState() {
    super.initState();

    debugPrint('🧾 qrSessionId from response: ${widget.qrResponse.data.qrSessionId}');

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

    final qrId = widget.qrResponse.data.qrSessionId;
    debugPrint('📡 Starting QR status polling for qrId=$qrId');
    _statusTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final AttendanceQrStatusResponse resp =
            await _repo.getQrStatus(qrId: qrId);

        if (!mounted) return;

        if (!resp.error && resp.data.status != 'PENDING') {
          _statusTimer?.cancel();
          _countdownTimer.cancel();

          if (mounted) {
            widget.onSuccess();
          }
        }
      } catch (_) {
      }
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
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.PrimaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.isCheckIn ? Icons.login : Icons.logout,
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
                        widget.isCheckIn ? "Check In" : "Check Out",
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
            // Buttons
            // Row(
            //   children: [
            //     Expanded(
            //       child: OutlinedButton(
            //         onPressed: () => Navigator.pop(context),
            //         style: OutlinedButton.styleFrom(
            //           padding: const EdgeInsets.symmetric(vertical: 14),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(12),
            //           ),
            //         ),
            //         child: const Text(
            //           "Cancel",
            //           style: TextStyle(
            //             fontSize: 15,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ),
            //     ),
            //     const SizedBox(width: 12),
            //     Expanded(
            //       child: FilledButton(
            //         onPressed: widget.onSuccess,
            //         style: FilledButton.styleFrom(
            //           backgroundColor: AppTheme.statusSuccess,
            //           padding: const EdgeInsets.symmetric(vertical: 14),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(12),
            //           ),
            //         ),
            //         child: const Text(
            //           "Done",
            //           style: TextStyle(
            //             fontSize: 15,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}