import 'package:dazzleshrms/core/app_theme/app_page_bar.dart';
import 'package:dazzleshrms/core/app_theme/app_surface.dart';
import 'package:dazzleshrms/core/app_theme/glass_surface.dart';
import 'package:dazzleshrms/core/app_theme/app_visuals.dart';
import 'package:dazzleshrms/core/app_theme/app_scaffold.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dazzleshrms/core/api_constants/api_constants.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import 'package:dazzleshrms/core/app_theme/theme_provider.dart';
import 'package:dazzleshrms/core/storage/session_storage.dart';
import 'package:dazzleshrms/core/permissions/permission_provider.dart';
import 'package:dazzleshrms/features/profile/data/models/profile_response.dart';
import 'package:dazzleshrms/features/profile/data/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

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

  bool _isUploadingImage = false;
  bool _isSubmittingChangeRequest = false;
  String _lastAvatarImageUrl = '';

  Future<void> _evictAvatarUrl(String url) async {
    if (url.isEmpty) return;
    try {
      await CachedNetworkImage.evictFromCache(url);
      await CachedNetworkImageProvider(url).evict();
      PaintingBinding.instance.imageCache.evict(NetworkImage(url));
    } catch (_) {}
  }

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

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
          ),
        );

    _cardControllers = List.generate(
      5,
      (i) => AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      ),
    );
    _cardSlideAnimations = _cardControllers
        .map(
          (c) => Tween<Offset>(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)),
        )
        .toList();
    _cardFadeAnimations = _cardControllers
        .map(
          (c) => Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)),
        )
        .toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(profileProvider.notifier).loadProfile();
      _runEntranceSequence();
    });
  }

  Future<void> _runEntranceSequence() async {
    _animationController.forward();
    for (int i = 0; i < _cardControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      _cardControllers[i].forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final c in _cardControllers) {
      c.dispose();
    }
    super.dispose();
  }

  String _getFullImageUrl(String profileImage) {
    return ApiConstants.resolveMediaUrl(profileImage);
  }

  Widget _buildAvatar(ProfileData data) {
    final colors = AppVisuals.of(context);
    final name = data.name;
    final profileImage = data.profileImage;
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final imageUrl = _getFullImageUrl(profileImage);
    final hasImage = imageUrl.isNotEmpty;
    final needsChangeRequest =
        data.hasProfileImage && !data.profileImageChangeAllowed;

    return GestureDetector(
      onTap: () => _showAvatarPopup(context, name, profileImage),
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.accentSurface,
              border: Border.all(
                color: colors.accent.withValues(alpha: .25),
                width: .5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.accent.withValues(alpha: .08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: hasImage
                ? ClipOval(
                    child: CachedNetworkImage(
                      key: ValueKey(imageUrl),
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                      placeholder: (context, url) => Container(
                        decoration: BoxDecoration(color: colors.accentSurface),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.accent,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(color: colors.accentSurface),
                        child: Center(
                          child: Text(
                            letter,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: colors.accent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: colors.accent,
                      ),
                    ),
                  ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _onAvatarEditTap,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppVisuals.of(context).accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surface, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  needsChangeRequest
                      ? Icons.lock_reset_rounded
                      : Icons.camera_alt_rounded,
                  size: 14,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
          // Upload indicator overlay
          if (_isUploadingImage)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ProfileData data) {
    final theme = Theme.of(context);
    final colors = AppVisuals.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GlassSurface(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked =
                  constraints.maxWidth < 280 ||
                  MediaQuery.textScalerOf(context).scale(16) > 22;
              final identity = Column(
                crossAxisAlignment: stacked
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name.isNotEmpty ? data.name : '—',
                    textAlign: stacked ? TextAlign.center : TextAlign.start,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.text,
                      letterSpacing: -.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.accentSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colors.accent.withValues(alpha: .25),
                        width: .5,
                      ),
                    ),
                    child: Text(
                      data.role.isNotEmpty ? data.role : 'N/A',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
              final avatar = ScaleTransition(
                scale: _scaleAnimation,
                child: _buildAvatar(data),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (stacked)
                    Column(
                      children: [avatar, const SizedBox(height: 16), identity],
                    )
                  else
                    Row(
                      children: [
                        avatar,
                        const SizedBox(width: 20),
                        Expanded(child: identity),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _onAvatarEditTap() {
    final data = ref.read(profileProvider).valueOrNull;
    if (data == null) return;
    if (!data.hasProfileImage || data.profileImageChangeAllowed) {
      _showImagePickerSheet();
    } else {
      _showChangeRequestSheet(
        message:
            'Profile image change is not allowed. Please request permission from HR/Admin.',
      );
    }
  }

  void _showImagePickerSheet() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final data = ref.read(profileProvider).valueOrNull;
    final sheetTitle = (data?.hasProfileImage ?? false)
        ? 'Change Profile Photo'
        : 'Add Profile Photo';

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                sheetTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppVisuals.of(context).accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: AppVisuals.of(context).accent,
                  ),
                ),
                title: const Text('Take a Photo'),
                subtitle: Text(
                  'Use your camera',
                  style: TextStyle(color: theme.hintColor, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOnLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: AppTheme.primaryOnLight,
                  ),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: Text(
                  'Select from your photos',
                  style: TextStyle(color: theme.hintColor, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangeRequestSheet({String? message}) {
    final theme = Theme.of(context);
    final colors = AppVisuals.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .85,
      ),
      builder: (sheetContext) {
        var submitting = false;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Material(
              color: Colors.transparent,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              clipBehavior: Clip.antiAlias,
              child: DecoratedBox(
                decoration: colors.backdrop,
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: colors.muted.withValues(alpha: .4),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: colors.accentSurface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock_reset_rounded,
                              color: colors.accent,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Request Photo Change',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            message ??
                                'Profile image change is not allowed. Please request permission from HR/Admin.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.muted,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: submitting
                                  ? null
                                  : () async {
                                      setSheetState(() => submitting = true);
                                      final success =
                                          await _submitProfileImageChangeRequest();
                                      if (!sheetContext.mounted) return;
                                      if (success) {
                                        Navigator.pop(sheetContext);
                                      } else {
                                        setSheetState(() => submitting = false);
                                      }
                                    },
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: submitting
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colors.muted,
                                      ),
                                    )
                                  : const Text(
                                      'Submit Request',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: submitting
                                ? null
                                : () => Navigator.pop(sheetContext),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _submitProfileImageChangeRequest() async {
    if (_isSubmittingChangeRequest) return false;
    try {
      setState(() => _isSubmittingChangeRequest = true);
      final message = await ref
          .read(profileProvider.notifier)
          .requestProfileImageChange();
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.statusSuccess,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return true;
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppTheme.statusError,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return false;
    } finally {
      if (mounted) {
        setState(() => _isSubmittingChangeRequest = false);
      }
    }
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingImage = true);

      final file = File(pickedFile.path);
      await ref.read(profileProvider.notifier).updateProfileImage(file);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile image updated successfully'),
            backgroundColor: AppTheme.statusSuccess,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final message = e.toString();
      final needsPermission =
          message.toLowerCase().contains('not allowed') ||
          message.toLowerCase().contains('request permission');
      if (needsPermission) {
        _showChangeRequestSheet(message: message);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.statusError,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  void _showAvatarPopup(
    BuildContext context,
    String name,
    String profileImage,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _ProfileImageViewer(
            name: name,
            profileImage: profileImage,
            imageUrl: _getFullImageUrl(profileImage),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
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
        child: GlassSurface(
          margin: const EdgeInsets.only(bottom: 20),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppVisuals.of(context).accent.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: AppVisuals.of(context).accent),
            ),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: .6,
                    ),
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final colors = AppVisuals.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profileState = ref.watch(profileProvider);
    return AppScaffold(
      appBar: const AppPageBar(title: 'Profile'),
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
                  Text("No profile data", style: theme.textTheme.titleMedium),
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

          final currentAvatarUrl = _getFullImageUrl(data.profileImage);
          if (_lastAvatarImageUrl.isNotEmpty && currentAvatarUrl.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await _evictAvatarUrl(_lastAvatarImageUrl);
            });
          }
          _lastAvatarImageUrl = currentAvatarUrl;

          return SingleChildScrollView(
            // extendBody supplies the floating navigation height as bottom padding.
            // Include it in the scroll extent so Logout can clear the bar.
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom,
            ),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildProfileHeader(data),

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
                        value: data.joiningDate.isNotEmpty
                            ? data.joiningDate
                            : "—",
                        theme: theme,
                        index: 4,
                      ),
                    ],
                  ),
                ),

                GlassSurface(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      'Dark mode',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    secondary: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.accentSurface,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: colors.accent,
                      ),
                    ),
                    value: isDark,
                    onChanged: (_) => themeNotifier.toggleTheme(),
                    activeTrackColor: colors.accent,
                    activeThumbColor: theme.colorScheme.onPrimary,
                    inactiveTrackColor: colors.accentSurface,
                    inactiveThumbColor: colors.muted,
                  ),
                ),
                const SizedBox(height: 12),

                //  LOGOUT
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Material(
                    color: AppTheme.statusError.withValues(alpha: 0.36),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          barrierColor: Colors.black.withValues(alpha: 0.5),
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: AppSurface(
                              padding: const EdgeInsets.all(24),

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
                                          AppTheme.statusError.withValues(
                                            alpha: 0.15,
                                          ),
                                          AppTheme.statusError.withValues(
                                            alpha: 0.05,
                                          ),
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
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            side: BorderSide(
                                              color: theme.dividerColor,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: theme
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          style: FilledButton.styleFrom(
                                            backgroundColor:
                                                AppTheme.statusError,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.statusError.withValues(alpha: 0.68),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              size: 20,
                              color: AppTheme.statusError,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Logout",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.statusError,
                              ),
                            ),
                          ],
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
              CircularProgressIndicator(color: AppVisuals.of(context).accent),
              const SizedBox(height: 16),
              Text("Loading profile...", style: theme.textTheme.bodyMedium),
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

class _ProfileImageViewer extends StatefulWidget {
  final String name;
  final String profileImage;
  final String imageUrl;

  const _ProfileImageViewer({
    required this.name,
    required this.profileImage,
    required this.imageUrl,
  });

  @override
  State<_ProfileImageViewer> createState() => _ProfileImageViewerState();
}

class _ProfileImageViewerState extends State<_ProfileImageViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _backgroundOpacity;
  late Animation<double> _contentOpacity;

  double _dragOffset = 0;
  double _dragScale = 1.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _backgroundOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onVerticalDragStart(DragStartDetails details) {
    setState(() => _isDragging = true);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dy;
      _dragScale = (1 - (_dragOffset.abs() / 600)).clamp(0.5, 1.0);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_dragOffset.abs() > 100 ||
        details.velocity.pixelsPerSecond.dy.abs() > 500) {
      _dismiss();
    } else {
      setState(() {
        _dragOffset = 0;
        _dragScale = 1.0;
        _isDragging = false;
      });
    }
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.imageUrl.isNotEmpty;
    final letter = widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?';

    final bgOpacity = _isDragging
        ? (1 - (_dragOffset.abs() / 400)).clamp(0.3, 1.0)
        : 1.0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.black.withValues(
            alpha: _backgroundOpacity.value * bgOpacity,
          ),
          body: Stack(
            children: [
              GestureDetector(
                onTap: _dismiss,
                child: Container(color: Colors.transparent),
              ),

              // Content
              FadeTransition(
                opacity: _contentOpacity,
                child: Column(
                  children: [
                    SafeArea(
                      bottom: false,
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _dismiss,
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Image
                    Expanded(
                      child: GestureDetector(
                        onVerticalDragStart: _onVerticalDragStart,
                        onVerticalDragUpdate: _onVerticalDragUpdate,
                        onVerticalDragEnd: _onVerticalDragEnd,
                        child: Center(
                          child: Transform.translate(
                            offset: Offset(0, _dragOffset),
                            child: Transform.scale(
                              scale: _dragScale,
                              child: hasImage
                                  ? InteractiveViewer(
                                      minScale: 1.0,
                                      maxScale: 4.0,
                                      child: CachedNetworkImage(
                                        imageUrl: widget.imageUrl,
                                        fit: BoxFit.contain,
                                        width: MediaQuery.of(
                                          context,
                                        ).size.width,
                                        placeholder: (context, url) => SizedBox(
                                          width: MediaQuery.of(
                                            context,
                                          ).size.width,
                                          height: MediaQuery.of(
                                            context,
                                          ).size.width,
                                          child: Container(
                                            color: Colors.grey[900],
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            _buildLetterFallback(letter),
                                      ),
                                    )
                                  : _buildLetterFallback(letter),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLetterFallback(String letter) {
    final size = MediaQuery.of(context).size.width * 0.7;
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryOnLight, AppTheme.PrimaryColor],
        ),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
