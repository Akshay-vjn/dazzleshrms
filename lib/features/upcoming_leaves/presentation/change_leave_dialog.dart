import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers/change_leave_provider.dart';
import '../../leave/data/providers/leave_type_provider.dart';
import '../../leave/data/models/leave_type_model.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaveTypeProvider.notifier).loadLeaveTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(changeLeaveProvider);

    ref.listen(changeLeaveProvider, (prev, next) {
      next.whenOrNull(
        data: (res) {
          if (res != null && !res.error) {
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
          String errorMessage = 'Something went wrong';
          if (e is DioException) {
            errorMessage = e.response?.data?['message'] ?? errorMessage;
          }

          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
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

                Consumer(
                  builder: (context, ref, child) {
                    final leaveTypesState = ref.watch(leaveTypeProvider);

                    return leaveTypesState.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (e, _) => Center(
                        child: Text(
                          "Error loading leave types",
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                      data: (types) {
                        return DropdownButtonFormField<LeaveType>(
                          value: types.any((t) => t.leaveId == selectedTypeId)
                              ? types.firstWhere((t) => t.leaveId == selectedTypeId)
                              : null,
                          decoration: InputDecoration(
                            hintText: "Select new leave type",
                            filled: true,
                            fillColor: theme.colorScheme.surfaceVariant
                                .withOpacity(0.4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: types.map((type) {
                            return DropdownMenuItem<LeaveType>(
                              value: type,
                              child: Text(type.leaveType),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                selectedType = val.leaveType;
                                selectedTypeId = val.leaveId;
                              });
                            }
                          },
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),

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
