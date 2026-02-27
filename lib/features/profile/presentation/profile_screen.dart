import 'dart:async';
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
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Drives the organic blob morphing
  late AnimationController _morphController;

  late List<AnimationController> _cardControllers;
  late List<Animation<Offset>> _cardSlideAnimations;
  late List<Animation<double>> _cardFadeAnimations;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.1, 0.7, curve: Curves.easeOutBack)),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.2, 1.0, curve: Curves.easeOut)),
    );

    _shimmerController = AnimationController(duration: const Duration(milliseconds: 1400), vsync: this);
    _shimmerAnimation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this)..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Slow organic morph — blobs breathe and shift
    _morphController = AnimationController(duration: const Duration(seconds: 8), vsync: this)..repeat();

    _cardControllers = List.generate(5, (i) => AnimationController(duration: const Duration(milliseconds: 500), vsync: this));
    _cardSlideAnimations = _cardControllers.map((c) => Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero).animate(CurvedAnimation(parent: c, curve: Curves.easeOut))).toList();
    _cardFadeAnimations = _cardControllers.map((c) => Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: c, curve: Curves.easeOut))).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile();
      _runEntranceSequence();
    });
  }

  Future<void> _runEntranceSequence() async {
    _entranceController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _shimmerController.forward();
    for (int i = 0; i < _cardControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) _cardControllers[i].forward();
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _morphController.dispose();
    for (final c in _cardControllers) c.dispose();
    super.dispose();
  }

  Color _neuBase(bool isDark) => isDark ? const Color(0xFF1E1E28) : const Color(0xFFE8ECF0);
  Color _neuShadowDark(bool isDark) => isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.15);
  Color _neuShadowLight(bool isDark) => isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.08);

  BoxDecoration _neuDecoration({required bool isDark, double radius = 20, bool inset = false}) {
    if (inset) {
      return BoxDecoration(color: _neuBase(isDark), borderRadius: BorderRadius.circular(radius), boxShadow: [
        BoxShadow(color: _neuShadowDark(isDark), blurRadius: 8, offset: const Offset(3, 3)),
        BoxShadow(color: _neuShadowLight(isDark), blurRadius: 8, offset: const Offset(-3, -3)),
      ]);
    }
    return BoxDecoration(color: _neuBase(isDark), borderRadius: BorderRadius.circular(radius), boxShadow: [
      BoxShadow(color: _neuShadowDark(isDark), blurRadius: 16, offset: const Offset(6, 6)),
      BoxShadow(color: _neuShadowLight(isDark), blurRadius: 16, offset: const Offset(-6, -6)),
    ]);
  }

  Widget _buildHeader(dynamic data, ThemeData theme, bool isDark) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entranceController, _shimmerController, _pulseController, _morphController]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: AspectRatio(
              aspectRatio: 1.15,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                decoration: _neuDecoration(isDark: isDark, radius: 28),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // ── Ink Blob Painter ───────────────────────────────
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _InkBlobPainter(
                            phase: _morphController.value * 2 * math.pi,
                            isDark: isDark,
                            primaryColor: AppTheme.dTeal,
                            accentColor: AppTheme.dGreen,
                          ),
                        ),
                      ),

                      // ── Shimmer ────────────────────────────────────────
                      Positioned.fill(
                        child: ShaderMask(
                          blendMode: BlendMode.srcATop,
                          shaderCallback: (bounds) => LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.centerRight,
                            stops: const [0.0, 0.5, 1.0],
                            colors: [Colors.transparent, Colors.white.withOpacity(0.07), Colors.transparent],
                            transform: _ShimmerTransform(_shimmerAnimation.value, Rect.zero),
                          ).createShader(bounds),
                          child: Container(color: Colors.white.withOpacity(0.001)),
                        ),
                      ),

                      // ── Content ────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) => Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: GestureDetector(
                                    onTap: () => _showAvatarPopup(context, data.name),
                                    child: Container(
                                      width: 92, height: 92,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppTheme.dTeal, AppTheme.dGreen]),
                                        boxShadow: [
                                          BoxShadow(color: AppTheme.dTeal.withOpacity(isDark ? 0.45 : 0.35), blurRadius: 16 + (_pulseAnimation.value - 1) * 60, spreadRadius: (_pulseAnimation.value - 1) * 10, offset: const Offset(0, 4)),
                                          BoxShadow(color: _neuShadowDark(isDark), blurRadius: 10, offset: const Offset(4, 4)),
                                          BoxShadow(color: _neuShadowLight(isDark), blurRadius: 10, offset: const Offset(-4, -4)),
                                        ],
                                      ),
                                      child: Center(child: Text(data.name.isNotEmpty ? data.name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1))),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(data.name.isNotEmpty ? data.name : "—", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: isDark ? Colors.white.withOpacity(0.92) : const Color(0xFF1A1A2E)), textAlign: TextAlign.center),
                            const SizedBox(height: 6),
                            if (data.designation.isNotEmpty)
                              Text(data.designation, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? Colors.white.withOpacity(0.4) : const Color(0xFF6B7280)), textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 10, runSpacing: 8,
                              children: [_buildNeuBadge(label: data.role.isNotEmpty ? data.role : "N/A", icon: Icons.verified_outlined, isDark: isDark, useGradient: true)],
                            ),
                          ],
                        ),
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
  }

  Widget _buildNeuBadge({required String label, required IconData icon, required bool isDark, required bool useGradient}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: useGradient
          ? BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppTheme.dTeal, AppTheme.dGreen]), borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: AppTheme.dTeal.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))])
          : _neuDecoration(isDark: isDark, radius: 30, inset: true),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: useGradient ? Colors.white : isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF6B7280)),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 0.2, color: useGradient ? Colors.white : isDark ? Colors.white.withOpacity(0.55) : const Color(0xFF4B5563))),
      ]),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String label, required String value, required ThemeData theme, required int index}) {
    return SlideTransition(
      position: _cardSlideAnimations[index],
      child: FadeTransition(
        opacity: _cardFadeAnimations[index],
        child: Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(
          leading: Icon(icon, color: AppTheme.PrimaryColor),
          title: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 12)),
          subtitle: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        )),
      ),
    );
  }

  void _showAvatarPopup(BuildContext context, String name) {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 200, height: 200,
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppTheme.dTeal, AppTheme.dGreen]),
                boxShadow: [BoxShadow(color: AppTheme.dTeal.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, 10)), BoxShadow(color: Colors.black.withOpacity(isDark ? 0.5 : 0.2), blurRadius: 20, offset: const Offset(6, 6))]),
            child: Center(child: Text(letter, style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w800, color: Colors.white))),
          ),
          const SizedBox(height: 20),
        ]),
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
        title: Text("Profile", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 8.0), child: IconButton(
            icon: Icon(themeNotifier.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () => themeNotifier.toggleTheme(),
          )),
        ],
      ),
      body: profileState.when(
        data: (data) {
          if (data == null) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.person_off_outlined, size: 64, color: theme.textTheme.bodySmall?.color?.withOpacity(0.3)), const SizedBox(height: 16), Text("No profile data", style: theme.textTheme.titleMedium), const SizedBox(height: 24), FilledButton.icon(onPressed: () => ref.read(profileProvider.notifier).loadProfile(), icon: const Icon(Icons.refresh), label: const Text("Retry"))]));
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(children: [
              _buildHeader(data, theme, isDark),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(padding: const EdgeInsets.only(left: 4, bottom: 12), child: Text("Employee Information", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                  _buildInfoCard(icon: Icons.badge_outlined, label: "Employee ID", value: data.code.isNotEmpty ? data.code : "—", theme: theme, index: 0),
                  _buildInfoCard(icon: Icons.phone_outlined, label: "Phone Number", value: data.mobile.isNotEmpty ? data.mobile : "—", theme: theme, index: 1),
                  _buildInfoCard(icon: Icons.business_outlined, label: "Designation", value: data.designation.isNotEmpty ? data.designation : "—", theme: theme, index: 2),
                  _buildInfoCard(icon: Icons.store_outlined, label: "Store", value: data.store.name.isNotEmpty ? data.store.name : data.store.shortForm.isNotEmpty ? data.store.shortForm : "—", theme: theme, index: 3),
                  _buildInfoCard(icon: Icons.calendar_today_outlined, label: "Joining Date", value: data.joiningDate.isNotEmpty ? data.joiningDate : "—", theme: theme, index: 4),
                ]),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity, height: 56,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: AppTheme.statusError, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        barrierColor: Colors.black.withOpacity(0.5),
                        builder: (context) => Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight, borderRadius: BorderRadius.circular(24)),
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              Container(width: 72, height: 72, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppTheme.statusError.withValues(alpha: 0.15), AppTheme.statusError.withValues(alpha: 0.05)]), shape: BoxShape.circle), child: const Icon(Icons.logout_rounded, size: 36, color: AppTheme.statusError)),
                              const SizedBox(height: 20),
                              Text("Logout", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              Text("Are you sure you want to logout from your account?", textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
                              const SizedBox(height: 28),
                              Row(children: [
                                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context, false), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: theme.dividerColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text("Cancel", style: TextStyle(fontWeight: FontWeight.w600, color: theme.textTheme.bodyMedium?.color)))),
                                const SizedBox(width: 12),
                                Expanded(child: FilledButton(onPressed: () => Navigator.pop(context, true), style: FilledButton.styleFrom(backgroundColor: AppTheme.statusError, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Logout", style: TextStyle(fontWeight: FontWeight.w600)))),
                              ]),
                            ]),
                          ),
                        ),
                      );
                      if (shouldLogout == true) {
                        await SessionStorage.clearSession();
                        ref.read(permissionProvider.notifier).clearPermissions();
                        if (!context.mounted) return;
                        context.goNamed('login');
                      }
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text("Logout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ]),
          );
        },
        loading: () => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(color: AppTheme.PrimaryColor), const SizedBox(height: 16), Text("Loading profile...", style: theme.textTheme.bodyMedium)])),
        error: (err, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.error_outline, size: 64, color: AppTheme.statusError.withOpacity(0.7)), const SizedBox(height: 16), Text("Something went wrong", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(err.toString(), textAlign: TextAlign.center, style: theme.textTheme.bodySmall), const SizedBox(height: 24), FilledButton.icon(onPressed: () => ref.read(profileProvider.notifier).loadProfile(), icon: const Icon(Icons.refresh), label: const Text("Try Again"))]))),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INK BLOB PAINTER — Liquid watercolor / lava-lamp organic shapes
//
// Draws 5 overlapping organic blobs using:
//   • Polar coordinate sine-sum distortion for blob outlines
//   •  Per-blob radial gradient fill (like ink bleeding into wet paper)
//   • Soft blur halos underneath
//   • A fine stipple texture (tiny dots) for the paper-grain feel
//   • Ink splatter dots scattered near blob edges
// ─────────────────────────────────────────────────────────────────────────────
class _InkBlobPainter extends CustomPainter {
  final double phase; // 0..2π
  final bool isDark;
  final Color primaryColor;
  final Color accentColor;

  _InkBlobPainter({
    required this.phase,
    required this.isDark,
    required this.primaryColor,
    required this.accentColor,
  });

  // Each blob: [centerX%, centerY%, baseRadius%, speedMultiplier, colorT(0=primary,1=accent)]
  static const _blobDefs = [
    [0.75, 0.18, 0.32, 1.0, 0.0],
    [0.20, 0.25, 0.26, 0.7, 0.5],
    [0.82, 0.72, 0.28, 1.3, 1.0],
    [0.15, 0.78, 0.22, 0.9, 0.3],
    [0.50, 0.50, 0.18, 1.6, 0.7],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Step 1: Halo blur under each blob ──────────────────────────────────
    for (final def in _blobDefs) {
      final cx = def[0] * w;
      final cy = def[1] * h;
      final r = def[2] * math.min(w, h);
      final colorT = def[4];
      final blobColor = Color.lerp(primaryColor, accentColor, colorT)!;

      canvas.drawCircle(
        Offset(cx, cy),
        r * 1.35,
        Paint()
          ..color = blobColor.withOpacity(isDark ? 0.055 : 0.035)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
      );
    }

    // ── Step 2: Draw each blob shape ───────────────────────────────────────
    for (int b = 0; b < _blobDefs.length; b++) {
      final def = _blobDefs[b];
      final cx = def[0] * w;
      final cy = def[1] * h;
      final baseR = def[2] * math.min(w, h);
      final speed = def[3];
      final colorT = def[4];

      final blobColor = Color.lerp(primaryColor, accentColor, colorT)!;
      final blobPhase = phase * speed + b * 1.3;

      // Build blob outline via polar distortion
      final path = _buildBlobPath(cx, cy, baseR, blobPhase);

      // Radial gradient — dense at center, fades to transparent (ink bleed)
      final rect = Rect.fromCircle(center: Offset(cx, cy), radius: baseR);
      final gradient = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          blobColor.withOpacity(isDark ? 0.13 : 0.08),
          blobColor.withOpacity(isDark ? 0.07 : 0.045),
          blobColor.withOpacity(0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      );

      canvas.drawPath(
        path,
        Paint()..shader = gradient.createShader(rect),
      );

      // Thin outline stroke — like the dried ink edge
      canvas.drawPath(
        path,
        Paint()
          ..color = blobColor.withOpacity(isDark ? 0.16 : 0.09)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }

    // ── Step 3: Ink splatter micro-dots ────────────────────────────────────
    _drawSplatter(canvas, size);

    // ── Step 4: Paper grain stipple ────────────────────────────────────────
    _drawStipple(canvas, size);

    // ── Step 5: Central ink pool — deep glow behind avatar ─────────────────
    canvas.drawCircle(
      Offset(w / 2, h / 2),
      w * 0.22,
      Paint()
        ..color = primaryColor.withOpacity(isDark ? 0.07 : 0.04)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );
  }

  Path _buildBlobPath(double cx, double cy, double r, double phase) {
    const steps = 64;
    final path = Path();
    for (int i = 0; i <= steps; i++) {
      final angle = (i / steps) * 2 * math.pi;
      // Stack multiple sine harmonics for organic feel
      final distort = 1.0
          + 0.13 * math.sin(3 * angle + phase)
          + 0.07 * math.sin(5 * angle + phase * 1.2)
          + 0.05 * math.cos(7 * angle + phase * 0.8)
          + 0.03 * math.sin(11 * angle + phase * 1.5);
      final rr = r * distort;
      final x = cx + rr * math.cos(angle);
      final y = cy + rr * math.sin(angle);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  void _drawSplatter(Canvas canvas, Size size) {
    final rng = math.Random(7);
    // 30 tiny ink drops scattered across the header
    for (int i = 0; i < 30; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final dotR = 0.6 + rng.nextDouble() * 1.8;
      final colorT = rng.nextDouble();
      final color = Color.lerp(primaryColor, accentColor, colorT)!;
      canvas.drawCircle(
        Offset(x, y),
        dotR,
        Paint()..color = color.withOpacity(isDark ? 0.12 : 0.07),
      );
    }
  }

  void _drawStipple(Canvas canvas, Size size) {
    // Very fine grain — fixed seed so it's stable
    final rng = math.Random(99);
    final paint = Paint()..color = primaryColor.withOpacity(isDark ? 0.04 : 0.025);
    for (int i = 0; i < 120; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        0.5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _InkBlobPainter old) =>
      old.phase != phase || old.isDark != isDark;
}

// ── Shimmer transform helper ───────────────────────────────────────────────────
class _ShimmerTransform extends GradientTransform {
  final double value;
  final Rect bounds;
  const _ShimmerTransform(this.value, this.bounds);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * value, 0, 0);
}