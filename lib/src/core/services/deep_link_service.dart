import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/routes/router.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/auth_cubit.dart';

/// Service to handle deep link navigation for password reset
/// Listens for deep links from iOS/Android and processes them
class DeepLinkService {
  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _linkSubscription;

  /// Initialize deep link listener for mobile platforms only
  static Future<void> initialize() async {
    await _handleInitialLink();
    _handleIncomingLinks();
  }

  /// Handle deep link when app is opened from a link (cold start)
  static Future<void> _handleInitialLink() async {
    try {
      final Uri? uri = await _appLinks.getInitialLink();
      if (uri != null) {
        _processDeepLink(uri);
      }
    } catch (e) {
      debugPrint('DeepLinkService: Error getting initial link: $e');
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

    if (uri.path.contains('resetPassword')) {
      // Support both 'token' (from email template) and 'access_token' (legacy)
      final token = uri.queryParameters['token'] ?? uri.queryParameters['access_token'];
      final refreshToken = uri.queryParameters['refresh_token'];
      final type = uri.queryParameters['type'] ?? 'recovery';

      debugPrint('DeepLinkService: Password reset link - token: ${token != null ? 'present' : 'missing'}, type: $type');

      if (token != null) {
        final context = AppRouter.navigatorKey.currentContext;
        if (context != null) {
          getIt<AuthCubit>().handlePasswordResetDeepLink(
            context: context,
            accessToken: token,
            refreshToken: refreshToken ?? '',
            type: type,
          );
        }
      }
    }
  }

  /// Dispose and clean up listeners
  static void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }
}
