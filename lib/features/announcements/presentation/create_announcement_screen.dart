import 'package:dazzleshrms/features/announcements/data/models/create_announcement_model.dart';
import 'package:dazzleshrms/features/announcements/data/providers/announcement_provider.dart';
import 'package:dazzleshrms/features/announcements/presentation/widgets/designation_sheet.dart';
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

  List<int> selectedStoreIds = [];
  List<String> selectedStoreNames = [];
  List<int> selectedEmployeeIds = [];
  List<String> selectedEmployeeNames = [];
  List<int> selectedDesignationIds = [];
  List<String> selectedDesignationNames = [];
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
      storeIds: selectedStoreIds,
      employeeIds: selectedEmployeeIds,
      designationIds: selectedDesignationIds,
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
        selectedStoreIds: selectedStoreIds,
        onSelect: (ids, names) {
          setState(() {
            selectedStoreIds = ids;
            selectedStoreNames = names;
            selectedEmployeeIds = [];
            selectedEmployeeNames = [];
          });
        },
      ),
    );
  }

  void _showDesignationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DesignationSheet(
        selectedDesignationIds: selectedDesignationIds,
        onSelect: (ids, names) {
          setState(() {
            selectedDesignationIds = ids;
            selectedDesignationNames = names;
          });
        },
      ),
    );
  }

  void _showEmployeeSheet() {
    if (selectedStoreIds.length > 1 || selectedDesignationIds.length > 1) {
      _showSnackBar("Employee selection is only available for a single store/designation");
      return;
    }

    if (selectedStoreIds.isEmpty && selectedDesignationIds.isEmpty) {
      _showSnackBar("Select a store or designation first");
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EmployeeSheet(
        storeId: selectedStoreIds.isEmpty ? null : selectedStoreIds.first,
        designationId: selectedDesignationIds.isEmpty ? null : selectedDesignationIds.first,
        selectedEmployeeIds: selectedEmployeeIds,
        onSelect: (ids, names) {
          setState(() {
            selectedEmployeeIds = ids;
            selectedEmployeeNames = names;
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
                selectedStoreIds = [];
                selectedStoreNames = [];
                selectedEmployeeIds = [];
                selectedEmployeeNames = [];
                selectedDesignationIds = [];
                selectedDesignationNames = [];
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

    final bool isEmployeeEnabled = (selectedStoreIds.length == 1 || selectedDesignationIds.length == 1);
    final bool isEmployeeDisabled = !isEmployeeEnabled;

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
                    decoration: _selectorDecoration(context, "Title").copyWith(
                      hintText: "Enter title",
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: announcementCtrl,
                    maxLines: 4,
                    decoration: _selectorDecoration(context, "Announcement").copyWith(
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
                              selectedStoreNames.isEmpty ? "All Stores" : selectedStoreNames.join(', '),
                              style: theme.textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 22),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  InkWell(
                    onTap: _showDesignationSheet,
                    child: InputDecorator(
                      decoration: _selectorDecoration(context, "Designation"),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              selectedDesignationNames.isEmpty ? "All Designations" : selectedDesignationNames.join(', '),
                              style: theme.textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 22),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  InkWell(
                    onTap: isEmployeeDisabled ? null : _showEmployeeSheet,
                    child: Opacity(
                      opacity: isEmployeeDisabled ? 0.5 : 1,
                      child: InputDecorator(
                        decoration:
                        _selectorDecoration(context, "Employee"),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                  isEmployeeDisabled
                                      ? (selectedStoreIds.length > 1 || selectedDesignationIds.length > 1
                                          ? "Not applicable for multiple selections"
                                          : "Select employee")
                                      : (selectedEmployeeNames.isEmpty
                                          ? "All Employees"
                                          : selectedEmployeeNames.join(', ')),
                                style: theme.textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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

                  if (selectedStoreIds.isNotEmpty ||
                      selectedEmployeeIds.isNotEmpty ||
                      selectedDesignationIds.isNotEmpty ||
                      attachmentPath != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedStoreIds = [];
                          selectedStoreNames = [];
                          selectedEmployeeIds = [];
                          selectedEmployeeNames = [];
                          selectedDesignationIds = [];
                          selectedDesignationNames = [];
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
