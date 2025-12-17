import 'dart:async';
import 'dart:developer';
import 'package:app_links/app_links.dart';
import 'package:flutter/scheduler.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/routes/router.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/auth_cubit.dart';

/// Service to handle deep link navigation for password reset
/// Listens for deep links from iOS/Android and processes them
class DeepLinkService {
  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _linkSubscription;
  static Uri? _pendingDeepLink;

  /// Initialize deep link listener for mobile platforms only
  static Future<void> initialize() async {
    await _captureInitialLink();
    _handleIncomingLinks();
  }

  /// Capture initial link but don't process yet (context not ready)
  static Future<void> _captureInitialLink() async {
    try {
      final Uri? uri = await _appLinks.getInitialLink();
      if (uri != null) {
        log('Captured initial link: $uri', name: 'DeepLinkService', level: 800);
        _pendingDeepLink = uri;
      }
    } catch (e) {
      log('Error getting initial link: $e', name: 'DeepLinkService', level: 900, error: e);
    }
  }

  /// Process pending deep link after app is built (call from first screen)
  static void processPendingDeepLink() {
    if (_pendingDeepLink != null) {
      log('Processing pending deep link: $_pendingDeepLink', name: 'DeepLinkService', level: 800);
      // Defer to next frame to ensure navigation is ready
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (_pendingDeepLink != null) {
          _processDeepLink(_pendingDeepLink!);
          _pendingDeepLink = null;
        }
      });
    }
  }

  /// Handle deep links while app is running (warm start)
  static void _handleIncomingLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) => _processDeepLink(uri),
      onError: (e) {
        log('Error listening to links: $e', name: 'DeepLinkService', level: 900, error: e);
      },
    );
  }

  /// Process deep link URI and navigate to appropriate page
  static void _processDeepLink(Uri uri) {
    log('Deep link received: $uri', name: 'DeepLinkService', level: 800);
    log('Path: ${uri.path}, Query params: ${uri.queryParameters}', name: 'DeepLinkService', level: 800);

    // Check if this is a password reset link by path or query params
    final isPasswordResetPath = uri.path.contains('reset-password');
    final typeParam = uri.queryParameters['type'];
    final isPasswordResetType = typeParam == 'recovery';

    if (isPasswordResetPath || isPasswordResetType) {
      // Supabase sends recovery tokens in hash fragment for mobile apps
      final fragment = uri.fragment;
      log('Hash fragment: $fragment', name: 'DeepLinkService', level: 800);
      
      if (fragment.isEmpty) {
        log('No hash fragment found - link may have expired or is invalid', name: 'DeepLinkService', level: 900);
        // Show error to user - tokens are required for password reset
        final context = AppRouter.navigatorKey.currentContext;
        if (context != null) {
          getIt<AuthCubit>().showError('Password reset link is invalid or has expired. Please request a new one.');
        }
        return;
      }

      // Parse hash fragment parameters
      final fragmentParams = Uri.splitQueryString(fragment);
      final accessToken = fragmentParams['access_token'];
      final refreshToken = fragmentParams['refresh_token'];
      final type = fragmentParams['type'];

      log('Parsed params - access_token: ${accessToken != null ? 'present' : 'missing'}, refresh_token: ${refreshToken != null ? 'present' : 'missing'}, type: $type', name: 'DeepLinkService', level: 800);

      // Handle password reset (type=recovery)
      if (type == 'recovery' && accessToken != null && refreshToken != null) {
        final context = AppRouter.navigatorKey.currentContext;
        if (context != null) {
          getIt<AuthCubit>().handlePasswordResetDeepLink(
            context: context,
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        } else {
          log('No navigator context available', name: 'DeepLinkService', level: 900);
        }
      } else {
        log('Invalid recovery link - missing required parameters', name: 'DeepLinkService', level: 900);
        
        // Check for errors in fragment
        final error = fragmentParams['error'];
        final errorDescription = fragmentParams['error_description'];
        if (error != null) {
          log('Error in deep link: $error - $errorDescription', name: 'DeepLinkService', level: 900);
          final context = AppRouter.navigatorKey.currentContext;
          if (context != null) {
            getIt<AuthCubit>().showError('Password reset failed: ${errorDescription ?? error}');
          }
        }
      }
    } else {
      log('Unhandled deep link path: ${uri.path}', name: 'DeepLinkService', level: 800);
    }
  }

  /// Dispose and clean up listeners
  static void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }
}
