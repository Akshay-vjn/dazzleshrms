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
  int? _selectedQuickReasonIndex;

  static const List<String> _quickRejectReasons = [
    " Not approved due to current work requirements.",
    " Unable to approve for the requested dates.",
    " Not approved due to team availability constraints.",
    " Kindly apply for alternate dates.",
    " Not approved as per company policy.",
  ];

  @override
  void initState() {
    super.initState();
    _reasonController.addListener(_onReasonTextChanged);
  }

  @override
  void dispose() {
    _reasonController.removeListener(_onReasonTextChanged);
    _reasonController.dispose();
    super.dispose();
  }

  void _onReasonTextChanged() {
    if (_selectedQuickReasonIndex != null) {
      final selectedText = _quickRejectReasons[_selectedQuickReasonIndex!];
      if (_reasonController.text != selectedText) {
        setState(() => _selectedQuickReasonIndex = null);
      }
    }
  }

  void _onQuickReasonToggled(int index) {
    setState(() {
      if (_selectedQuickReasonIndex == index) {
        _selectedQuickReasonIndex = null;
        _reasonController.clear();
      } else {
        _selectedQuickReasonIndex = index;
        _reasonController.text = _quickRejectReasons[index];
        _reasonController.selection = TextSelection.fromPosition(
          TextPosition(offset: _reasonController.text.length),
        );
      }
    });
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
        child: SingleChildScrollView(
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
                      color: AppTheme.PrimaryColor.withOpacity(0.12),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: AppTheme.PrimaryColor,
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
              const SizedBox(height: 16),
              Text(
                "Quick Reasons",
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              ...List.generate(_quickRejectReasons.length, (index) {
                final isSelected = _selectedQuickReasonIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => _onQuickReasonToggled(index),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.statusError.withOpacity(0.1)
                            : isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.statusError
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppTheme.statusError
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.statusError
                                    : theme.colorScheme.outline.withOpacity(0.4),
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _quickRejectReasons[index],
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? AppTheme.statusError
                                    : theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
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
      ),
    );
  }
}

