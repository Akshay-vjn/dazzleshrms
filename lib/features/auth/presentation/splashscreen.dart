import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dazzleshrms/core/app_theme/app_theme.dart';
import 'package:dazzleshrms/core/storage/session_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _shimmerController;

  late final Animation<double> _containerFade;
  late final Animation<double> _logoExpand;
  late final Animation<double> _logoFade;
  late final Animation<double> _textOpacity;
  late final Animation<double> _textScale;
  late final Animation<double> _shimmerPosition;

  @override
  void initState() {
    super.initState();

    // Main animation controller
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Shimmer effect controller
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Container fades in quickly
    _containerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Logo expands from center
    _logoExpand = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.15, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    // Logo fades in with expand
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.15, 0.5, curve: Curves.easeIn),
      ),
    );

    // Text appears with scale
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.55, 0.85, curve: Curves.easeIn),
      ),
    );

    _textScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.55, 0.85, curve: Curves.easeOutBack),
      ),
    );

    // Shimmer moves across
    _shimmerPosition = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.linear,
      ),
    );

    _mainController.forward();
    _startSplashFlow();
  }

  void _startSplashFlow() {
    Timer(const Duration(milliseconds: 2500), () async {
      final token = await SessionStorage.getToken();

      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        context.goNamed('home');
      } else {
        context.goNamed('login');
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo Container
            AnimatedBuilder(
              animation: Listenable.merge([_mainController, _shimmerController]),
              builder: (context, child) {
                return Opacity(
                  opacity: _containerFade.value,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Container with shimmer overlay
                      Container(
                        height: 230,
                        width: 230,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.PrimaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(36),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(36),
                          child: AnimatedBuilder(
                            animation: _shimmerController,
                            builder: (context, child) {
                              return ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.15),
                                      Colors.transparent,
                                    ],
                                    stops: [
                                      _shimmerPosition.value - 0.3,
                                      _shimmerPosition.value,
                                      _shimmerPosition.value + 0.3,
                                    ],
                                  ).createShader(bounds);
                                },
                                child: Container(
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Expanding and fading logo
                      Transform.scale(
                        scale: _logoExpand.value,
                        child: Opacity(
                          opacity: _logoFade.value,
                          child: Text(
                            "D",
                            style: TextStyle(
                              fontFamily: 'Dazzles',
                              fontSize: 150,
                              color: AppTheme.PrimaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Animated Text with scale
            AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _textScale.value,
                  child: Opacity(
                    opacity: _textOpacity.value,
                    child: Column(
                      children: [
                        Text(
                          "DAZZLES HRMS",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Human Resource Management",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}