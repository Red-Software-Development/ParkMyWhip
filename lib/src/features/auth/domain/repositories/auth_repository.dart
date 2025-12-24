import 'package:park_my_whip/src/core/data/result.dart';
import 'package:park_my_whip/src/core/models/email_check_result.dart';
import 'package:park_my_whip/src/core/models/signup_eligibility_result.dart';
import 'package:park_my_whip/src/core/models/supabase_user_model.dart';

/// Repository interface for authentication operations
/// Defines the contract that any auth implementation must follow
abstract class AuthRepository {
  /// Check if email exists and has access to the specified app
  /// Returns [EmailCheckResult] with status and user info if exists
  Future<Result<EmailCheckResult>> checkEmailForApp({
    required String email,
    required String appId,
  });

  /// Check signup eligibility for an email
  /// Automatically grants app access if user exists in another app
  /// Returns [SignupEligibilityResult] indicating if user can signup or should login
  Future<Result<SignupEligibilityResult>> checkSignupEligibility({
    required String email,
    required String appId,
  });

  /// Sign in with email and password
  Future<Result<SupabaseUserModel>> login({
    required String email,
    required String password,
  });

  /// Create a new user account
  Future<Result<void>> createAccount({
    required String email,
    required String password,
    required String fullName,
  });

  /// Send OTP for email verification
  Future<Result<void>> sendOtpForEmailVerification({
    required String email,
  });

  /// Verify OTP and complete signup
  Future<Result<SupabaseUserModel>> verifyOtpAndCompleteSignup({
    required String email,
    required String otp,
  });

  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail({
    required String email,
  });

  /// Update user password
  Future<Result<void>> updatePassword({
    required String newPassword,
  });

  /// Sign out current user
  Future<Result<void>> signOut();

  /// Get cached user from local storage
  Future<Result<SupabaseUserModel?>> getCachedUser();

  /// Cache user to local storage
  Future<Result<void>> cacheUser(SupabaseUserModel user);

  /// Clear cached user from local storage
  Future<Result<void>> clearCachedUser();
}
