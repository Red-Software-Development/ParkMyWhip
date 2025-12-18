import 'package:park_my_whip/src/core/models/supabase_user_model.dart';

/// Abstract contract for authentication remote data source
/// All backend auth operations go through this interface
abstract class AuthRemoteDataSource {
  /// Login with email and password
  /// Returns [SupabaseUserModel] on success
  /// Throws exception on failure
  Future<SupabaseUserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Send password reset email to user
  /// Returns true on success
  /// Throws exception on failure
  Future<bool> sendPasswordResetEmail({
    required String email,
  });

  /// Update user password (used after password reset link)
  /// Returns true on success
  /// Throws exception on failure
  Future<bool> updatePassword({
    required String newPassword,
  });

  /// Sign out current user
  /// Returns true on success
  /// Throws exception on failure
  Future<bool> signOut();

  /// Create account in Supabase and insert user profile in database
  /// Step 1: Creates account with email and password
  /// Step 2: Creates user profile in database
  /// Returns true on success
  /// Throws exception on failure
  Future<bool> createAccount({
    required String email,
    required String password,
    required String fullName,
  });

  /// Send OTP for email verification
  /// Returns true on success
  /// Throws exception on failure
  Future<bool> sendOtpForEmailVerification({
    required String email,
  });

  /// Verify OTP and complete signup
  /// Verifies email with OTP code
  /// Returns [SupabaseUserModel] on success
  /// Throws exception on failure
  Future<SupabaseUserModel> verifyOtpAndCompleteSignup({
    required String email,
    required String otp,
  });
}
