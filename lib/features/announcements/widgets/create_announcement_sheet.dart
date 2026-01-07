import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_theme/app_theme.dart';
import '../data/providers/announcement_provider.dart';
import '../data/models/create_announcement_model.dart';

class CreateAnnouncementSheet extends ConsumerStatefulWidget {
  const CreateAnnouncementSheet({super.key});

  @override
  ConsumerState<CreateAnnouncementSheet> createState() =>
      _CreateAnnouncementSheetState();
}

class _CreateAnnouncementSheetState
    extends ConsumerState<CreateAnnouncementSheet> {
  final GlobalKey<ScaffoldMessengerState> _messengerKey = GlobalKey<ScaffoldMessengerState>();
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController announcementCtrl = TextEditingController();
  final TextEditingController storeIdCtrl = TextEditingController();
  final TextEditingController employeeIdCtrl = TextEditingController();

  void _showSheetSnackBar(
      String message, {
        bool isError = true,
      }) {
    _messengerKey.currentState
      ?..hideCurrentSnackBar()
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

  void _submitAnnouncement() {
    if (titleCtrl.text.trim().isEmpty || announcementCtrl.text.trim().isEmpty) {
      _showSheetSnackBar("Please fill title and announcement");
      return;
    }

    int? storeId;
    if (storeIdCtrl.text.trim().isNotEmpty) {
      storeId = int.tryParse(storeIdCtrl.text.trim());
    }

    int? employeeId;
    if (employeeIdCtrl.text.trim().isNotEmpty) {
      employeeId = int.tryParse(employeeIdCtrl.text.trim());
    }

    ref.read(createAnnouncementProvider.notifier).createAnnouncement(
      title: titleCtrl.text.trim(),
      announcement: announcementCtrl.text.trim(),
      storeId: storeId,
      employeeId: employeeId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final createAnnouncementState = ref.watch(createAnnouncementProvider);

    ref.listen<AsyncValue<CreateAnnouncementResponse?>>(
      createAnnouncementProvider,
          (previous, next) {
        next.whenOrNull(
          error: (error, _) {
            _showSheetSnackBar(error.toString());
          },
          data: (data) {
            if (data != null) {
              _showSheetSnackBar(
                "Announcement created successfully",
                isError: false,
              );
              // Clear fields
              titleCtrl.clear();
              announcementCtrl.clear();
              storeIdCtrl.clear();
              employeeIdCtrl.clear();
              
              Future.delayed(const Duration(milliseconds: 800), () {
                if (mounted) Navigator.pop(context);
              });
            }
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
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: ScaffoldMessenger(
          key: _messengerKey,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: Column(
              children: [
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            "New Announcement",
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Text("Title", style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        TextField(
                          controller: titleCtrl,
                          decoration: const InputDecoration(
                            hintText: "Enter title",
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text("Announcement", style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        TextField(
                          controller: announcementCtrl,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: "Enter announcement details",
                          ),
                        ),

                        const SizedBox(height: 20),
                        
                        Text("Target Audience (Optional)", style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: storeIdCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Store ID",
                                  hintText: "e.g. 3",
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: employeeIdCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Employee ID",
                                  hintText: "e.g. 4",
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Leave blank to send globally.",
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: createAnnouncementState.isLoading
                          ? null
                          : _submitAnnouncement,
                      child: createAnnouncementState.isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                          : const Text("Post Announcement"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    announcementCtrl.dispose();
    storeIdCtrl.dispose();
    employeeIdCtrl.dispose();
    super.dispose();
  }
}
