import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import 'package:dazzleshrms/core/app_theme/theme_provider.dart';
import 'package:dazzleshrms/core/storage/session_storage.dart';
import 'package:dazzleshrms/core/permissions/permission_provider.dart';
import 'package:dazzleshrms/features/profile/data/providers/profile_provider.dart';

import 'package:dazzleshrms/features/profile/profile_screen/widgets/infotile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  Widget _buildAvatar(String name) {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 36,
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: animation,
                    child: child,
                  );
                },
                child: Icon(
                  themeNotifier.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  key: ValueKey(themeNotifier.isDarkMode),
                ),
              ),
              onPressed: () {
                themeNotifier.toggleTheme();
              },
              tooltip: themeNotifier.isDarkMode
                  ? 'Switch to Light Mode'
                  : 'Switch to Dark Mode',
            ),
          ),
        ],
      ),
      body: profileState.when(
        data: (data) {
          if (data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No profile data"),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () =>
                        ref.read(profileProvider.notifier).loadProfile(),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= PROFILE HEADER =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.PrimaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppTheme.PrimaryColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      _buildAvatar(data.name),
                      const SizedBox(height: 12),
                      Text(
                        data.name.isNotEmpty ? data.name : "—",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.role.isNotEmpty
                            ? data.role
                            : "N/A",
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ================= EMPLOYEE INFO =================
                Text(
                  "Employee Information",
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                InfoTile(
                  icon: Icons.badge_outlined,
                  label: "Employee ID",
                  value: data.code.isNotEmpty ? data.code : "—",
                ),
                InfoTile(
                  icon: Icons.phone_outlined,
                  label: "Phone",
                  value: data.mobile.isNotEmpty ? data.mobile : "—",
                ),
                InfoTile(
                  icon: Icons.business_outlined,
                  label: "Designation",
                  value: data.designation.isNotEmpty ? data.designation : "—",
                ),
                InfoTile(
                  icon: Icons.store_outlined,
                  label: "Store",
                  value: data.store.name.isNotEmpty
                      ? data.store.name
                      : data.store.shortForm.isNotEmpty
                          ? data.store.shortForm
                          : "—",
                ),
                InfoTile(
                  icon: Icons.calendar_today_outlined,
                  label: "Joining Date",
                  value: data.joiningDate.isNotEmpty ? data.joiningDate : "—",
                ),

                const SizedBox(height: 24),



                const SizedBox(height: 32),

                // ================= LOGOUT =================
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.statusError,
                    ),
                    onPressed: () async {
                      await SessionStorage.clearSession();
                      ref.read(permissionProvider.notifier).clearPermissions();

                      if (!context.mounted) return;
                      context.goNamed('login');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                err.toString(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    ref.read(profileProvider.notifier).loadProfile(),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
