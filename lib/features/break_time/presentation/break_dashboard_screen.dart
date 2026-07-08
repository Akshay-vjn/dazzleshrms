import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../dashboard/data/models/attendance_qr_response.dart';
import '../data/models/break_history_response.dart';
import '../data/repo/break_history_repo.dart';
import '../data/repo/breakqr_repo.dart';

class BreakDashboardScreen extends StatefulWidget {
  const BreakDashboardScreen({super.key});

  @override
  State<BreakDashboardScreen> createState() => _BreakDashboardScreenState();
}

class _BreakDashboardScreenState extends State<BreakDashboardScreen> {
  final BreakHistoryRepo _historyRepo = BreakHistoryRepo();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayDateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _timeFormat = DateFormat('hh:mm a');

  bool _loading = true;
  bool _loadingHistory = false;
  String? _error;
  BreakHistoryData? _history;
  late DateTime _selectedDate;

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
      final history = await _historyRepo.getBreakHistory(date: _selectedDateStr);

      if (!mounted) return;
      setState(() {
        _history = history.data;
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
      final history = await _historyRepo.getBreakHistory(date: _selectedDateStr);
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.PrimaryColor,
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
            if (_loadingHistory)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              if (breaks.isEmpty)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
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
        title: const Text('Break History'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isToday ? 'Today' : _displayDateFormat.format(_selectedDate),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.6),
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
                color: (_secondsLeft <= 10
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
                Text(
                  'Date: ${item.date}',
                  style: theme.textTheme.bodyMedium,
                ),
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
