import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
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
        debugPrint('DeepLinkService: Captured initial link: $uri');
        _pendingDeepLink = uri;
      }
    } catch (e) {
      debugPrint('DeepLinkService: Error getting initial link: $e');
    }
  }

  /// Process pending deep link after app is built (call from first screen)
  static void processPendingDeepLink() {
    if (_pendingDeepLink != null) {
      debugPrint('DeepLinkService: Processing pending deep link: $_pendingDeepLink');
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
        debugPrint('DeepLinkService: Error listening to links: $e');
      },
    );
  }

  /// Process deep link URI and navigate to appropriate page
  static void _processDeepLink(Uri uri) {
    debugPrint('DeepLinkService: Deep link received: $uri');
    debugPrint('DeepLinkService: Full URI string: ${uri.toString()}');

    // Supabase sends recovery tokens in hash fragment for mobile apps
    final fragment = uri.fragment;
    debugPrint('DeepLinkService: Hash fragment: $fragment');
    
    if (fragment.isEmpty) {
      debugPrint('DeepLinkService: No hash fragment found');
      return;
    }

    // Parse hash fragment parameters
    final fragmentParams = Uri.splitQueryString(fragment);
    final accessToken = fragmentParams['access_token'];
    final refreshToken = fragmentParams['refresh_token'];
    final type = fragmentParams['type'];

    debugPrint('DeepLinkService: Parsed params - access_token: ${accessToken != null ? 'present' : 'missing'}, refresh_token: ${refreshToken != null ? 'present' : 'missing'}, type: $type');

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
        debugPrint('DeepLinkService: No navigator context available');
      }
    } else {
      debugPrint('DeepLinkService: Invalid recovery link - missing required parameters');
      
      // Check for errors in fragment
      final error = fragmentParams['error'];
      final errorDescription = fragmentParams['error_description'];
      if (error != null) {
        debugPrint('DeepLinkService: Error in deep link: $error - $errorDescription');
      }
    }
  }

  /// Dispose and clean up listeners
  static void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }
}
