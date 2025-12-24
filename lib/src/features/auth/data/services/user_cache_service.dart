import 'dart:convert';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/helpers/app_logger.dart';
import 'package:park_my_whip/src/core/helpers/shared_pref_helper.dart';
import 'package:park_my_whip/src/core/models/supabase_user_model.dart';

/// Service for caching user data locally using SharedPreferences
/// 
/// This service handles all local user data persistence operations.
/// Cache failures do NOT break the auth flow - they only log warnings.
class UserCacheService {
  final SharedPrefHelper _sharedPrefHelper;

  const UserCacheService({
    required SharedPrefHelper sharedPrefHelper,
  }) : _sharedPrefHelper = sharedPrefHelper;

  /// Caches the complete user profile and user ID
  /// 
  /// Stores both the full user object and user ID separately for quick access.
  /// Does NOT throw errors - logs warnings on failure.
  Future<void> cacheUser(SupabaseUserModel user) async {
    try {
      // Cache full user profile
      final userJson = jsonEncode(user.toJson());
      await _sharedPrefHelper.setData(
        key: SharedPrefStrings.supabaseUserProfile,
        value: userJson,
      );

      // Cache user ID separately for quick access
      await _sharedPrefHelper.setData(
        key: SharedPrefStrings.userId,
        value: user.id,
      );

      AppLogger.debug(
        'User cached successfully: ${user.id}',
        name: 'UserCacheService',
      );
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Failed to cache user: $e',
        name: 'UserCacheService',
      );
      AppLogger.error(
        'Cache error details',
        name: 'UserCacheService',
        error: e,
        stackTrace: stackTrace,
      );
      // Do NOT rethrow - cache failures should not break auth flow
    }
  }

  /// Retrieves the cached user profile
  /// 
  /// Returns null if no cached user exists or if parsing fails.
  /// Does NOT throw errors - logs warnings on failure.
  Future<SupabaseUserModel?> getCachedUser() async {
    try {
      final userJson = await _sharedPrefHelper.getString(
        key: SharedPrefStrings.supabaseUserProfile,
      );

      if (userJson == null || userJson.isEmpty) {
        AppLogger.debug('No cached user found', name: 'UserCacheService');
        return null;
      }

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      final user = SupabaseUserModel.fromJson(userMap);

      AppLogger.debug(
        'Retrieved cached user: ${user.id}',
        name: 'UserCacheService',
      );

      return user;
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Failed to retrieve cached user: $e',
        name: 'UserCacheService',
      );
      AppLogger.error(
        'Cache retrieval error details',
        name: 'UserCacheService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Retrieves only the cached user ID (faster than getting full profile)
  /// 
  /// Returns null if no cached user ID exists.
  /// Does NOT throw errors - logs warnings on failure.
  Future<String?> getCachedUserId() async {
    try {
      final userId = await _sharedPrefHelper.getString(
        key: SharedPrefStrings.userId,
      );

      if (userId == null || userId.isEmpty) {
        AppLogger.debug('No cached user ID found', name: 'UserCacheService');
        return null;
      }

      AppLogger.debug('Retrieved cached user ID: $userId', name: 'UserCacheService');
      return userId;
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Failed to retrieve cached user ID: $e',
        name: 'UserCacheService',
      );
      AppLogger.error(
        'Cache retrieval error details',
        name: 'UserCacheService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Clears all cached user data
  /// 
  /// Removes both user profile and user ID from cache.
  /// Does NOT throw errors - logs warnings on failure.
  Future<void> clearCache() async {
    try {
      await _sharedPrefHelper.removeData(SharedPrefStrings.supabaseUserProfile);
      await _sharedPrefHelper.removeData(SharedPrefStrings.userId);

      AppLogger.debug('User cache cleared successfully', name: 'UserCacheService');
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Failed to clear user cache: $e',
        name: 'UserCacheService',
      );
      AppLogger.error(
        'Cache clear error details',
        name: 'UserCacheService',
        error: e,
        stackTrace: stackTrace,
      );
      // Do NOT rethrow - cache failures should not break auth flow
    }
  }

  /// Checks if user data exists in cache
  /// 
  /// Returns true if cached user profile exists, false otherwise.
  Future<bool> hasCache() async {
    try {
      final userJson = await _sharedPrefHelper.getString(
        key: SharedPrefStrings.supabaseUserProfile,
      );
      return userJson != null && userJson.isNotEmpty;
    } catch (e) {
      AppLogger.warning(
        'Failed to check cache existence: $e',
        name: 'UserCacheService',
      );
      return false;
    }
  }
}
