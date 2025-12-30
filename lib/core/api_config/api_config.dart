import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

import '../storage/session_storage.dart';
import '../navigation/navigation_keys.dart';
import '../../features/auth/data/models/refresh_token_model.dart';
import '../api_constants/api_constants.dart';

class ApiConfig {
  // Base configuration constants
  static const String _baseUrl = "http://192.168.1.184:7907/api";
  static const Duration _connectTimeout = Duration(seconds: 20);
  static const Duration _receiveTimeout = Duration(seconds: 20);

  // State management for token refresh
  static bool _handlingUnauthorized = false;
  static bool _isRefreshing = false;
  static final List<_PendingRequest> _pendingRequests = [];

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      headers: {
        "Content-Type": "application/json",
      },
    ),
  )
    ..interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip adding token for refresh token request to avoid infinite loop
          if (!_isRefreshTokenRequest(options)) {
            final token = await SessionStorage.getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;

          // Skip refresh logic for refresh token endpoint itself
          if (statusCode == 401 && 
              !_handlingUnauthorized && 
              !_isRefreshTokenRequest(error.requestOptions)) {
            _handlingUnauthorized = true;

            try {
              // Try to refresh the token
              final refreshToken = await SessionStorage.getRefreshToken();
              
              if (refreshToken != null && refreshToken.isNotEmpty) {
                // If already refreshing, queue this request
                if (_isRefreshing) {
                  developer.log(
                    'Token refresh in progress, queueing request: ${error.requestOptions.path}',
                    name: 'ApiConfig',
                  );
                  _pendingRequests.add(_PendingRequest(
                    requestOptions: error.requestOptions,
                    handler: handler,
                  ));
                  _handlingUnauthorized = false;
                  return;
                }

                _isRefreshing = true;
                developer.log(
                  'Access token expired, attempting to refresh token',
                  name: 'ApiConfig',
                );

                // Create a new Dio instance without interceptors to avoid recursion
                final refreshDio = Dio(
                  BaseOptions(
                    baseUrl: _baseUrl,
                    connectTimeout: _connectTimeout,
                    receiveTimeout: _receiveTimeout,
                    headers: {
                      "Content-Type": "application/json",
                    },
                  ),
                );

                try {
                  final refreshResponse = await refreshDio.post(
                    ApiConstants.refreshToken,
                    data: {
                      "refreshToken": refreshToken,
                    },
                  );

                  // Validate response structure
                  if (refreshResponse.data == null) {
                    throw Exception("Refresh response is null");
                  }

                  final refreshTokenModel = RefreshTokenModel.fromJson(refreshResponse.data);

                  // Validate refresh response
                  if (refreshTokenModel.error == false && 
                      refreshTokenModel.data.token.isNotEmpty) {
                    developer.log(
                      'Token refresh successful',
                      name: 'ApiConfig',
                    );

                    // Update tokens in storage
                    await SessionStorage.updateTokens(
                      token: refreshTokenModel.data.token,
                      refreshToken: refreshTokenModel.data.refreshToken,
                    );

                    // Retry the original request with new token
                    final opts = error.requestOptions;
                    opts.headers['Authorization'] = 'Bearer ${refreshTokenModel.data.token}';

                    try {
                      final response = await dio.fetch(opts);
                      
                      // Process any pending requests
                      _processPendingRequests(refreshTokenModel.data.token);
                      
                      _isRefreshing = false;
                      _handlingUnauthorized = false;
                      handler.resolve(response);
                      return;
                    } catch (retryError) {
                      // Retry failed even with new token
                      developer.log(
                        'Request retry failed after token refresh: ${retryError.toString()}',
                        name: 'ApiConfig',
                        error: retryError,
                      );
                      _isRefreshing = false;
                      _handlingUnauthorized = false;
                      _clearPendingRequests();
                      
                      // Ensure we pass a DioException
                      final dioError = retryError is DioException
                          ? retryError
                          : DioException(
                              requestOptions: error.requestOptions,
                              error: retryError,
                              type: DioExceptionType.unknown,
                            );
                      handler.reject(dioError);
                      return;
                    }
                  } else {
                    throw Exception(
                      "Invalid refresh response: error=${refreshTokenModel.error}, "
                      "tokenEmpty=${refreshTokenModel.data.token.isEmpty}",
                    );
                  }
                } catch (refreshError) {
                  // Refresh failed, log and clear session
                  developer.log(
                    'Token refresh failed: ${refreshError.toString()}',
                    name: 'ApiConfig',
                    error: refreshError,
                  );
                  
                  await SessionStorage.clearSession();
                  _isRefreshing = false;
                  _handlingUnauthorized = false;
                  _clearPendingRequests();

                  final ctx = rootNavigatorKey.currentContext;
                  if (ctx != null) {
                    GoRouter.of(ctx).goNamed('login');
                  }
                  
                  // Reject the original error
                  handler.reject(error);
                  return;
                }
              } else {
                // No refresh token available
                developer.log(
                  'No refresh token available, redirecting to login',
                  name: 'ApiConfig',
                );
                await SessionStorage.clearSession();
                _handlingUnauthorized = false;

                final ctx = rootNavigatorKey.currentContext;
                if (ctx != null) {
                  GoRouter.of(ctx).goNamed('login');
                }
              }
            } catch (e, stackTrace) {
              // Error during refresh process
              developer.log(
                'Error during token refresh process: ${e.toString()}',
                name: 'ApiConfig',
                error: e,
                stackTrace: stackTrace,
              );
              
              await SessionStorage.clearSession();
              _handlingUnauthorized = false;
              _clearPendingRequests();

              final ctx = rootNavigatorKey.currentContext;
              if (ctx != null) {
                GoRouter.of(ctx).goNamed('login');
              }
              
              handler.reject(error);
              return;
            }
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

  static bool _isRefreshTokenRequest(RequestOptions options) {
    // Check if this is a refresh token request by checking the path
    final path = options.path;
    final normalizedPath = path.split('?').first; // Remove query params
    
    // Check if the path matches the refresh token endpoint
    return normalizedPath == ApiConstants.refreshToken || 
           normalizedPath.contains(ApiConstants.refreshToken);
  }

  static void _processPendingRequests(String newToken) {
    final pendingCount = _pendingRequests.length;
    if (pendingCount > 0) {
      developer.log(
        'Processing $pendingCount pending request(s) with new token',
        name: 'ApiConfig',
      );
    }
    
    final requestsToProcess = List<_PendingRequest>.from(_pendingRequests);
    _pendingRequests.clear();
    
    for (var pendingRequest in requestsToProcess) {
      final opts = pendingRequest.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newToken';
      dio.fetch(opts).then(
        (response) {
          developer.log(
            'Pending request succeeded: ${opts.path}',
            name: 'ApiConfig',
          );
          pendingRequest.handler.resolve(response);
        },
        onError: (error) {
          developer.log(
            'Pending request failed: ${opts.path} - ${error.toString()}',
            name: 'ApiConfig',
            error: error,
          );
          // Ensure we pass a DioException
          final dioError = error is DioException
              ? error
              : DioException(
                  requestOptions: opts,
                  error: error,
                  type: DioExceptionType.unknown,
                );
          pendingRequest.handler.reject(dioError);
        },
      );
    }
  }

  static void _clearPendingRequests() {
    final pendingCount = _pendingRequests.length;
    if (pendingCount > 0) {
      developer.log(
        'Clearing $pendingCount pending request(s) due to refresh failure',
        name: 'ApiConfig',
      );
    }
    
    final requestsToClear = List<_PendingRequest>.from(_pendingRequests);
    _pendingRequests.clear();
    
    for (var pendingRequest in requestsToClear) {
      pendingRequest.handler.reject(
        DioException(
          requestOptions: pendingRequest.requestOptions,
          error: Exception("Token refresh failed"),
          type: DioExceptionType.unknown,
        ),
      );
    }
  }
}

class _PendingRequest {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;

  _PendingRequest({
    required this.requestOptions,
    required this.handler,
  });
}
