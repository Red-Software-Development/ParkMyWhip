import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/routes/router.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:uni_links/uni_links.dart';

/// Service to handle deep link navigation for password reset
/// Listens for deep links from iOS/Android and processes them
class DeepLinkService {
  static StreamSubscription? _linkSubscription;

  /// Initialize deep link listener for mobile platforms only
  static void initialize() {
    _handleInitialLink();
    _handleIncomingLinks();
  }

  /// Handle deep link when app is opened from a link
  static void _handleInitialLink() {
    getInitialUri().then((Uri? uri) {
      if (uri != null) {
        _processDeepLink(uri);
      }
    }).catchError((e) {
      debugPrint('DeepLinkService: Error getting initial link: $e');
    });
  }

  /// Handle deep links while app is running
  static void _handleIncomingLinks() {
    _linkSubscription = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _processDeepLink(uri);
      }
    }, onError: (e) {
      debugPrint('DeepLinkService: Error listening to links: $e');
    });
  }

  /// Process deep link URI and navigate to appropriate page
  static void _processDeepLink(Uri uri) {
    debugPrint('DeepLinkService: Deep link received: $uri');

    if (uri.path.contains('resetPassword')) {
      final token = uri.queryParameters['token'];
      final type = uri.queryParameters['type'] ?? 'recovery';

      debugPrint('DeepLinkService: Password reset link - token: $token, type: $type');

      if (token != null) {
        final context = AppRouter.navigatorKey.currentContext;
        if (context != null) {
          getIt<AuthCubit>().handlePasswordResetDeepLink(
            context: context,
            token: token,
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
