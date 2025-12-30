import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers/change_leave_provider.dart';

class ChangeLeaveDialog extends ConsumerStatefulWidget {
  final int logId;

  const ChangeLeaveDialog({super.key, required this.logId});

  @override
  ConsumerState<ChangeLeaveDialog> createState() =>
      _ChangeLeaveDialogState();
}

class _ChangeLeaveDialogState
    extends ConsumerState<ChangeLeaveDialog> {
  String? selectedType;
  int? selectedTypeId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(changeLeaveProvider);

    /// 🔥 LISTEN FOR SUCCESS / ERROR
    ref.listen(changeLeaveProvider, (prev, next) {
      next.whenOrNull(
        data: (res) {
          if (res != null && !res.error) {
            // ✅ RETURN TRUE TO PARENT
            Navigator.pop(context, true);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(res.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    });

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== HEADER =====
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.edit_calendar_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Modify Leave",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ===== CHANGE TYPE =====
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    hintText: "Select new leave type",
                    filled: true,
                    fillColor:
                    theme.colorScheme.surfaceVariant.withOpacity(0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: "HDO", child: Text("Half Day Out")),
                    DropdownMenuItem(value: "HDI", child: Text("Half Day In")),
                    DropdownMenuItem(value: "Absent", child: Text("Absent")),
                  ],
                  onChanged: (val) {
                    setState(() {
                      selectedType = val;
                      selectedTypeId = val == "HDO"
                          ? 5
                          : val == "HDI"
                          ? 6
                          : 4;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // ===== CANCEL LEAVE =====
                TextButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () => ref
                      .read(changeLeaveProvider.notifier)
                      .cancelLeave(widget.logId),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    "Cancel Leave",
                    style: TextStyle(color: Colors.red),
                  ),
                ),

                const SizedBox(height: 20),

                // ===== ACTIONS =====
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: state.isLoading || selectedType == null
                            ? null
                            : () => ref
                            .read(changeLeaveProvider.notifier)
                            .changeLeaveType(
                          logId: widget.logId,
                          newType: selectedType!,
                          newTypeId: selectedTypeId!,
                        ),
                        child: const Text("Submit"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ===== LOADING OVERLAY =====
          if (state.isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
