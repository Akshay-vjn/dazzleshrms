import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_theme/app_theme.dart';
import 'data/models/apply_leave_model.dart';
import 'data/models/leave_type_model.dart';
import 'data/providers/apply_leave_provider.dart';
import 'data/providers/leave_type_provider.dart';

class ApplyLeaveFormSheet extends ConsumerStatefulWidget {
  const ApplyLeaveFormSheet({super.key});

  @override
  ConsumerState<ApplyLeaveFormSheet> createState() =>
      _ApplyLeaveFormSheetState();
}

class _ApplyLeaveFormSheetState
    extends ConsumerState<ApplyLeaveFormSheet> {
  final TextEditingController reasonCtrl = TextEditingController();

  int? selectedLeaveTypeId;
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();

    /// 🔹 Load leave types when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaveTypeProvider.notifier).loadLeaveTypes();
    });
  }

  // ===================== HELPERS =====================

  void _showSheetSnackBar(
      String message, {
        bool isError = true,
      }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
          isError ? AppTheme.statusError : AppTheme.statusSuccess,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        isFrom ? fromDate = picked : toDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) =>
      date.toIso8601String().split('T').first;

  void _submitLeave() {
    if (selectedLeaveTypeId == null ||
        fromDate == null ||
        toDate == null ||
        reasonCtrl.text.trim().isEmpty) {
      _showSheetSnackBar("Please fill all fields");
      return;
    }

    ref.read(applyLeaveProvider.notifier).applyLeave(
      leaveTypeId: selectedLeaveTypeId!,
      fromDate: _formatDate(fromDate!),
      toDate: _formatDate(toDate!),
      note: reasonCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final leaveTypeState = ref.watch(leaveTypeProvider);
    final applyLeaveState = ref.watch(applyLeaveProvider);

    /// ✅ SINGLE LISTENER – CORRECT PLACE
    ref.listen<AsyncValue<ApplyLeaveResponse?>>(
      applyLeaveProvider,
          (previous, next) {
        next.whenOrNull(
          error: (error, _) {
            _showSheetSnackBar(error.toString());
          },
          data: (_) {
            _showSheetSnackBar(
              "Leave applied successfully",
              isError: false,
            );

            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted) Navigator.pop(context);
            });
          },
        );
      },
    );

    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // ================= DRAG INDICATOR =================
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            // ================= FORM =================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "New Leave Request",
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ---------- LEAVE TYPE ----------
                    Text("Leave Type", style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),

                    leaveTypeState.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      error: (e, _) => Text(
                        e.toString(),
                        style: const TextStyle(color: Colors.red),
                      ),
                      data: (types) {
                        return DropdownButtonFormField<int>(
                          value: selectedLeaveTypeId,
                          hint: const Text("Select leave type"),
                          items: types
                              .map(
                                (LeaveType e) => DropdownMenuItem<int>(
                              value: e.leaveId,
                              child: Text(e.leaveType),
                            ),
                          )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => selectedLeaveTypeId = v),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ---------- DATE RANGE ----------
                    Text("Leave Duration",
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pickDate(isFrom: true),
                            child: Text(
                              fromDate == null
                                  ? "From Date"
                                  : _formatDate(fromDate!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pickDate(isFrom: false),
                            child: Text(
                              toDate == null
                                  ? "To Date"
                                  : _formatDate(toDate!),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ---------- REASON ----------
                    Text("Reason", style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),

                    TextField(
                      controller: reasonCtrl,
                      maxLines: 2,
                      decoration:
                      const InputDecoration(hintText: "Enter reason"),
                    ),
                  ],
                ),
              ),
            ),

            // ================= SUBMIT BUTTON =================
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed:
                  applyLeaveState.isLoading ? null : _submitLeave,
                  child: applyLeaveState.isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                      : const Text("Submit Leave"),
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
    reasonCtrl.dispose();
    super.dispose();
  }
}
