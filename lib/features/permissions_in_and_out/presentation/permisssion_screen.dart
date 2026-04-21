import 'package:dio/dio.dart';
import 'package:dazzleshrms/core/api_config/api_config.dart';
import 'package:dazzleshrms/core/api_constants/api_constants.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import 'package:dazzleshrms/features/dashboard/presentation/widgets/dashboard_grid.dart';
import 'package:dazzleshrms/features/dashboard/presentation/widgets/dashboard_grid_item.dart';
import 'package:dazzleshrms/features/leave_management/presentation/widgets/permission_dialog.dart';
import 'package:dazzleshrms/features/permissions_in_and_out/presentation/permission_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PermisssionScreen extends StatefulWidget {
  const PermisssionScreen({super.key});

  @override
  State<PermisssionScreen> createState() => _PermisssionScreenState();
}

class _PermisssionScreenState extends State<PermisssionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Permissions"),
      ),
      body: PermissionDashboard(
        actions: DashboardGrid(
          animation: _controller,
          items: [
            DashboardGridItem(
              icon: Icons.qr_code_2_rounded,
              label: "In / Out",
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (_) => const PermissionDialog(),
                );
              },
              animation: _controller,
              intervalStart: 0.12,
              gradientStart: AppTheme.dTeal,
              gradientEnd: AppTheme.dGreen,
              iconColor: AppTheme.gridIconColor,
            ),
            DashboardGridItem(
              icon: Icons.access_time_filled_rounded,
              label: "Late / Early",
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const LateEarlyPermissionSheet(),
                );
              },
              animation: _controller,
              intervalStart: 0.18,
              gradientStart: AppTheme.gridGradient2Start,
              gradientEnd: AppTheme.gridGradient2End,
              iconColor: AppTheme.gridIconColor,
            ),
            DashboardGridItem(
              icon: Icons.approval_rounded,
              label: "Approvals",
              onTap: () => context.pushNamed("permission_approvals"),
              animation: _controller,
              intervalStart: 0.24,
              gradientStart: AppTheme.gridGradient3Start,
              gradientEnd: AppTheme.gridGradient3End,
              iconColor: AppTheme.gridIconColor,
            ),
          ],
        ),
      ),
    );
  }
}

class LateEarlyPermissionSheet extends StatefulWidget {
  const LateEarlyPermissionSheet({super.key});

  @override
  State<LateEarlyPermissionSheet> createState() => _LateEarlyPermissionSheetState();
}

class _LateEarlyPermissionSheetState extends State<LateEarlyPermissionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _timeController = TextEditingController();
  final Dio _dio = ApiConfig.dio;

  DateTime _selectedDate = DateTime.now();
  String _selectedType = "LATE_ENTRY";
  bool _submitting = false;

  bool get _isLateEntry => _selectedType == "LATE_ENTRY";

  @override
  void dispose() {
    _reasonController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked == null) return;

    final hh = picked.hour.toString().padLeft(2, '0');
    final mm = picked.minute.toString().padLeft(2, '0');
    _timeController.text = "$hh:$mm:00";
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() => _submitting = true);
    try {
      final payload = <String, dynamic>{
        "date": DateFormat("yyyy-MM-dd").format(_selectedDate),
        "type": _selectedType,
        "reason": _reasonController.text.trim(),
      };

      if (_isLateEntry) {
        payload["toTime"] = _timeController.text.trim();
      } else {
        payload["fromTime"] = _timeController.text.trim();
      }

      final response = await _dio.post(
        ApiConstants.attendancePermissionApply,
        data: payload,
      );

      if (!mounted) return;
      final message = response.data?["message"]?.toString() ??
          "Attendance adjustment applied successfully";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.statusSuccess,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data?["message"]?.toString() ??
          "Failed to apply attendance adjustment";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.statusError,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Please try again."),
          backgroundColor: AppTheme.statusError,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat("yyyy-MM-dd").format(_selectedDate);
    final title = _isLateEntry ? "Late Entry" : "Early Exit";
    final timeLabel = _isLateEntry ? "To Time" : "From Time";

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Apply $title",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    items: const [
                      DropdownMenuItem(
                        value: "LATE_ENTRY",
                        child: Text("Late Entry"),
                      ),
                      DropdownMenuItem(
                        value: "EARLY_EXIT",
                        child: Text("Early Exit"),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedType = value;
                        _timeController.clear();
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Type",
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(14),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: "Date"),
                      child: Text(dateText),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _timeController,
                    readOnly: true,
                    onTap: _pickTime,
                    decoration: InputDecoration(
                      labelText: timeLabel,
                      suffixIcon: const Icon(Icons.access_time_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "$timeLabel is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _reasonController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Reason",
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Reason is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Submit"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
