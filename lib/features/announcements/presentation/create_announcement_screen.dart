import 'package:dazzleshrms/features/announcements/data/models/create_announcement_model.dart';
import 'package:dazzleshrms/features/announcements/data/models/store_model.dart';
import 'package:dazzleshrms/features/announcements/data/models/employee_model.dart';
import 'package:dazzleshrms/features/announcements/data/providers/announcement_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_theme/app_theme.dart';

class CreateAnnouncementScreen extends ConsumerStatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  ConsumerState<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState
    extends ConsumerState<CreateAnnouncementScreen> {
  final GlobalKey<ScaffoldMessengerState> _messengerKey = GlobalKey<ScaffoldMessengerState>();
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController announcementCtrl = TextEditingController();
  int? selectedStoreId;
  int? selectedEmployeeId;

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
    if (titleCtrl.text.trim().isEmpty || announcementCtrl.text.trim().isEmpty) {
      _showSnackBar("Please fill title and announcement");
      return;
    }

    ref.read(createAnnouncementProvider.notifier).createAnnouncement(
      title: titleCtrl.text.trim(),
      announcement: announcementCtrl.text.trim(),
      storeId: selectedStoreId,
      employeeId: selectedEmployeeId,
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
            _showSnackBar(error.toString());
          },
          data: (data) {
            if (data != null) {
              _showSnackBar(
                "Announcement created successfully",
                isError: false,
              );
              // Clear fields
              titleCtrl.clear();
              announcementCtrl.clear();
              setState(() {
                selectedStoreId = null;
                selectedEmployeeId = null;
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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("New Announcement"),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text("Target Audience (Optional)",
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ref.watch(storesProvider).when(
                              loading: () => const LinearProgressIndicator(),
                              error: (e, _) => Text('Error loading stores: $e',
                                  style: const TextStyle(color: Colors.red)),
                              data: (stores) => DropdownButtonFormField<int>(
                                value: selectedStoreId,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: "Store",
                                  hintText: "Select Store",
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  const DropdownMenuItem<int>(
                                    value: null,
                                    child: Text("None (Global)"),
                                  ),
                                  ...stores.map((s) => DropdownMenuItem<int>(
                                        value: s.storeId,
                                        child: Text(
                                          s.storeName,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    selectedStoreId = val;
                                    selectedEmployeeId =
                                        null; // Reset employee when store changes
                                  });
                                },
                              ),
                            ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: selectedStoreId == null
                            ? const TextField(
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: "Employee",
                                  hintText: "Select Store first",
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                  border: OutlineInputBorder(),
                                ),
                              )
                            : ref
                                .watch(employeesProvider(selectedStoreId!))
                                .when(
                                  loading: () => const LinearProgressIndicator(),
                                  error: (e, _) => Text('Error: $e',
                                      style:
                                          const TextStyle(color: Colors.red)),
                                  data: (employees) =>
                                      DropdownButtonFormField<int>(
                                    value: selectedEmployeeId,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      labelText: "Employee",
                                      hintText: "Select Employee",
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 12),
                                      border: OutlineInputBorder(),
                                    ),
                                    items: [
                                      const DropdownMenuItem<int>(
                                        value: null,
                                        child: Text("All Employees"),
                                      ),
                                      ...employees
                                          .map((e) => DropdownMenuItem<int>(
                                                value: e.employeeId,
                                                child: Text(
                                                  e.employeeName,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              )),
                                    ],
                                    onChanged: (val) {
                                      setState(() {
                                        selectedEmployeeId = val;
                                      });
                                    },
                                  ),
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Leave blank to send globally.",
                    style:
                        theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor, // Ensure this matches scaffold bg
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
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
    );
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    announcementCtrl.dispose();
    super.dispose();
  }
}
