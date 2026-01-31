import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/app_theme/app_theme.dart';
import 'core/app_theme/theme_provider.dart';
import 'core/navigation/app_router.dart';
import 'core/network/connectivity_provider.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint("Firebase initialized successfully");


  runApp(
    const ProviderScope(
      child: DazzlesHrmsApp(),
    ),
  );
}

class DazzlesHrmsApp extends ConsumerWidget {
  const DazzlesHrmsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    ref.listen(connectivityStatusProvider, (previous, next) {
      if (next == ConnectivityStatus.isDisconnected) {
        router.push('/no-internet');
      } else if (next == ConnectivityStatus.isConnected &&
          previous == ConnectivityStatus.isDisconnected) {
        if (router.canPop()) {
          router.pop();
        } else {
          router.go('/home');
        }
      }
    });

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Dazzles HRMS',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
