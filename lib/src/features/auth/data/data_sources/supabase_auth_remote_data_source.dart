import 'dart:developer';
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
      
      // Add detailed error logging for debugging
      if (e is AuthException) {
        log('Auth error details - Status: ${e.statusCode}, Message: ${e.message}', 
            name: 'SupabaseAuthRemoteDataSource', level: 900);
      }
      
      rethrow; // Let NetworkExceptions handle error translation
    }
  }

  @override
  Future<bool> sendPasswordResetEmail({required String email}) async {
    try {
      log('Sending password reset to $email', name: 'SupabaseAuthRemoteDataSource', level: 800);

      // Deep link URL for mobile app password reset
      // Format: scheme://host/path (as per Supabase deep linking docs)
      await _supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: 'parkmywhip://reset-password',
      );

      log('Password reset email sent', name: 'SupabaseAuthRemoteDataSource', level: 800);
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
  Future<bool> createAccount({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      debugPrint('🔵 [SIGNUP] Creating account for $email');

      // Step 1: Create account in Supabase (without email confirmation)
      final signUpResponse = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
        emailRedirectTo: null, // Disable automatic email sending
      );

      debugPrint('🔵 [SIGNUP] SignUp response: user=${signUpResponse.user?.id}, session=${signUpResponse.session?.accessToken != null}');

      if (signUpResponse.user == null) {
        debugPrint('🔴 [SIGNUP ERROR] No user returned from Supabase');
        throw Exception('Account creation failed. No user returned from Supabase.');
      }

      debugPrint('✅ [SIGNUP] Account created successfully. User ID: ${signUpResponse.user!.id}');

      // Step 2: Create user profile in database
      try {
        debugPrint('🔵 [SIGNUP] Creating user profile in database...');
        await _supabaseClient.from('users').insert({
          'id': signUpResponse.user!.id,
          'email': email,
          'full_name': fullName,
          'role': 'user',
          'is_active': true,
          'metadata': {},
        });
        debugPrint('✅ [SIGNUP] User profile created in database');
      } catch (dbError) {
        debugPrint('🔴 [SIGNUP ERROR] Database insert error: $dbError');
        throw Exception('Failed to create user profile in database: $dbError');
      }

      return true;
    } catch (e) {
      debugPrint('🔴 [SIGNUP ERROR] Create account error: $e');
      
      // Add detailed error logging
      if (e is AuthException) {
        debugPrint('🔴 [SIGNUP ERROR] Auth error - Status: ${e.statusCode}, Message: ${e.message}');
      }
      if (e is PostgrestException) {
        debugPrint('🔴 [SIGNUP ERROR] Database error - Code: ${e.code}, Message: ${e.message}');
      }
      
      rethrow; // Let NetworkExceptions handle error translation
    }
  }

  @override
  Future<bool> sendOtpForEmailVerification({
    required String email,
  }) async {
    try {
      log('Sending OTP to $email for email verification', name: 'SupabaseAuthRemoteDataSource', level: 800);

      // Send OTP for email verification
      await _supabaseClient.auth.signInWithOtp(email: email);

      log('OTP sent to $email', name: 'SupabaseAuthRemoteDataSource', level: 800);
      return true;
    } catch (e) {
      log('Send OTP error: $e', name: 'SupabaseAuthRemoteDataSource', level: 900, error: e);
      rethrow; // Let NetworkExceptions handle error translation
    }
  }

  @override
  Future<SupabaseUserModel> verifyOtpAndCompleteSignup({
    required String email,
    required String otp,
  }) async {
    try {
      log('Verifying OTP for $email', name: 'SupabaseAuthRemoteDataSource', level: 800);

      // Verify OTP to confirm email
      final verifyResponse = await _supabaseClient.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );

      if (verifyResponse.user == null) {
        throw Exception('OTP verification failed.');
      }

      log('Email verified successfully', name: 'SupabaseAuthRemoteDataSource', level: 1000);

      // Fetch user profile from database
      final userProfile = await _supabaseClient
          .from('users')
          .select()
          .eq('id', verifyResponse.user!.id)
          .single();

      return SupabaseUserModel(
        id: verifyResponse.user!.id,
        email: verifyResponse.user!.email ?? email,
        fullName: userProfile['full_name'] ?? 'User',
        emailVerified: true,
        avatarUrl: userProfile['avatar_url'],
        phoneNumber: userProfile['phone'],
        metadata: Map<String, dynamic>.from(userProfile['metadata'] ?? {}),
        createdAt: DateTime.parse(userProfile['created_at']),
        updatedAt: DateTime.parse(userProfile['updated_at']),
      );
    } catch (e) {
      log('OTP verification error: $e', name: 'SupabaseAuthRemoteDataSource', level: 900, error: e);
      rethrow; // Let NetworkExceptions handle error translation
    }
  }
}
