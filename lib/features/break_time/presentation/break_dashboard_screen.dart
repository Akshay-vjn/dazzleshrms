import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../dashboard/data/models/attendance_qr_response.dart';
import '../data/models/break_history_response.dart';
import '../data/models/break_status_response.dart';
import '../data/repo/break_history_repo.dart';
import '../data/repo/breakqr_repo.dart';

class BreakDashboardScreen extends StatefulWidget {
  const BreakDashboardScreen({super.key});

  @override
  State<BreakDashboardScreen> createState() => _BreakDashboardScreenState();
}

class _BreakDashboardScreenState extends State<BreakDashboardScreen> {
  final BreakHistoryRepo _historyRepo = BreakHistoryRepo();
  final BreakqrRepo _breakRepo = BreakqrRepo();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _timeFormat = DateFormat('hh:mm a');

  bool _loading = true;
  bool _loadingHistory = false;
  bool _loadingBreakStatus = false;
  String? _error;
  BreakHistoryData? _history;
  late DateTime _selectedDate;

  // Break status
  bool _isOnBreak = false;
  String _currentAction = 'BREAK_OUT';

  String get _selectedDateStr => _dateFormat.format(_selectedDate);
  bool get _isToday =>
      _dateFormat.format(_selectedDate) == _dateFormat.format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _historyRepo.getBreakHistory(date: _selectedDateStr),
        _breakRepo.getBreakStatus(),
      ]);

      if (!mounted) return;
      final history = results[0] as BreakHistoryResponse;
      final status = results[1] as BreakStatusResponse;

      setState(() {
        _history = history.data;
        _isOnBreak = status.data.isOnBreak;
        _currentAction = status.data.currentAction;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadHistory() async {
    setState(() => _loadingHistory = true);
    try {
      final history = await _historyRepo.getBreakHistory(
        date: _selectedDateStr,
      );
      if (!mounted) return;
      setState(() {
        _history = history.data;
        _loadingHistory = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingHistory = false);
    }
  }

  Future<void> _loadBreakStatus() async {
    try {
      final status = await _breakRepo.getBreakStatus();
      if (!mounted) return;
      setState(() {
        _isOnBreak = status.data.isOnBreak;
        _currentAction = status.data.currentAction;
      });
    } catch (_) {}
  }

  Future<void> _handleBreak(BuildContext context) async {
    final bool isBreakOut = !_isOnBreak;
    final String method = isBreakOut ? 'BREAK_OUT' : 'BREAK_IN';

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

      final qrResponse = await _breakRepo.generateQr(
        method: method,
        lat: position.latitude,
        lng: position.longitude,
        accuracy: position.accuracy,
      );

      if (context.mounted) {
        Navigator.pop(context); // Pop loading

        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => BreakQrDialog(
            isBreakOut: isBreakOut,
            qrResponse: qrResponse,
            onCompleted: () async {
              if (mounted) {
                setState(() {
                  _isOnBreak = isBreakOut;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isBreakOut
                          ? '✓ Break started successfully'
                          : '✓ Break ended successfully',
                    ),
                    backgroundColor: AppTheme.statusSuccess,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                // Refresh history and status after break action
                _loadHistory();
                _loadBreakStatus();
              }
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

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.statusError,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final theme = Theme.of(context);
        final actionColor = theme.brightness == Brightness.light
            ? AppTheme.textPrimaryLight
            : AppTheme.PrimaryColor;

        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppTheme.PrimaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: actionColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadHistory();
    }
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '$mins min';
    if (mins == 0) return '$hours hr';
    return '$hours hr $mins min';
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '--';
    return _timeFormat.format(dateTime.toLocal());
  }

  Widget _buildBreakActionButton(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final textColor = isDark ? Colors.white : Colors.black.withValues(alpha: 0.85);
    final buttonColor = _isOnBreak ? AppTheme.statusSuccess : AppTheme.statusWarning;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppTheme.PrimaryColor.withValues(alpha: isDark ? 0.35 : 0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
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
                    color: AppTheme.PrimaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.coffee,
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
                        "Break",
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                    color: buttonColor.withValues(alpha: 0.15),
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
                          color: buttonColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isOnBreak ? 'ON BREAK' : 'ACTIVE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: buttonColor,
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
              child: _TonalButton(
                onPressed:
                    _loadingBreakStatus ? null : () => _handleBreak(context),
                color: buttonColor,
                icon: _isOnBreak
                    ? Icons.input
                    : Icons.output,
                label: _loadingBreakStatus
                    ? "Loading..."
                    : (_isOnBreak ? "Break In" : "Break Out"),
                isLoading: _loadingBreakStatus,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerButton(ThemeData theme) {
    return TextButton.icon(
      onPressed: _pickDate,
      icon: const Icon(Icons.calendar_month_rounded, size: 20),
      label: Text(
        _isToday
            ? 'Today'
            : DateFormat('dd MMM').format(_selectedDate),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: theme.brightness == Brightness.light
            ? AppTheme.textPrimaryLight
            : AppTheme.PrimaryColor,
        backgroundColor: theme.brightness == Brightness.light
            ? AppTheme.PrimaryColor.withValues(alpha: 0.18)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        minimumSize: const Size(0, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return RefreshIndicator(
        onRefresh: _loadDashboard,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(
              height: 400,
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return RefreshIndicator(
        onRefresh: _loadDashboard,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 400,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final history = _history;
    final breaks = history?.breaks ?? [];

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Break In/Out button card
            _buildBreakActionButton(theme),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Break History',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black.withValues(alpha: 0.85),
                  ),
                ),
                _buildDatePickerButton(theme),
              ],
            ),
            const SizedBox(height: 16),

            if (_loadingHistory)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (breaks.isEmpty)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: const Center(
                  child: Text(
                    'No break history',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              )
            else
              ...breaks.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BreakHistoryTile(
                    item: item,
                    timeFormat: _formatTime,
                    minutesFormat: _formatMinutes,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: _buildBody(theme),
    );
  }
}

class BreakQrDialog extends StatefulWidget {
  final bool isBreakOut;
  final AttendanceQrResponse qrResponse;
  final VoidCallback onCompleted;

  const BreakQrDialog({
    super.key,
    required this.isBreakOut,
    required this.qrResponse,
    required this.onCompleted,
  });

  @override
  State<BreakQrDialog> createState() => _BreakQrDialogState();
}

class _BreakQrDialogState extends State<BreakQrDialog> {
  final BreakqrRepo _repo = BreakqrRepo();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _countdownTimer;
  Timer? _statusTimer;
  late int _secondsLeft;
  late final Uint8List _imageBytes;

  @override
  void initState() {
    super.initState();
    final qrImageBase64 = widget.qrResponse.data.qrImage;
    _imageBytes = base64Decode(qrImageBase64.split(',').last);

    final expiresAt = widget.qrResponse.data.expiresAt;
    final remaining =
        (expiresAt - DateTime.now().millisecondsSinceEpoch) / 1000;
    _secondsLeft = remaining > 0 ? remaining.ceil() : 60;

    _startCountdown();
    _startStatusPolling();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _statusTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR code expired. Please try again.'),
            backgroundColor: AppTheme.statusError,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void _startStatusPolling() {
    _statusTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final response = await _repo.getBreakStatus();
        if (!mounted || response.error) return;

        if (response.data.isOnBreak == widget.isBreakOut) {
          timer.cancel();
          _countdownTimer?.cancel();
          await _playSuccessSound();
          if (!mounted) return;
          widget.onCompleted();
        }
      } catch (_) {}
    });
  }

  Future<void> _playSuccessSound() async {
    try {
      await _audioPlayer.play(AssetSource('audio/notification.mp3'));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
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
                    color: AppTheme.PrimaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.isBreakOut
                        ? Icons.logout_rounded
                        : Icons.login_rounded,
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
                        widget.isBreakOut ? 'Break Out' : 'Break In',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Show this QR to the scanner',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
            if (widget.qrResponse.data.sessionPin != null) ...[
              const SizedBox(height: 12),
              Text(
                'PIN : ${widget.qrResponse.data.sessionPin}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color:
                    (_secondsLeft <= 10
                            ? AppTheme.statusError
                            : AppTheme.PrimaryColor)
                        .withValues(alpha: 0.1),
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
                      color: _secondsLeft <= 10
                          ? AppTheme.statusError
                          : AppTheme.PrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakHistoryTile extends StatelessWidget {
  final BreakHistoryItem item;
  final String Function(DateTime?) timeFormat;
  final String Function(int) minutesFormat;

  const _BreakHistoryTile({
    required this.item,
    required this.timeFormat,
    required this.minutesFormat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 7),
                Text('Date: ${item.date}', style: theme.textTheme.bodyMedium),
                Text(
                  'Time: ${timeFormat(item.breakOutTime)} - ${timeFormat(item.breakInTime)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.statusSuccess.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              minutesFormat(item.totalMinutes),
              style: const TextStyle(
                color: AppTheme.statusSuccess,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TonalButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Color color;
  final IconData icon;
  final String label;
  final bool isLoading;

  const _TonalButton({
    required this.onPressed,
    this.onLongPress,
    required this.color,
    required this.icon,
    required this.label,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null;
    final Color effectiveColor = disabled ? color.withValues(alpha: 0.4) : color;
    final Color foregroundColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : effectiveColor;

    return Material(
      color: color.withValues(alpha: disabled ? 0.18 : 0.36),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: disabled ? 0.35 : 0.68),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(effectiveColor),
                      ),
                    )
                  : Icon(icon, size: 20, color: foregroundColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
