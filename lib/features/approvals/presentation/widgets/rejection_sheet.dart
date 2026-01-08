import 'package:flutter/material.dart';
import '../../../../core/app_theme/app_theme.dart';

class RejectionSheet extends StatefulWidget {
  final String employeeName;
  final Function(String reason) onSubmitted;

  const RejectionSheet({
    super.key,
    required this.employeeName,
    required this.onSubmitted,
  });

  @override
  State<RejectionSheet> createState() => _RejectionSheetState();
}

class _RejectionSheetState extends State<RejectionSheet> {
  final TextEditingController _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Reject Leave",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.PrimaryColor.withOpacity(0.12), // 🔹 low opacity bg
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppTheme.PrimaryColor, // 🔹 icon color
                    splashRadius: 22,
                  ),
                ),

              ],
            ),
            // Text(
            //   "For ${widget.employeeName}",
            //   style: theme.textTheme.bodyMedium?.copyWith(
            //     color: AppTheme.statusError,
            //     fontWeight: FontWeight.w600,
            //   ),
            // ),
            const SizedBox(height: 20),
            Text(
              "Reason for Rejection",
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _reasonController,
              maxLines: 4,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Enter the reason why this leave is being rejected...",
                hintStyle: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                fillColor: isDark ? AppTheme.surfaceDark : Colors.grey[100],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please provide a rejection reason";
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSubmitted(_reasonController.text.trim());
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.iconPrimary,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Reject"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
