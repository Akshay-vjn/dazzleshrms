import 'dart:math' as math;

import 'package:dazzleshrms/core/app_theme/app_scaffold.dart';
import 'package:dazzleshrms/core/app_theme/app_visuals.dart';
import 'package:dazzleshrms/core/storage/session_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Minimal luxury splash: just the "D".
///
/// The letter first appears as a fine outline, turning slowly toward you in
/// 3D. Then the solid letter opens from its center like an iris, filling the
/// outline completely.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _outline;
  late final Animation<double> _turn;
  late final Animation<double> _iris;
  late final Animation<double> _text;

  @override
  void initState() {
    super.initState();

    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );

    _outline = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.0, 0.28, curve: Curves.easeOut),
    );
    _turn = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.0, 0.70, curve: Curves.easeOutCubic),
    );
    _iris = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.32, 0.70, curve: Curves.easeInOutCubic),
    );
    _text = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.68, 1.0, curve: Curves.easeOutCubic),
    );

    _c.forward();
    _startSplashFlow();
  }

  Future<void> _startSplashFlow() async {
    final results = await Future.wait([
      SessionStorage.getToken(),
      SessionStorage.getRole(),
      Future<void>.delayed(const Duration(milliseconds: 3700)),
    ]);

    if (!mounted) return;

    final token = results[0] as String?;
    final role = ((results[1] as String?) ?? '').toLowerCase();

    if (token != null && token.isNotEmpty) {
      context.goNamed(role == 'store' ? 'store_qr' : 'home');
    } else {
      context.goNamed('login');
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppVisuals.of(context).accent;

    const double size = 170;

    final outlineD = Text(
      'D',
      style: TextStyle(
        fontFamily: 'Dazzles',
        fontSize: size,
        height: 1.0,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeJoin = StrokeJoin.round
          ..color = accent,
      ),
    );

    final solidD = Text(
      'D',
      style: TextStyle(
        fontFamily: 'Dazzles',
        fontSize: size,
        height: 1.0,
        color: accent,
      ),
    );

    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            // Turns from 40 degrees away to facing front.
            final double angle = 0.7 * (1.0 - _turn.value);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0012)
                    ..rotateY(angle),
                  child: Opacity(
                    opacity: _outline.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        outlineD,
                        ClipPath(
                          clipper: _IrisClipper(progress: _iris.value),
                          child: solidD,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Opacity(
                  opacity: _text.value,
                  child: Transform.translate(
                    offset: Offset(0, 12 * (1.0 - _text.value)),
                    child: Text(
                      'DAZZLES HRMS',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 8 - 5 * _text.value,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Circular reveal that grows from the center of the child until it covers it.
class _IrisClipper extends CustomClipper<Path> {
  _IrisClipper({required this.progress});

  final double progress;

  @override
  Path getClip(Size size) {
    final Offset center = size.center(Offset.zero);
    final double maxRadius = math.sqrt(
      size.width * size.width + size.height * size.height,
    ) / 2;
    return Path()
      ..addOval(Rect.fromCircle(center: center, radius: maxRadius * progress));
  }

  @override
  bool shouldReclip(_IrisClipper old) => old.progress != progress;
}