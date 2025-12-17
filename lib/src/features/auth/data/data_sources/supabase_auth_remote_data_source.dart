import 'package:flutter/foundation.dart';
import 'package:park_my_whip/src/core/models/supabase_user_model.dart';
import 'package:park_my_whip/src/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:park_my_whip/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Concrete implementation of [AuthRemoteDataSource] using Supabase
/// Handles all Supabase auth operations and user profile management
class SupabaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;

  SupabaseAuthRemoteDataSource({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<SupabaseUserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('SupabaseAuthRemoteDataSource: Attempting login for $email');

      // Sign in with Supabase
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Login failed. No user returned.');
      }

      debugPrint('SupabaseAuthRemoteDataSource: User logged in: ${user.id}');

      // Fetch user profile from users table
      final userProfile = await _supabaseClient
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (userProfile == null) {
        debugPrint('SupabaseAuthRemoteDataSource: Creating new user profile');
        // Create user profile if it doesn't exist
        await _supabaseClient.from('users').insert({
          'id': user.id,
          'email': user.email ?? email,
          'full_name': user.userMetadata?['full_name'] ?? 'User',
          'phone': user.phone,
          'role': 'user',
          'is_active': true,
          'metadata': {},
        });

        // Fetch the newly created profile
        final newProfile = await _supabaseClient
            .from('users')
            .select()
            .eq('id', user.id)
            .single();

        return SupabaseUserModel(
          id: user.id,
          email: user.email ?? email,
          fullName: newProfile['full_name'] ?? 'User',
          emailVerified: user.emailConfirmedAt != null,
          avatarUrl: newProfile['avatar_url'],
          phoneNumber: newProfile['phone'],
          metadata: Map<String, dynamic>.from(newProfile['metadata'] ?? {}),
          createdAt: DateTime.parse(newProfile['created_at']),
          updatedAt: DateTime.parse(newProfile['updated_at']),
        );
      }

      // Return existing user profile
      return SupabaseUserModel(
        id: user.id,
        email: user.email ?? email,
        fullName: userProfile['full_name'] ?? 'User',
        emailVerified: user.emailConfirmedAt != null,
        avatarUrl: userProfile['avatar_url'],
        phoneNumber: userProfile['phone'],
        metadata: Map<String, dynamic>.from(userProfile['metadata'] ?? {}),
        createdAt: DateTime.parse(userProfile['created_at']),
        updatedAt: DateTime.parse(userProfile['updated_at']),
      );
    } catch (e, stackTrace) {
      debugPrint('SupabaseAuthRemoteDataSource: Login error: $e');
      debugPrint('SupabaseAuthRemoteDataSource: Stack trace: $stackTrace');
      rethrow; // Let NetworkExceptions handle error translation
    }
  }

  @override
  Future<bool> sendPasswordResetEmail({required String email}) async {
    try {
      debugPrint('SupabaseAuthRemoteDataSource: Sending password reset to $email');

      // Get Supabase project URL for edge function redirect
      final redirectUrl = '${SupabaseConfig.supabaseUrl}/functions/v1/password-reset-redirect';

      await _supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectUrl,
      );

      debugPrint('SupabaseAuthRemoteDataSource: Password reset email sent with redirect: $redirectUrl');
      return true;
    } catch (e) {
      debugPrint('SupabaseAuthRemoteDataSource: Password reset error: $e');
      rethrow; // Let NetworkExceptions handle error translation
    }
  }

  @override
  Future<bool> updatePassword({required String newPassword}) async {
    try {
      debugPrint('SupabaseAuthRemoteDataSource: Updating password');

      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      debugPrint('SupabaseAuthRemoteDataSource: Password updated successfully');
      return true;
    } catch (e) {
      debugPrint('SupabaseAuthRemoteDataSource: Update password error: $e');
      rethrow; // Let NetworkExceptions handle error translation
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      debugPrint('SupabaseAuthRemoteDataSource: Signing out user');
      await _supabaseClient.auth.signOut();
      debugPrint('SupabaseAuthRemoteDataSource: User signed out successfully');
      return true;
    } catch (e) {
      debugPrint('SupabaseAuthRemoteDataSource: Sign out error: $e');
      rethrow; // Let NetworkExceptions handle error translation
    }
  }

  @override
  Future<bool> sendSignUpOtp({required String email}) async {
    try {
      debugPrint('SupabaseAuthRemoteDataSource: Sending OTP to $email');

      // Send OTP to email using Supabase magic link/OTP
      await _supabaseClient.auth.signInWithOtp(email: email);

      debugPrint('SupabaseAuthRemoteDataSource: OTP sent successfully to $email');
      return true;
    } catch (e) {
      debugPrint('SupabaseAuthRemoteDataSource: Send OTP error: $e');
      rethrow; // Let NetworkExceptions handle error translation
    }
  }

  @override
  Future<SupabaseUserModel> completeSignup({
    required String email,
    required String password,
    required String fullName,
    required String otp,
  }) async {
    try {
      debugPrint('SupabaseAuthRemoteDataSource: Completing signup for $email');

      // First verify the OTP
      final verifyResponse = await _supabaseClient.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );

      final user = verifyResponse.user;
      if (user == null) {
        throw Exception('OTP verification failed.');
      }

      debugPrint('SupabaseAuthRemoteDataSource: OTP verified. Updating password...');

      // Update user password after OTP verification
      await _supabaseClient.auth.updateUser(
        UserAttributes(
          password: password,
          data: {'full_name': fullName},
        ),
      );

      debugPrint('SupabaseAuthRemoteDataSource: Password updated successfully');

      // Check if user profile exists in users table
      final userProfile = await _supabaseClient
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (userProfile == null) {
        debugPrint('SupabaseAuthRemoteDataSource: Creating user profile in database');
        // Create user profile
        await _supabaseClient.from('users').insert({
          'id': user.id,
          'email': user.email ?? email,
          'full_name': fullName,
          'phone': user.phone,
          'role': 'user',
          'is_active': true,
          'metadata': {},
        });

        // Fetch the newly created profile
        final newProfile = await _supabaseClient
            .from('users')
            .select()
            .eq('id', user.id)
            .single();

        return SupabaseUserModel(
          id: user.id,
          email: user.email ?? email,
          fullName: newProfile['full_name'] ?? fullName,
          emailVerified: user.emailConfirmedAt != null,
          avatarUrl: newProfile['avatar_url'],
          phoneNumber: newProfile['phone'],
          metadata: Map<String, dynamic>.from(newProfile['metadata'] ?? {}),
          createdAt: DateTime.parse(newProfile['created_at']),
          updatedAt: DateTime.parse(newProfile['updated_at']),
        );
      }

      // Return existing user profile
      return SupabaseUserModel(
        id: user.id,
        email: user.email ?? email,
        fullName: userProfile['full_name'] ?? fullName,
        emailVerified: user.emailConfirmedAt != null,
        avatarUrl: userProfile['avatar_url'],
        phoneNumber: userProfile['phone'],
        metadata: Map<String, dynamic>.from(userProfile['metadata'] ?? {}),
        createdAt: DateTime.parse(userProfile['created_at']),
        updatedAt: DateTime.parse(userProfile['updated_at']),
      );
    } catch (e) {
      debugPrint('SupabaseAuthRemoteDataSource: Complete signup error: $e');
      rethrow; // Let NetworkExceptions handle error translation
    }
  }
}
