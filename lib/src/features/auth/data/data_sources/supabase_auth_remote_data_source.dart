import 'dart:developer';
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
      log('Attempting login for $email', name: 'SupabaseAuthRemoteDataSource', level: 800);

      // Sign in with Supabase
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Login failed. No user returned.');
      }

      log('User logged in: ${user.id}', name: 'SupabaseAuthRemoteDataSource', level: 1000);

      // Fetch user profile from users table
      final userProfile = await _supabaseClient
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (userProfile == null) {
        log('Creating new user profile', name: 'SupabaseAuthRemoteDataSource', level: 800);
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
      log('Login error: $e', name: 'SupabaseAuthRemoteDataSource', level: 900, error: e, stackTrace: stackTrace);
      rethrow; // Let NetworkExceptions handle error translation
    }
  }

  @override
  Future<bool> sendPasswordResetEmail({required String email}) async {
    try {
      log('Sending password reset to $email', name: 'SupabaseAuthRemoteDataSource', level: 800);

      // Use deep link URL for mobile app redirect
      const redirectUrl = 'parkmywhip://parkmywhip.com/reset-password';

      await _supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectUrl,
      );

      log('Password reset email sent with redirect: $redirectUrl', name: 'SupabaseAuthRemoteDataSource', level: 800);
      return true;
    } catch (e) {
      log('Password reset error: $e', name: 'SupabaseAuthRemoteDataSource', level: 900, error: e);
      rethrow; // Let NetworkExceptions handle error translation
    }
  }

  @override
  Future<bool> updatePassword({required String newPassword}) async {
    try {
      log('Updating password', name: 'SupabaseAuthRemoteDataSource', level: 800);

      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      log('Password updated successfully', name: 'SupabaseAuthRemoteDataSource', level: 1000);
      return true;
    } catch (e) {
      log('Update password error: $e', name: 'SupabaseAuthRemoteDataSource', level: 900, error: e);
      rethrow; // Let NetworkExceptions handle error translation
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      log('Signing out user', name: 'SupabaseAuthRemoteDataSource', level: 800);
      await _supabaseClient.auth.signOut();
      log('User signed out successfully', name: 'SupabaseAuthRemoteDataSource', level: 1000);
      return true;
    } catch (e) {
      log('Sign out error: $e', name: 'SupabaseAuthRemoteDataSource', level: 900, error: e);
      rethrow; // Let NetworkExceptions handle error translation
    }
  }

  @override
  Future<bool> sendSignUpOtp({required String email}) async {
    try {
      log('Sending OTP to $email', name: 'SupabaseAuthRemoteDataSource', level: 800);

      // Send OTP to email using Supabase magic link/OTP
      await _supabaseClient.auth.signInWithOtp(email: email);

      log('OTP sent successfully to $email', name: 'SupabaseAuthRemoteDataSource', level: 800);
      return true;
    } catch (e) {
      log('Send OTP error: $e', name: 'SupabaseAuthRemoteDataSource', level: 900, error: e);
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
      log('Completing signup for $email', name: 'SupabaseAuthRemoteDataSource', level: 800);

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

      log('OTP verified. Updating password...', name: 'SupabaseAuthRemoteDataSource', level: 800);

      // Update user password after OTP verification
      await _supabaseClient.auth.updateUser(
        UserAttributes(
          password: password,
          data: {'full_name': fullName},
        ),
      );

      log('Password updated successfully', name: 'SupabaseAuthRemoteDataSource', level: 1000);

      // Check if user profile exists in users table
      final userProfile = await _supabaseClient
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (userProfile == null) {
        log('Creating user profile in database', name: 'SupabaseAuthRemoteDataSource', level: 800);
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
      log('Complete signup error: $e', name: 'SupabaseAuthRemoteDataSource', level: 900, error: e);
      rethrow; // Let NetworkExceptions handle error translation
    }
  }
}
