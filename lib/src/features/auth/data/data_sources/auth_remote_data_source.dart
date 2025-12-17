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

  /// Send OTP to email for signup verification
  /// Returns true on success (OTP sent)
  /// Throws exception on failure
  Future<bool> sendSignUpOtp({
    required String email,
  });

  /// Complete signup after OTP verification
  /// Creates account with email and password
  /// Returns [SupabaseUserModel] on success
  /// Throws exception on failure
  Future<SupabaseUserModel> completeSignup({
    required String email,
    required String password,
    required String fullName,
    required String otp,
  });
}
