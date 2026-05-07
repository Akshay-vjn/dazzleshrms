import 'dart:io';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dazzleshrms/core/api_constants/api_constants.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import 'package:dazzleshrms/core/app_theme/theme_provider.dart';
import 'package:dazzleshrms/core/storage/session_storage.dart';
import 'package:dazzleshrms/core/permissions/permission_provider.dart';
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
  String _lastAvatarImageUrl = '';

  Future<void> _evictAvatarUrl(String url) async {
    if (url.isEmpty) return;
    try {
      await CachedNetworkImage.evictFromCache(url);
      await CachedNetworkImageProvider(url).evict();
      PaintingBinding.instance.imageCache.evict(NetworkImage(url));
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (_) {
    }
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

  String _getFullImageUrl(String profileImage) {
    if (profileImage.isEmpty) return '';
    final url = '${ApiConstants.mediaBaseUrl}$profileImage';
    return url;
  }

  Widget _buildAvatar(String name, String profileImage) {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final imageUrl = _getFullImageUrl(profileImage);
    final hasImage = imageUrl.isNotEmpty;

    return GestureDetector(
      onTap: () => _showAvatarPopup(context, name, profileImage),
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: hasImage
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.dTeal,
                        AppTheme.dGreen,
                      ],
                    ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.dTeal.withOpacity(0.3),
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
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppTheme.dTeal, AppTheme.dGreen],
                          ),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppTheme.dTeal, AppTheme.dGreen],
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
                    ),
                  )
                : Center(
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
          // Edit icon overlay
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showImagePickerSheet(),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.PrimaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 14,
                  color: Colors.white,
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
              child: const Center(
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

  void _showImagePickerSheet() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentProfileImage =
        ref.read(profileProvider).valueOrNull?.profileImage ?? '';
    final currentImageUrl = _getFullImageUrl(currentProfileImage);
    final canRemove = currentProfileImage.isNotEmpty;

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
                'Change Profile Photo',
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
                    color: AppTheme.PrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: AppTheme.PrimaryColor,
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
                    color: AppTheme.dTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: AppTheme.dTeal,
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
              if (canRemove) ...[
                const SizedBox(height: 6),
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.statusError.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppTheme.statusError,
                    ),
                  ),
                  title: const Text('Remove Photo'),
                  subtitle: Text(
                    'Remove your current profile photo',
                    style: TextStyle(color: theme.hintColor, fontSize: 12),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _removeProfilePhoto(currentImageUrl);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeProfilePhoto(String currentImageUrl) async {
    try {
      setState(() => _isUploadingImage = true);

      await _evictAvatarUrl(currentImageUrl);

      await ref.read(profileProvider.notifier).removeProfileImage();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile image removed successfully'),
            backgroundColor: AppTheme.dGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove image: $e'),
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
            backgroundColor: AppTheme.dGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update image: $e'),
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

  void _showAvatarPopup(BuildContext context, String name, String profileImage) {
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
          return FadeTransition(
            opacity: animation,
            child: child,
          );
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

          final currentAvatarUrl = _getFullImageUrl(data.profileImage);
          if (_lastAvatarImageUrl.isNotEmpty && currentAvatarUrl.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await _evictAvatarUrl(_lastAvatarImageUrl);
            });
          }
          _lastAvatarImageUrl = currentAvatarUrl;

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
                                  AppTheme.dTeal,
                                  AppTheme.dGreen,
                                  AppTheme.dTeal,
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
                              child: _buildAvatar(data.name, data.profileImage),
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
    if (_dragOffset.abs() > 100 || details.velocity.pixelsPerSecond.dy.abs() > 500) {
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
          backgroundColor: Colors.black.withValues(alpha: _backgroundOpacity.value * bgOpacity),
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
                                        width: MediaQuery.of(context).size.width,
                                        placeholder: (context, url) => SizedBox(
                                          width: MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context).size.width,
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
          colors: [AppTheme.dTeal, AppTheme.dGreen],
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