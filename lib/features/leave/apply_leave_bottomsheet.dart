import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ApplyLeaveFormSheet extends StatefulWidget {
  const ApplyLeaveFormSheet({super.key});

  @override
  State<ApplyLeaveFormSheet> createState() => _ApplyLeaveFormSheetState();
}

class _ApplyLeaveFormSheetState extends State<ApplyLeaveFormSheet> {
  final TextEditingController reasonCtrl = TextEditingController();

  String? selectedLeaveType;
  DateTime? fromDate;
  DateTime? toDate;

  final leaveTypes = [
    "Casual Leave",
    "Sick Leave",
    "Earned Leave",
    "Work From Home",
  ];

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

  void _submitLeave() {
    if (selectedLeaveType == null ||
        fromDate == null ||
        toDate == null ||
        reasonCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6, // ✅ ONE PLACE
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag indicator
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

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Text("New Leave Request", style: theme.textTheme.titleMedium)),
                    const SizedBox(height: 20),

                    Text("Leave Type", style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedLeaveType,
                      hint: const Text("Select leave type"),
                      items: leaveTypes
                          .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => selectedLeaveType = v),
                    ),

                    const SizedBox(height: 20),

                    Text("Leave Duration", style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pickDate(isFrom: true),
                            child: Text(
                              fromDate == null
                                  ? "From Date"
                                  : "${fromDate!.day}/${fromDate!.month}/${fromDate!.year}",
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
                                  : "${toDate!.day}/${toDate!.month}/${toDate!.year}",
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Text("Reason", style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reasonCtrl,
                      maxLines: 2,
                      decoration:
                      const InputDecoration(hintText: "Enter reason"),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Fixed submit button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _submitLeave,
                  child: const Text("Submit Leave"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
