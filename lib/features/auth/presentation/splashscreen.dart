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
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
    _startSplashFlow();
  }

  void _startSplashFlow() {
    Timer(const Duration(seconds: 3), () async {
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: Container(
                  height: 230,
                  width: 230,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.PrimaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(36),
                  ),
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
            ),

            const SizedBox(height: 32),

            SlideTransition(
              position: _textSlide,
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
          ],
        ),
      ),
    );
  }
}
