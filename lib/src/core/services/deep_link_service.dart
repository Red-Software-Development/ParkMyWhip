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

    if (uri.path.contains('reset-password')) {
      // Supabase sends tokens in the fragment (hash), not query params
      // Fragment format: #access_token=xxx&refresh_token=xxx&type=recovery
      final fragment = uri.fragment;
      debugPrint('DeepLinkService: Fragment: $fragment');

      // Parse fragment as query parameters
      final fragmentParams = Uri.splitQueryString(fragment);
      
      final accessToken = fragmentParams['access_token'];
      final refreshToken = fragmentParams['refresh_token'];
      final type = fragmentParams['type'] ?? 'recovery';

      debugPrint('DeepLinkService: Password reset link - access_token: ${accessToken != null ? 'present' : 'missing'}, type: $type');

      if (accessToken != null) {
        final context = AppRouter.navigatorKey.currentContext;
        if (context != null) {
          getIt<AuthCubit>().handlePasswordResetDeepLink(
            context: context,
            accessToken: accessToken,
            refreshToken: refreshToken ?? '',
            type: type,
          );
        }
      } else {
        debugPrint('DeepLinkService: No access token found in fragment');
      }
    }
  }

  /// Dispose and clean up listeners
  static void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }
}
