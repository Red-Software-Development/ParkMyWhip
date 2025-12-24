import 'package:park_my_whip/src/core/data/result.dart';
import 'package:park_my_whip/src/core/helpers/app_logger.dart';
import 'package:park_my_whip/src/core/models/email_check_result.dart';
import 'package:park_my_whip/src/core/models/signup_eligibility_result.dart';
import 'package:park_my_whip/src/core/models/supabase_user_model.dart';
import 'package:park_my_whip/src/core/networking/network_exceptions.dart';
import 'package:park_my_whip/src/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:park_my_whip/src/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:park_my_whip/src/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository
/// Coordinates between remote and local data sources
/// Handles business logic and error transformation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Result<EmailCheckResult>> checkEmailForApp({
    required String email,
    required String appId,
  }) async {
    try {
      final result = await _remoteDataSource.checkEmailForApp(
        email: email,
        appId: appId,
      );

      AppLogger.auth('Email check completed: ${result.status}');
      return Success(result);
    } catch (e, stackTrace) {
      AppLogger.error('Email check failed',
          name: 'AuthRepository', error: e, stackTrace: stackTrace);
      return Failure(_getErrorMessage(e), e as Exception?);
    }
  }

  @override
  Future<Result<SignupEligibilityResult>> checkSignupEligibility({
    required String email,
    required String appId,
  }) async {
    try {
      final result = await _remoteDataSource.checkSignupEligibility(
        email: email,
        appId: appId,
      );

      AppLogger.auth(
        'Signup eligibility check completed: canSignup=${result.canSignup}, '
        'hasAppAccess=${result.hasAppAccess}',
      );
      return Success(result);
    } catch (e, stackTrace) {
      AppLogger.error('Signup eligibility check failed',
          name: 'AuthRepository', error: e, stackTrace: stackTrace);
      return Failure(_getErrorMessage(e), e as Exception?);
    }
  }

  @override
  Future<Result<SupabaseUserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.loginWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Cache user locally
      await _localDataSource.cacheUser(user);
      
      AppLogger.success('User logged in and cached: ${user.id}', name: 'AuthRepository');
      return Success(user);
    } catch (e, stackTrace) {
      AppLogger.error('Login failed', name: 'AuthRepository', error: e, stackTrace: stackTrace);
      return Failure(_getErrorMessage(e), e as Exception?);
    }
  }

  @override
  Future<Result<void>> createAccount({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      await _remoteDataSource.createAccount(
        email: email,
        password: password,
        fullName: fullName,
      );
      
      AppLogger.success('Account created successfully', name: 'AuthRepository');
      return const Success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Create account failed', 
          name: 'AuthRepository', error: e, stackTrace: stackTrace);
      return Failure(_getErrorMessage(e), e as Exception?);
    }
  }

  @override
  Future<Result<void>> sendOtpForEmailVerification({
    required String email,
  }) async {
    try {
      await _remoteDataSource.sendOtpForEmailVerification(email: email);
      
      AppLogger.success('OTP sent successfully', name: 'AuthRepository');
      return const Success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Send OTP failed', 
          name: 'AuthRepository', error: e, stackTrace: stackTrace);
      return Failure(_getErrorMessage(e), e as Exception?);
    }
  }

  @override
  Future<Result<SupabaseUserModel>> verifyOtpAndCompleteSignup({
    required String email,
    required String otp,
  }) async {
    try {
      final user = await _remoteDataSource.verifyOtpAndCompleteSignup(
        email: email,
        otp: otp,
      );
      
      // Cache user locally
      await _localDataSource.cacheUser(user);
      
      AppLogger.success('OTP verified and user cached: ${user.id}', 
          name: 'AuthRepository');
      return Success(user);
    } catch (e, stackTrace) {
      AppLogger.error('OTP verification failed', 
          name: 'AuthRepository', error: e, stackTrace: stackTrace);
      return Failure(_getErrorMessage(e), e as Exception?);
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _remoteDataSource.sendPasswordResetEmail(email: email);
      
      AppLogger.success('Password reset email sent', name: 'AuthRepository');
      return const Success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Send password reset email failed', 
          name: 'AuthRepository', error: e, stackTrace: stackTrace);
      return Failure(_getErrorMessage(e), e as Exception?);
    }
  }

  @override
  Future<Result<void>> updatePassword({
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.updatePassword(newPassword: newPassword);
      
      AppLogger.success('Password updated successfully', name: 'AuthRepository');
      return const Success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Update password failed', 
          name: 'AuthRepository', error: e, stackTrace: stackTrace);
      return Failure(_getErrorMessage(e), e as Exception?);
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      await _localDataSource.clearUser();
      
      AppLogger.success('User signed out and cache cleared', name: 'AuthRepository');
      return const Success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Sign out failed', 
          name: 'AuthRepository', error: e, stackTrace: stackTrace);
      return Failure(_getErrorMessage(e), e as Exception?);
    }
  }

  @override
  Future<Result<SupabaseUserModel?>> getCachedUser() async {
    try {
      final user = await _localDataSource.getCachedUser();
      return Success(user);
    } catch (e, stackTrace) {
      AppLogger.error('Get cached user failed', 
          name: 'AuthRepository', error: e, stackTrace: stackTrace);
      return Failure(_getErrorMessage(e), e as Exception?);
    }
  }

  @override
  Future<Result<void>> cacheUser(SupabaseUserModel user) async {
    try {
      await _localDataSource.cacheUser(user);
      return const Success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Cache user failed', 
          name: 'AuthRepository', error: e, stackTrace: stackTrace);
      return Failure(_getErrorMessage(e), e as Exception?);
    }
  }

  @override
  Future<Result<void>> clearCachedUser() async {
    try {
      await _localDataSource.clearUser();
      return const Success(null);
    } catch (e, stackTrace) {
      AppLogger.error('Clear cached user failed', 
          name: 'AuthRepository', error: e, stackTrace: stackTrace);
      return Failure(_getErrorMessage(e), e as Exception?);
    }
  }

  /// Extract error message from exception using NetworkExceptions
  String _getErrorMessage(dynamic error) =>
      NetworkExceptions.getSupabaseExceptionMessage(error);
}
