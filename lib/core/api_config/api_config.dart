import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

import '../storage/session_storage.dart';
import '../navigation/navigation_keys.dart';

class ApiConfig {
  static bool _handlingUnauthorized = false;

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://192.168.1.184:7907/api",
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        "Content-Type": "application/json",
      },
    ),
  )
    ..interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach bearer token from shared preferences if it exists.
          final token = await SessionStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          if (statusCode == 401 && !_handlingUnauthorized) {
            _handlingUnauthorized = true;
            await SessionStorage.clearSession();

            final ctx = rootNavigatorKey.currentContext;
            if (ctx != null) {
              GoRouter.of(ctx).goNamed('login');
            }
            _handlingUnauthorized = false;
          }
          handler.next(error);
        },
      ),
    )
    ..interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );
}
