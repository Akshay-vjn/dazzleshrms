import 'dart:math' as math;
import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import 'package:dazzleshrms/core/app_theme/theme_provider.dart';
import 'package:dazzleshrms/core/storage/session_storage.dart';
import 'package:dazzleshrms/core/permissions/permission_provider.dart';
import 'package:dazzleshrms/features/profile/data/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  late List<AnimationController> _cardControllers;
  late List<Animation<Offset>> _cardSlideAnimations;
  late List<Animation<double>> _cardFadeAnimations;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _cardControllers = List.generate(
        5,
        (i) => AnimationController(
            duration: const Duration(milliseconds: 500), vsync: this));
    _cardSlideAnimations = _cardControllers
        .map((c) => Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();
    _cardFadeAnimations = _cardControllers
        .map((c) => Tween<double>(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile();
      _runEntranceSequence();
    });
  }

  Future<void> _runEntranceSequence() async {
    _animationController.forward();
    for (int i = 0; i < _cardControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (mounted) _cardControllers[i].forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final c in _cardControllers) c.dispose();
    super.dispose();
  }

  Widget _buildAvatar(String name) {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return GestureDetector(
      onTap: () => _showAvatarPopup(context, name),
      child: Container(
        width: 88,
        height: 88,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.dTeal,  // was Color(0xFF6366F1) Indigo
              AppTheme.dGreen, // was Color(0xFF8B5CF6) Purple / Color(0xFFA855F7) Light purple
            ],
          ),
        ),
        child: Center(
          child: Text(
            letter,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showAvatarPopup(BuildContext context, String name) {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'profile_avatar',
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.dTeal,  // was Color(0xFF6366F1) Indigo
                      AppTheme.dGreen, // was Color(0xFFA855F7) Light purple
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: const TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    required int index,
  }) {
    return SlideTransition(
      position: _cardSlideAnimations[index],
      child: FadeTransition(
        opacity: _cardFadeAnimations[index],
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              icon,
              color: AppTheme.PrimaryColor,
            ),
            title: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            subtitle: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final profileState = ref.watch(profileProvider);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Profile",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                themeNotifier.isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
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
                  Icon(
                    Icons.person_off_outlined,
                    size: 64,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No profile data",
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () =>
                        ref.read(profileProvider.notifier).loadProfile(),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            height: 140,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.dTeal,  // was Color(0xFF4F46E5)
                                  AppTheme.dGreen, // was Color(0xFF7C3AED)
                                  AppTheme.dTeal,  // was Color(0xFF8B5CF6)
                                ],
                                stops: [0.0, 0.5, 1.0],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Animated floating circles
                                Positioned(
                                  right: -20,
                                  top: -20,
                                  child: TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 0, end: 1),
                                    duration: const Duration(seconds: 2),
                                    builder: (context, double value, child) {
                                      return Transform.translate(
                                        offset: Offset(
                                          math.sin(value * 2 * math.pi) * 10,
                                          math.cos(value * 2 * math.pi) * 10,
                                        ),
                                        child: Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withValues(alpha: 0.1),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  left: 20,
                                  bottom: 10,
                                  child: TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 0, end: 1),
                                    duration: const Duration(milliseconds: 2500),
                                    builder: (context, double value, child) {
                                      return Transform.translate(
                                        offset: Offset(
                                          math.cos(value * 2 * math.pi) * 8,
                                          math.sin(value * 2 * math.pi) * 8,
                                        ),
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withValues(alpha: 0.08),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // Shimmer effect
                                Positioned.fill(
                                  child: TweenAnimationBuilder(
                                    tween: Tween<double>(begin: -1, end: 2),
                                    duration: const Duration(seconds: 3),
                                    builder: (context, double value, child) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            stops: [
                                              (value - 0.3).clamp(0.0, 1.0),
                                              value.clamp(0.0, 1.0),
                                              (value + 0.3).clamp(0.0, 1.0),
                                            ],
                                            colors: [
                                              Colors.transparent,
                                              Colors.white.withValues(alpha: 0.1),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.fromLTRB(16, 100, 16, 0),
                            padding: const EdgeInsets.fromLTRB(16, 56, 16, 20),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.dividerColor.withOpacity(0.1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Text(
                                    data.name.isNotEmpty ? data.name : "—",
                                    style:
                                    theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.PrimaryColor.withOpacity(
                                          0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      data.role.isNotEmpty
                                          ? data.role
                                          : "N/A",
                                      style:
                                      theme.textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.PrimaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 56,
                          child: Center(
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: _buildAvatar(data.name),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                //EMPLOYEE INFO
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 12),
                        child: Text(
                          "Employee Information",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildInfoCard(
                        icon: Icons.badge_outlined,
                        label: "Employee ID",
                        value: data.code.isNotEmpty ? data.code : "—",
                        theme: theme,
                        index: 0,
                      ),
                      _buildInfoCard(
                        icon: Icons.phone_outlined,
                        label: "Phone Number",
                        value: data.mobile.isNotEmpty ? data.mobile : "—",
                        theme: theme,
                        index: 1,
                      ),
                      _buildInfoCard(
                        icon: Icons.business_outlined,
                        label: "Designation",
                        value: data.designation.isNotEmpty
                            ? data.designation
                            : "—",
                        theme: theme,
                        index: 2,
                      ),
                      _buildInfoCard(
                        icon: Icons.store_outlined,
                        label: "Store",
                        value: data.store.name.isNotEmpty
                            ? data.store.name
                            : data.store.shortForm.isNotEmpty
                            ? data.store.shortForm
                            : "—",
                        theme: theme,
                        index: 3,
                      ),
                      _buildInfoCard(
                        icon: Icons.calendar_today_outlined,
                        label: "Joining Date",
                        value:
                        data.joiningDate.isNotEmpty ? data.joiningDate : "—",
                        theme: theme,
                        index: 4,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                //  LOGOUT
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.statusError.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.statusError,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          barrierColor: Colors.black.withOpacity(0.5),
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppTheme.statusError.withValues(alpha: 0.15),
                                          AppTheme.statusError.withValues(alpha: 0.05),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.logout_rounded,
                                      size: 36,
                                      color: AppTheme.statusError,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "Logout",
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Are you sure you want to logout from your account?",
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.hintColor,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            side: BorderSide(color: theme.dividerColor),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: theme.textTheme.bodyMedium?.color,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: FilledButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          style: FilledButton.styleFrom(
                                            backgroundColor: AppTheme.statusError,
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            "Logout",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );

                        if (shouldLogout == true) {
                          await SessionStorage.clearSession();
                          ref
                              .read(permissionProvider.notifier)
                              .clearPermissions();

                          if (!context.mounted) return;
                          context.goNamed('login');
                        }
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.PrimaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                "Loading profile...",
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.statusError.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  "Something went wrong",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () =>
                      ref.read(profileProvider.notifier).loadProfile(),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Try Again"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}