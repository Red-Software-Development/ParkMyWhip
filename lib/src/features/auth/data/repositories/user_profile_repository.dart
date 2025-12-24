import 'package:park_my_whip/src/core/config/config.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/helpers/app_logger.dart';
import 'package:park_my_whip/src/core/models/supabase_user_model.dart';
import 'package:park_my_whip/src/core/models/user_app_model.dart';
import 'package:park_my_whip/supabase/supabase_config.dart';

/// Repository for managing user profiles in the `users` table
/// 
/// Handles all CRUD operations for user profiles and provides RPC functions
/// for complex operations that bypass RLS (Row Level Security).
/// 
/// Standard CRUD uses SupabaseService wrapper.
/// RPC functions use direct SupabaseConfig.client.rpc() calls.
class UserProfileRepository {
  const UserProfileRepository();

  // ========== Standard CRUD Operations ==========

  /// Gets a user's profile from the users table
  /// 
  /// Returns the user profile with optional userApp data.
  /// Returns null if profile not found or on error.
  Future<SupabaseUserModel?> getUserProfile(
    String userId, {
    UserAppModel? userApp,
  }) async {
    try {
      AppLogger.database('Getting user profile for user: $userId');

      final data = await SupabaseService.selectSingle(
        DbStrings.usersTable,
        filters: {DbStrings.id: userId},
      );

      if (data == null) {
        AppLogger.database('User profile not found');
        return null;
      }

      final user = SupabaseUserModel.fromJson(data, userApp: userApp);
      AppLogger.database('User profile retrieved: ${user.id}');
      return user;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get user profile: $e',
        name: 'UserProfileRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Gets raw user profile data (Map) without converting to model
  /// 
  /// Useful when you need the raw data for manipulation.
  /// Returns null if profile not found or on error.
  Future<Map<String, dynamic>?> getUserProfileData(String userId) async {
    try {
      AppLogger.database('Getting raw user profile data for user: $userId');

      final data = await SupabaseService.selectSingle(
        DbStrings.usersTable,
        filters: {DbStrings.id: userId},
      );

      if (data == null) {
        AppLogger.database('User profile data not found');
        return null;
      }

      AppLogger.database('User profile data retrieved');
      return data;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get user profile data: $e',
        name: 'UserProfileRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Creates a new user profile in the users table
  /// 
  /// Throws on failure (caller should handle via NetworkExceptions).
  Future<void> createUserProfile({
    required String userId,
    required String email,
    String? fullName,
  }) async {
    try {
      AppLogger.database('Creating user profile for user: $userId');

      await SupabaseService.insert(
        DbStrings.usersTable,
        {
          DbStrings.id: userId,
          DbStrings.email: email,
          DbStrings.fullName: fullName ?? email.split('@')[0],
          DbStrings.role: AppConfig.defaultRole,
          DbStrings.isActive: true,
          DbStrings.metadata: {},
        },
      );

      AppLogger.database('User profile created successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to create user profile: $e',
        name: 'UserProfileRepository',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Updates a user's email in the users table
  /// 
  /// Throws on failure (caller should handle via NetworkExceptions).
  Future<void> updateUserEmail(String userId, String email) async {
    try {
      AppLogger.database('Updating email for user: $userId');

      await SupabaseService.update(
        DbStrings.usersTable,
        {
          DbStrings.email: email,
          DbStrings.updatedAt: DateTime.now().toIso8601String(),
        },
        filters: {DbStrings.id: userId},
      );

      AppLogger.database('User email updated successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to update user email: $e',
        name: 'UserProfileRepository',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Deletes a user profile from the users table
  /// 
  /// Should only be called if user has no other app registrations.
  /// Throws on failure (caller should handle via NetworkExceptions).
  Future<void> deleteUserProfile(String userId) async {
    try {
      AppLogger.database('Deleting user profile for user: $userId');

      await SupabaseService.delete(
        DbStrings.usersTable,
        filters: {DbStrings.id: userId},
      );

      AppLogger.database('User profile deleted successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete user profile: $e',
        name: 'UserProfileRepository',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Checks if a user profile exists
  /// 
  /// Returns true if profile exists, false otherwise.
  Future<bool> userProfileExists(String userId) async {
    try {
      final data = await getUserProfileData(userId);
      return data != null;
    } catch (e) {
      AppLogger.warning(
        'Failed to check user profile existence: $e',
        name: 'UserProfileRepository',
      );
      return false;
    }
  }

  // ========== RPC Functions (Bypass RLS) ==========

  /// RPC: Gets user by email (bypasses RLS)
  /// 
  /// Used for password reset validation.
  /// Returns user data map or null if not found.
  /// Throws on error (caller should handle via NetworkExceptions).
  Future<Map<String, dynamic>?> getUserProfileByEmail(String email) async {
    try {
      AppLogger.database('RPC: Getting user by email: $email');

      final response = await SupabaseConfig.client.rpc(
        'get_user_by_email',
        params: {'user_email': email},
      );

      if (response == null) {
        AppLogger.database('RPC: No user found with email');
        return null;
      }

      AppLogger.database('RPC: User found by email');
      return response as Map<String, dynamic>?;
    } catch (e, stackTrace) {
      AppLogger.error(
        'RPC: Failed to get user by email: $e',
        name: 'UserProfileRepository',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// RPC: Checks user and app access (bypasses RLS)
  /// 
  /// Returns map with 'user' and 'user_app' keys:
  /// - null: User doesn't exist
  /// - {'user': {...}, 'user_app': null}: User exists, no app access
  /// - {'user': {...}, 'user_app': {...}}: User exists with app access
  /// 
  /// Throws on error (caller should handle via NetworkExceptions).
  Future<Map<String, dynamic>?> checkUserAppAccess({
    required String email,
    required String appId,
  }) async {
    try {
      AppLogger.database(
        'RPC: Checking user and app access for email: $email, app: $appId',
      );

      final response = await SupabaseConfig.client.rpc(
        DbStrings.getUserByEmailWithAppCheck,
        params: {
          'user_email': email,
          'p_app_id': appId,
        },
      );

      if (response == null) {
        AppLogger.database('RPC: No user found');
        return null;
      }

      final result = response as Map<String, dynamic>;
      final hasAppAccess = result['user_app'] != null;
      
      AppLogger.database(
        'RPC: User found, has app access: $hasAppAccess',
      );

      return result;
    } catch (e, stackTrace) {
      AppLogger.error(
        'RPC: Failed to check user app access: $e',
        name: 'UserProfileRepository',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// RPC: Creates user profile AND user_app record atomically (bypasses RLS)
  /// 
  /// Creates both records in a single transaction.
  /// Returns map with 'user' and 'user_app' keys.
  /// Throws on error (caller should handle via NetworkExceptions).
  Future<Map<String, dynamic>> createUserProfileWithApp({
    required String userId,
    required String email,
    required String appId,
  }) async {
    try {
      AppLogger.database(
        'RPC: Creating user profile with app for user: $userId, app: $appId',
      );

      final response = await SupabaseConfig.client.rpc(
        'create_user_profile',
        params: {
          'p_user_id': userId,
          'p_email': email,
          'p_app_id': appId,
        },
      );

      if (response == null) {
        throw Exception('RPC: create_user_profile returned null');
      }

      final result = response as Map<String, dynamic>;
      AppLogger.database('RPC: User profile and app created successfully');
      return result;
    } catch (e, stackTrace) {
      AppLogger.error(
        'RPC: Failed to create user profile with app: $e',
        name: 'UserProfileRepository',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// RPC: Deletes current auth user (bypasses RLS)
  /// 
  /// Deletes user from auth.users table.
  /// Should ONLY be called when user has no other app registrations.
  /// Throws on error (caller should handle via NetworkExceptions).
  Future<void> deleteAuthUser() async {
    try {
      AppLogger.database('RPC: Deleting auth user');

      await SupabaseConfig.client.rpc('delete_user');

      AppLogger.database('RPC: Auth user deleted successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'RPC: Failed to delete auth user: $e',
        name: 'UserProfileRepository',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// RPC: Checks user existence and grants app access if user exists (bypasses RLS)
  /// 
  /// Returns map with 'user' and 'user_app' keys:
  /// - {'user': null, 'user_app': null}: User doesn't exist (new user)
  /// - {'user': {...}, 'user_app': {...}}: User exists, app access granted
  /// 
  /// If user exists but doesn't have app access, this RPC automatically
  /// creates the user_apps record and returns it.
  /// 
  /// Throws on error (caller should handle via NetworkExceptions).
  Future<Map<String, dynamic>> checkUserAndGrantAppAccess({
    required String email,
    required String appId,
  }) async {
    try {
      AppLogger.database(
        'RPC: Checking user and granting app access for email: $email, app: $appId',
      );

      final response = await SupabaseConfig.client.rpc(
        'check_user_and_grant_app_access',
        params: {
          'user_email': email,
          'p_app_id': appId,
        },
      );

      if (response == null) {
        throw Exception('RPC: check_user_and_grant_app_access returned null');
      }

      final result = response as Map<String, dynamic>;
      final isNewUser = result['user'] == null;
      
      AppLogger.database(
        'RPC: ${isNewUser ? 'New user' : 'Existing user with app access granted'}',
      );

      return result;
    } catch (e, stackTrace) {
      AppLogger.error(
        'RPC: Failed to check user and grant app access: $e',
        name: 'UserProfileRepository',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
