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

class _ChangeLeaveDialogState extends ConsumerState<ChangeLeaveDialog> {
  String? selectedType;
  int? selectedTypeId;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(changeLeaveProvider);

    ref.listen(changeLeaveProvider, (prev, next) {
      next.whenOrNull(
        data: (res) {
          if (res != null && !res.error) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(res.message)),
            );
          }
        },
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        },
      );
    });

    return AlertDialog(
      title: const Text("Modify Leave"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // CHANGE TYPE
          DropdownButtonFormField<String>(
            value: selectedType,
            decoration: const InputDecoration(
              labelText: "Change Leave Type",
            ),
            items: const [
              DropdownMenuItem(value: "HDO", child: Text("Half Day - Outdoor")),
              DropdownMenuItem(value: "HDI", child: Text("Half Day - Indoor")),
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

          const SizedBox(height: 16),

          // CANCEL
          TextButton.icon(
            onPressed: state.isLoading
                ? null
                : () => ref
                .read(changeLeaveProvider.notifier)
                .cancelLeave(widget.logId),
            icon: const Icon(Icons.delete_outline),
            label: const Text("Cancel Leave"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
        ElevatedButton(
          onPressed: state.isLoading || selectedType == null
              ? null
              : () => ref
              .read(changeLeaveProvider.notifier)
              .changeLeaveType(
            logId: widget.logId,
            newType: selectedType!,
            newTypeId: selectedTypeId!,
          ),
          child: state.isLoading
              ? const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text("Submit"),
        ),
      ],
    );
  }
}
