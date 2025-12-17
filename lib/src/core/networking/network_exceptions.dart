import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:park_my_whip/src/core/routes/router.dart';
import 'package:park_my_whip/src/core/widgets/error_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized exception handler for Supabase operations
/// Translates technical errors into user-friendly messages
abstract class NetworkExceptions {
  /// Takes a Supabase exception and returns a user-friendly error message
  static String getSupabaseExceptionMessage(dynamic error) {
    debugPrint('NetworkExceptions: Processing error: $error');

    // Network connectivity issues
    if (error is SocketException) {
      return 'No internet connection. Please check your network settings.';
    }

    // Supabase Auth exceptions
    if (error is AuthException) {
      return _getAuthErrorMessage(error);
    }

    // Supabase Database (Postgrest) exceptions
    if (error is PostgrestException) {
      return _getPostgrestErrorMessage(error);
    }

    // Supabase Storage exceptions
    if (error is StorageException) {
      return _getStorageErrorMessage(error);
    }

    // Generic Exception with message
    if (error is Exception) {
      final errorString = error.toString();
      if (errorString.contains('Exception: ')) {
        return errorString.replaceFirst('Exception: ', '');
      }
      return errorString;
    }

    // Catch-all for unknown errors
    return 'An unexpected error occurred. Please try again.';
  }

  /// Maps Supabase AuthException to user-friendly messages
  static String _getAuthErrorMessage(AuthException error) {
    final message = error.message.toLowerCase();
    final statusCode = error.statusCode;

    debugPrint('NetworkExceptions: Auth error - Code: $statusCode, Message: ${error.message}');

    // Common auth error patterns
    if (message.contains('invalid login credentials') ||
        message.contains('invalid credentials')) {
      return 'Invalid email or password. Please try again.';
    }

    if (message.contains('email not confirmed') ||
        message.contains('email not verified')) {
      return 'Please verify your email address before logging in.';
    }

    if (message.contains('user not found') ||
        message.contains('user does not exist')) {
      return 'No account found with this email.';
    }

    if (message.contains('email already registered') ||
        message.contains('user already registered')) {
      return 'This email is already registered. Try logging in.';
    }

    if (message.contains('weak password') ||
        message.contains('password is too weak')) {
      return 'Password is too weak. Use at least 6 characters.';
    }

    if (message.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }

    if (message.contains('user is disabled') ||
        message.contains('account has been disabled')) {
      return 'This account has been disabled. Contact support.';
    }

    if (message.contains('too many requests') ||
        statusCode == '429') {
      return 'Too many attempts. Please try again later.';
    }

    if (message.contains('network') || message.contains('timeout')) {
      return 'Network error. Check your internet connection.';
    }

    if (message.contains('session not found') ||
        message.contains('refresh token not found')) {
      return 'Your session has expired. Please login again.';
    }

    if (message.contains('password mismatch')) {
      return 'Passwords do not match.';
    }

    // OTP related errors
    if (message.contains('invalid otp') ||
        message.contains('otp expired') ||
        message.contains('token has expired')) {
      return 'Invalid or expired OTP. Please request a new one.';
    }

    if (message.contains('otp not found')) {
      return 'OTP not found. Please request a new verification code.';
    }

    if (message.contains('email rate limit exceeded')) {
      return 'Too many emails sent. Please wait before requesting a new code.';
    }

    // Signup specific errors
    if (message.contains('user already exists')) {
      return 'An account with this email already exists. Try logging in.';
    }

    if (message.contains('signup disabled')) {
      return 'Signup is currently disabled. Please try again later.';
    }

    if (message.contains('email provider')) {
      return 'Email service is temporarily unavailable. Please try again.';
    }

    if (message.contains('captcha') || message.contains('verification failed')) {
      return 'Verification failed. Please try again.';
    }

    // Generic auth failure
    return 'Authentication failed. Please check your credentials and try again.';
  }

  /// Maps Supabase PostgrestException to user-friendly messages
  static String _getPostgrestErrorMessage(PostgrestException error) {
    final message = error.message?.toLowerCase() ?? '';
    final code = error.code;

    debugPrint('NetworkExceptions: Database error - Code: $code, Message: ${error.message}');

    if (code == '23505') {
      return 'This record already exists in the database.';
    }

    if (code == '23503') {
      return 'Cannot delete this record as it is referenced by other data.';
    }

    if (code == '42501' || message.contains('permission denied')) {
      return 'You don\'t have permission to access this resource.';
    }

    if (code == 'PGRST116' || message.contains('not found')) {
      return 'Requested data could not be found.';
    }

    if (message.contains('timeout') || message.contains('deadline exceeded')) {
      return 'Operation timed out. Please try again.';
    }

    if (message.contains('connection')) {
      return 'Database connection error. Please try again.';
    }

    if (message.contains('violates')) {
      return 'Data validation failed. Please check your input.';
    }

    return 'Database operation failed. Please try again.';
  }

  /// Maps Supabase StorageException to user-friendly messages
  static String _getStorageErrorMessage(StorageException error) {
    final message = error.message?.toLowerCase() ?? '';
    final statusCode = error.statusCode;

    debugPrint('NetworkExceptions: Storage error - Code: $statusCode, Message: ${error.message}');

    if (statusCode == '404' || message.contains('not found')) {
      return 'File not found in storage.';
    }

    if (statusCode == '401' || message.contains('unauthorized')) {
      return 'You\'re not authorized to perform this storage operation.';
    }

    if (message.contains('canceled')) {
      return 'Storage operation was canceled.';
    }

    if (message.contains('size') || message.contains('too large')) {
      return 'File is too large to upload.';
    }

    if (message.contains('quota') || message.contains('limit')) {
      return 'Storage quota exceeded.';
    }

    return 'Storage operation failed. Please try again.';
  }

  /// Shows an error dialog with the translated error message
  /// Use this when there's no UI space to display inline error messages
  /// 
  /// Example usage:
  /// ```dart
  /// try {
  ///   await someBackendOperation();
  /// } catch (e) {
  ///   NetworkExceptions.showErrorDialog(e);
  /// }
  /// ```
  static void showErrorDialog(
    dynamic error, {
    String? title,
    VoidCallback? onDismiss,
  }) {
    final context = AppRouter.navigatorKey.currentContext;
    if (context == null) {
      debugPrint('NetworkExceptions: Cannot show dialog - no context available');
      return;
    }

    final errorMessage = getSupabaseExceptionMessage(error);
    
    showDialog(
      context: context,
      builder: (_) => ErrorDialog(
        errorMessage: errorMessage,
        title: title ?? 'Error',
        onDismiss: onDismiss,
      ),
    );
  }
}
