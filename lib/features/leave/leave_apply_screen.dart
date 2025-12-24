import 'package:flutter/material.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import 'package:dazzleshrms/features/leave/leave_history_screen.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
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

  // ---------- DATE PICKER ----------
  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  // ---------- SUBMIT ----------
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

    // 🔹 Later replace this with API call
    debugPrint("Leave Applied:");
    debugPrint("Type: $selectedLeaveType");
    debugPrint("From: $fromDate");
    debugPrint("To: $toDate");
    debugPrint("Reason: ${reasonCtrl.text}");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Leave applied successfully")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text("Apply Leave"),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LeaveHistoryScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.history_rounded,
              color: AppTheme.PrimaryColor,
              size: 20,
            ),
            label: const Text(
              "Leave History",
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.PrimaryColor,
              ),
            ),
          ),
        ],
      ),


      body: SingleChildScrollView(
        
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- LEAVE TYPE ----------
            Text(
              "Leave Type",
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: selectedLeaveType,
              hint: const Text("Select leave type"),
              items: leaveTypes
                  .map(
                    (type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ),
              )
                  .toList(),
              onChanged: (value) {
                setState(() => selectedLeaveType = value);
              },
            ),

            const SizedBox(height: 20),

            // ---------- DATE RANGE ----------
            Text(
              "Leave Duration",
              style: theme.textTheme.titleMedium,
            ),
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

            // ---------- REASON ----------
            Text(
              "Reason",
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            TextField(
              controller: reasonCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Enter reason for leave",
              ),
            ),

            const SizedBox(height: 28),

            // ---------- SUBMIT ----------
            FilledButton(
              onPressed: _submitLeave,
              child: const Text("Submit Leave"),
            ),
          ],
        ),
      ),
    );
  }
}
