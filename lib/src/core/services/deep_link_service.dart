import 'dart:async';
import 'dart:developer';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/routes/names.dart';
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
    final codeParam = uri.queryParameters['code'];
    final typeParam = uri.queryParameters['type'];
    
    // Check for errors in query params first
    final errorParam = uri.queryParameters['error'];
    final errorDescription = uri.queryParameters['error_description'];
    
    if (isPasswordResetPath && errorParam != null) {
      // Link has error (expired or invalid)
      log('Error in query params: $errorParam - $errorDescription', name: 'DeepLinkService', level: 900);
      final context = AppRouter.navigatorKey.currentContext;
      if (context != null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.resetLinkError,
          (route) => false,
          arguments: errorDescription?.replaceAll('+', ' ') ?? AuthStrings.linkExpiredMessage,
        );
      }
      return;
    }

    if (isPasswordResetPath && codeParam != null) {
      // Supabase PKCE flow: Exchange code for session tokens
      log('Found password reset code in query params', name: 'DeepLinkService', level: 800);
      
      final context = AppRouter.navigatorKey.currentContext;
      if (context != null) {
        getIt<AuthCubit>().handlePasswordResetCode(
          context: context,
          code: codeParam,
        );
      } else {
        log('No navigator context available', name: 'DeepLinkService', level: 900);
      }
      return;
    }

    // Legacy flow: Check hash fragment for tokens (in case Supabase changes behavior)
    if (isPasswordResetPath || typeParam == 'recovery') {
      final fragment = uri.fragment;
      log('Hash fragment: ${fragment.isEmpty ? "(empty)" : fragment}', name: 'DeepLinkService', level: 800);
      
      if (fragment.isNotEmpty) {
        // Parse hash fragment parameters
        final fragmentParams = Uri.splitQueryString(fragment);
        final accessToken = fragmentParams['access_token'];
        final refreshToken = fragmentParams['refresh_token'];
        final type = fragmentParams['type'];

        log('Parsed hash params - access_token: ${accessToken != null ? 'present' : 'missing'}, refresh_token: ${refreshToken != null ? 'present' : 'missing'}, type: $type', name: 'DeepLinkService', level: 800);

        // Handle password reset with tokens (type=recovery)
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
          return;
        }

        // Check for errors in fragment
        final error = fragmentParams['error'];
        final fragmentErrorDescription = fragmentParams['error_description'];
        if (error != null) {
          log('Error in hash fragment: $error - $fragmentErrorDescription', name: 'DeepLinkService', level: 900);
          final context = AppRouter.navigatorKey.currentContext;
          if (context != null) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RoutesName.resetLinkError,
              (route) => false,
              arguments: fragmentErrorDescription?.replaceAll('+', ' ') ?? 'Password reset link is invalid or has expired',
            );
          }
          return;
        }
      }

      // No code, no hash fragment with tokens - invalid link
      log('No recovery code or tokens found in deep link', name: 'DeepLinkService', level: 900);
      final context = AppRouter.navigatorKey.currentContext;
      if (context != null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.resetLinkError,
          (route) => false,
          arguments: 'Password reset link is invalid or has expired',
        );
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
