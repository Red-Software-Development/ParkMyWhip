import 'package:park_my_whip/src/core/config/config.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/helpers/app_logger.dart';
import 'package:park_my_whip/src/core/models/email_check_result.dart';
import 'package:park_my_whip/src/core/models/signup_eligibility_result.dart';
import 'package:park_my_whip/src/core/models/supabase_user_model.dart';
import 'package:park_my_whip/src/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:park_my_whip/src/features/auth/data/repositories/user_app_repository.dart';
import 'package:park_my_whip/src/features/auth/data/repositories/user_profile_repository.dart';
import 'package:park_my_whip/src/features/auth/data/services/user_cache_service.dart';
import 'package:park_my_whip/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Concrete implementation of [AuthRemoteDataSource] using Supabase
/// 
/// Uses the new architecture with:
/// - UserCacheService for local caching
/// - UserProfileRepository for users table operations
/// - UserAppRepository for user_apps table operations
class SupabaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final UserCacheService _cacheService;
  final UserProfileRepository _profileRepo;
  final UserAppRepository _appRepo;

  SupabaseAuthRemoteDataSource({
    required UserCacheService userCacheService,
    required UserProfileRepository userProfileRepository,
    required UserAppRepository userAppRepository,
  })  : _cacheService = userCacheService,
        _profileRepo = userProfileRepository,
        _appRepo = userAppRepository;

  @override
  Future<EmailCheckResult> checkEmailForApp({
    required String email,
    required String appId,
  }) async {
    try {
      _logInfo('Checking email $email for app $appId');

      final response = await _profileRepo.checkUserAppAccess(
        email: email,
        appId: appId,
      );

      final result = EmailCheckResult.fromRpcResponse(response);

      _logSuccess('Email check result: ${result.status}');
      return result;
    } catch (e, stackTrace) {
      _logError('Email check failed', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<SignupEligibilityResult> checkSignupEligibility({
    required String email,
    required String appId,
  }) async {
    try {
      _logInfo('Checking signup eligibility for: $email');

      // Check if user exists and grant app access if needed
      final result = await _profileRepo.checkUserAndGrantAppAccess(
        email: email,
        appId: appId,
      );

      final eligibilityResult = SignupEligibilityResult.fromRpcResponse(result);

      _logSuccess(
        'Signup eligibility: canSignup=${eligibilityResult.canSignup}, '
        'hasAppAccess=${eligibilityResult.hasAppAccess}',
      );

      return eligibilityResult;
    } catch (e, stackTrace) {
      _logError('Signup eligibility check failed', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<SupabaseUserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _logInfo('Attempting login for $email');

      // Step 1: Check user app access with RPC
      final appAccessResult = await _profileRepo.checkUserAppAccess(
        email: email,
        appId: AppConfig.appId,
      );

      if (appAccessResult == null) {
        AppLogger.auth('User not found with email: $email');
        throw Exception(
          'No account found with this email address. Please sign up first.',
        );
      }

      final data = appAccessResult;
      final userData = data['user'] as Map<String, dynamic>?;
      final userAppData = data['user_app'] as Map<String, dynamic>?;

      // Check if user exists in users table
      if (userData == null) {
        AppLogger.auth('User profile not found for: $email');
        throw Exception(
          'No account found with this email address. Please sign up first.',
        );
      }

      // Check if user is registered for this specific app
      if (userAppData == null) {
        AppLogger.auth('User not registered for app: ${AppConfig.appId}');
        throw Exception(
          'Your account is not registered for this app. Try signing up.',
        );
      }

      // Check if user is active in the app
      final isActive = userAppData['is_active'] as bool? ?? false;
      if (!isActive) {
        AppLogger.auth('User is deactivated for app: ${AppConfig.appId}');
        throw Exception(
          'Your account has been deactivated. Please contact support.',
        );
      }

      // Step 2: Authenticate with Supabase
      final response = await SupabaseConfig.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        AppLogger.auth('Sign in failed: No user returned');
        throw Exception('Login failed. Please try again.');
      }

      _logSuccess('Sign in successful for: $email');

      final userId = response.user!.id;

      // Step 3: Fetch user profile and app registration
      final user = await _profileRepo.getUserProfile(userId);
      final userApp = await _appRepo.getUserAppRegistration(
        userId,
        AppConfig.appId,
      );

      // These should exist since we validated them above
      if (user == null || userApp == null) {
        AppLogger.auth('Failed to fetch user data after authentication');
        throw Exception('Failed to load user profile. Please try again.');
      }

      // Update user with app registration and cache
      final userWithApp = user.copyWith(userApp: userApp);
      await _cacheService.cacheUser(userWithApp);

      return userWithApp;
    } catch (e, stackTrace) {
      _logError('Login failed', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> sendPasswordResetEmail({required String email}) async {
    try {
      _logInfo('Sending password reset to $email');

      await SupabaseConfig.auth.resetPasswordForEmail(
        email,
        redirectTo: AuthConstStrings.passwordResetDeepLink,
      );

      _logSuccess('Password reset email sent');
      return true;
    } catch (e, stackTrace) {
      _logError('Password reset failed', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> updatePassword({required String newPassword}) async {
    try {
      _logInfo('Updating password');

      await SupabaseConfig.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      _logSuccess('Password updated successfully');
      return true;
    } catch (e, stackTrace) {
      _logError('Update password failed', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      _logInfo('Signing out user');

      // 1. Sign out from Supabase Auth
      await SupabaseConfig.auth.signOut();
      _logSuccess('Signed out from Supabase Auth');

      // 2. Clear local cache
      await _cacheService.clearCache();
      _logSuccess('Cleared local cache');

      return true;
    } catch (e, stackTrace) {
      _logError('Sign out failed', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> createAccount({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      _logInfo('Creating account for $email');

      // 1. Sign up with Supabase Auth
      final authResponse = await _signUpWithEmail(email, password, fullName);
      final user = _validateAuthResponse(authResponse);
      _logSuccess('Supabase Auth: Account created ${user.id}');

      // 2. Create user profile in users table
      await _profileRepo.createUserProfile(
        userId: user.id,
        email: email,
        fullName: fullName,
      );
      _logSuccess('User profile created in database');

      // 3. Create user_apps record
      await _appRepo.createUserAppRegistration(
        userId: user.id,
        appId: AppConfig.appId,
        role: AppConfig.defaultRole,
      );
      _logSuccess('User app registration created');

      return true;
    } catch (e, stackTrace) {
      _logError('Create account failed', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> sendOtpForEmailVerification({required String email}) async {
    try {
      _logInfo('Sending OTP to $email');

      await SupabaseConfig.auth.signInWithOtp(email: email);

      _logSuccess('OTP sent to $email');
      return true;
    } catch (e, stackTrace) {
      _logError('Send OTP failed', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<SupabaseUserModel> verifyOtpAndCompleteSignup({
    required String email,
    required String otp,
  }) async {
    try {
      _logInfo('Verifying OTP for $email');

      // 1. Verify OTP with Supabase Auth
      final verifyResponse = await _verifyOtp(email, otp);
      final user = _validateAuthResponse(verifyResponse);
      _logSuccess('Email verified successfully');

      // 2. Get user profile (should already exist from createAccount)
      final userApp = await _appRepo.getUserAppRegistration(user.id, AppConfig.appId);
      final userProfile = await _profileRepo.getUserProfile(user.id, userApp: userApp);
      
      if (userProfile == null) {
        throw _AuthException('User profile not found after OTP verification');
      }
      
      _logSuccess('User profile loaded: ${userProfile.id}');

      // 3. Cache user locally
      await _cacheService.cacheUser(userProfile);
      _logSuccess('User cached locally');

      return userProfile;
    } catch (e, stackTrace) {
      _logError('OTP verification failed', e, stackTrace);
      rethrow;
    }
  }

  // ========== Private Helper Methods ==========

  /// Builds a SupabaseUserModel from auth User when profile fetch fails
  SupabaseUserModel _buildUserModel(User user, String email) {
    return SupabaseUserModel(
      id: user.id,
      email: user.email ?? email,
      fullName: user.userMetadata?[DbStrings.fullName] ?? AuthConstStrings.defaultUserName,
      emailVerified: user.emailConfirmedAt != null,
      avatarUrl: null,
      phoneNumber: user.phone,
      metadata: user.userMetadata ?? {},
      createdAt: DateTime.parse(user.createdAt),
      updatedAt: DateTime.parse(user.updatedAt ?? user.createdAt),
    );
  }

  // ========== Private Auth Methods ==========

  Future<AuthResponse> _signInWithPassword(String email, String password) =>
      SupabaseConfig.auth.signInWithPassword(email: email, password: password);

  Future<AuthResponse> _signUpWithEmail(String email, String password, String fullName) =>
      SupabaseConfig.auth.signUp(
        email: email,
        password: password,
        data: {DbStrings.fullName: fullName},
        emailRedirectTo: null,
      );

  Future<AuthResponse> _verifyOtp(String email, String otp) =>
      SupabaseConfig.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );

  User _validateAuthResponse(AuthResponse response) {
    if (response.user == null) {
      throw _AuthException(ErrorStrings.authFailed);
    }
    return response.user!;
  }

  // ========== Logging Helpers ==========

  void _logInfo(String message) => AppLogger.auth(message);

  void _logSuccess(String message) => AppLogger.auth(message);

  void _logError(String message, Object error, [StackTrace? stackTrace]) {
    final errorDetails = StringBuffer(message);
    if (error is AuthException) {
      errorDetails.write(' | Status: ${error.statusCode}, Message: ${error.message}');
    }
    if (error is PostgrestException) {
      errorDetails.write(' | DB Code: ${error.code}, Message: ${error.message}');
    }
    AppLogger.error(errorDetails.toString(), name: 'Auth', error: error, stackTrace: stackTrace);
  }
}

/// Custom auth exception
class _AuthException implements Exception {
  final String message;
  _AuthException(this.message);

  @override
  String toString() => message;
}
