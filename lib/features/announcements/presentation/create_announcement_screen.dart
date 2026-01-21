import 'package:dazzleshrms/features/announcements/data/models/create_announcement_model.dart';
import 'package:dazzleshrms/features/announcements/data/providers/announcement_provider.dart';
import 'package:dazzleshrms/features/announcements/presentation/widgets/employee_sheet.dart';
import 'package:dazzleshrms/features/announcements/presentation/widgets/store_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/app_theme/app_theme.dart';

class CreateAnnouncementScreen extends ConsumerStatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  ConsumerState<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState
    extends ConsumerState<CreateAnnouncementScreen> {
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController announcementCtrl = TextEditingController();

  int? selectedStoreId;
  String? selectedStoreName;
  int? selectedEmployeeId;
  String? selectedEmployeeName;
  String? attachmentPath;
  String? attachmentName;

  InputDecoration _selectorDecoration(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor:
      isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
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
    if (titleCtrl.text.trim().isEmpty ||
        announcementCtrl.text.trim().isEmpty) {
      _showSnackBar("Please fill title and announcement");
      return;
    }

    ref.read(createAnnouncementProvider.notifier).createAnnouncement(
      title: titleCtrl.text.trim(),
      announcement: announcementCtrl.text.trim(),
      storeId: selectedStoreId,
      employeeId: selectedEmployeeId,
      attachmentPath: attachmentPath,
    );
  }

  Future<void> _pickPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          attachmentPath = result.files.single.path;
          attachmentName = result.files.single.name;
        });
      }
    } catch (e) {
      _showSnackBar("Error picking file: $e");
    }
  }

  void _showStoreSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StoreSheet(
        selectedStoreId: selectedStoreId,
        onSelect: (id, name) {
          setState(() {
            selectedStoreId = id;
            selectedStoreName = name;
            selectedEmployeeId = null;
            selectedEmployeeName = null;
          });
        },
      ),
    );
  }

  void _showEmployeeSheet() {
    if (selectedStoreId == null) {
      _showSnackBar("Please select a store first");
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EmployeeSheet(
        storeId: selectedStoreId!,
        selectedEmployeeId: selectedEmployeeId,
        onSelect: (id, name) {
          setState(() {
            selectedEmployeeId = id;
            selectedEmployeeName = name;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final createState = ref.watch(createAnnouncementProvider);

    ref.listen<AsyncValue<CreateAnnouncementResponse?>>(
      createAnnouncementProvider,
          (_, next) {
        next.whenOrNull(
          error: (e, _) => _showSnackBar(e.toString()),
          data: (data) {
            if (data != null) {
              _showSnackBar("Announcement created", isError: false);
              titleCtrl.clear();
              announcementCtrl.clear();
              setState(() {
                selectedStoreId = null;
                selectedStoreName = null;
                selectedEmployeeId = null;
                selectedEmployeeName = null;
                attachmentPath = null;
                attachmentName = null;
              });
              Future.delayed(const Duration(milliseconds: 800), () {
                if (mounted) Navigator.pop(context);
              });
            }
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text("New Announcement")),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: "Title",
                      hintText: "Enter title",
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: announcementCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Announcement",
                      hintText: "Enter details",
                    ),
                  ),

                  const SizedBox(height: 24),

                  InkWell(
                    onTap: _showStoreSheet,
                    child: InputDecorator(
                      decoration: _selectorDecoration(context, "Store"),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              selectedStoreName ?? "All Stores",
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 22),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  InkWell(
                    onTap:
                    selectedStoreId != null ? _showEmployeeSheet : null,
                    child: Opacity(
                      opacity: selectedStoreId != null ? 1 : 0.5,
                      child: InputDecorator(
                        decoration:
                        _selectorDecoration(context, "Employee"),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                selectedStoreId == null
                                    ? "Select store first"
                                    : (selectedEmployeeName ??
                                    "All Employees"),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, size: 22),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  InkWell(
                    onTap: _pickPDF,
                    child: InputDecorator(
                      decoration: _selectorDecoration(context, "Attachment (PDF)"),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              attachmentName ?? "Select PDF File",
                              style: theme.textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            attachmentPath != null ? Icons.picture_as_pdf : Icons.attach_file,
                            size: 22,
                            color: attachmentPath != null ? Colors.red : null,
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (selectedStoreId != null ||
                      selectedEmployeeId != null ||
                      attachmentPath != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedStoreId = null;
                          selectedStoreName = null;
                          selectedEmployeeId = null;
                          selectedEmployeeName = null;
                          attachmentPath = null;
                          attachmentName = null;
                        });
                      },
                      child: const Text("Clear Selection"),
                    ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed:
                createState.isLoading ? null : _submitAnnouncement,
                child: createState.isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                  CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("Post Announcement"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    announcementCtrl.dispose();
    super.dispose();
  }
}
