import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/routes/names.dart';
import 'package:park_my_whip/src/core/routes/router.dart';
import 'package:park_my_whip/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service to handle Supabase auth state changes and password reset deep links
/// Uses Supabase's built-in deep link handling instead of manual app_links parsing
class DeepLinkService {
  static StreamSubscription<AuthState>? _authStateSubscription;

  /// Initialize Supabase auth state listener
  /// This replaces manual deep link handling - Supabase handles deep links automatically
  static void initialize() {
    log('Initializing DeepLinkService with Supabase auth state listener', name: 'DeepLinkService', level: 800);
    
    // Listen to Supabase auth state changes
    // When user clicks password reset link, Supabase automatically:
    // 1. Opens the app via deep link
    // 2. Exchanges the code for a session
    // 3. Triggers PASSWORD_RECOVERY event
    _authStateSubscription = SupabaseConfig.client.auth.onAuthStateChange.listen(
      (AuthState authState) {
        final event = authState.event;
        final session = authState.session;
        
        log('Auth state changed: $event, session: ${session != null ? "present" : "null"}', 
            name: 'DeepLinkService', level: 800);

        // Handle password recovery event
        if (event == AuthChangeEvent.passwordRecovery) {
          log('Password recovery event detected', name: 'DeepLinkService', level: 800);
          _handlePasswordRecovery();
        }
      },
      onError: (error) {
        log('Auth state change error: $error', name: 'DeepLinkService', level: 900, error: error);
        // If there's an error (like expired token), show error page
        _handlePasswordResetError(error.toString());
      },
    );
  }

  /// Handle successful password recovery
  static void _handlePasswordRecovery() {
    final context = AppRouter.navigatorKey.currentContext;
    if (context != null) {
      log('Navigating to reset password page', name: 'DeepLinkService', level: 800);
      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesName.resetPassword,
        (route) => false,
      );
    } else {
      log('No navigator context available', name: 'DeepLinkService', level: 900);
    }
  }

  /// Handle password reset errors (expired/invalid links)
  static void _handlePasswordResetError(String error) {
    final context = AppRouter.navigatorKey.currentContext;
    if (context != null) {
      log('Navigating to error page: $error', name: 'DeepLinkService', level: 900);
      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesName.resetLinkError,
        (route) => false,
        arguments: AuthStrings.linkExpiredMessage,
      );
    }
  }

  /// Dispose and clean up listeners
  static void dispose() {
    _authStateSubscription?.cancel();
    _authStateSubscription = null;
  }
}
