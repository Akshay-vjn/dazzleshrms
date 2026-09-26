import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/api_constants/api_constants.dart';
import '../../../../core/app_theme/app_theme.dart';

class EmployeeAvatar extends StatelessWidget {
  final String name;
  final String profileImage;
  final double radius;
  final bool enablePreview;

  const EmployeeAvatar({
    super.key,
    required this.name,
    required this.profileImage,
    this.radius = 24,
    this.enablePreview = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageUrl = ApiConstants.resolveMediaUrl(profileImage);
    final hasImage = imageUrl.isNotEmpty;
    final letter = _letter(name);
    final accent = AppTheme.accent(isDark);
    final size = radius * 2;

    final letterStyle = TextStyle(
      color: accent,
      fontWeight: FontWeight.bold,
      fontSize: radius * 0.67,
    );

    final avatarWidget = hasImage
        ? Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: accent.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: CircleAvatar(
              radius: radius,
              backgroundColor: accent.withValues(alpha: 0.12),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Text(letter, style: letterStyle),
                  errorWidget: (_, __, ___) => Text(letter, style: letterStyle),
                ),
              ),
            ),
          )
        : CircleAvatar(
            radius: radius,
            backgroundColor: accent.withValues(alpha: 0.12),
            child: Text(letter, style: letterStyle),
          );

    if (!enablePreview) return avatarWidget;

    return GestureDetector(
      onTap: () => _showImagePopup(context, imageUrl, letter),
      child: avatarWidget,
    );
  }

  String _letter(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }

  void _showImagePopup(BuildContext context, String imageUrl, String letter) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 60,
                    ),
                    child: imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: InteractiveViewer(
                              minScale: 0.8,
                              maxScale: 4.0,
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.contain,
                                placeholder: (_, __) => const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                                errorWidget: (_, __, ___) =>
                                    _popupFallback(letter),
                              ),
                            ),
                          )
                        : _popupFallback(letter),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.close_rounded, size: 24),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _popupFallback(String letter) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.PrimaryColor.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
