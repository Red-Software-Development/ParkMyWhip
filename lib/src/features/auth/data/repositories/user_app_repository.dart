import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/helpers/app_logger.dart';
import 'package:park_my_whip/src/core/models/user_app_model.dart';
import 'package:park_my_whip/supabase/supabase_config.dart';

/// Repository for managing user-app registrations in the `user_apps` table
/// 
/// Handles multi-app access control - allows users to have access to multiple apps.
/// All operations use SupabaseService wrapper for consistency.
class UserAppRepository {
  const UserAppRepository();

  /// Gets a user's registration for a specific app
  /// 
  /// Returns the UserApp record if found, null otherwise.
  /// Does NOT throw errors - logs and returns null on failure.
  Future<UserAppModel?> getUserAppRegistration(
    String userId,
    String appId,
  ) async {
    try {
      AppLogger.database(
        'Getting user_app registration for user: $userId, app: $appId',
      );

      final data = await SupabaseService.selectSingle(
        DbStrings.userAppsTable,
        filters: {
          DbStrings.userId: userId,
          DbStrings.appId: appId,
        },
      );

      if (data == null) {
        AppLogger.database('No user_app registration found');
        return null;
      }

      final userApp = UserAppModel.fromJson(data);
      AppLogger.database('User_app registration found: ${userApp.id}');
      return userApp;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get user_app registration: $e',
        name: 'UserAppRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Deletes a user's registration for a specific app
  /// 
  /// Used when removing app access or during account deletion.
  /// Throws on failure (caller should handle via NetworkExceptions).
  Future<void> deleteUserAppRegistration(
    String userId,
    String appId,
  ) async {
    try {
      AppLogger.database(
        'Deleting user_app registration for user: $userId, app: $appId',
      );

      await SupabaseService.delete(
        DbStrings.userAppsTable,
        filters: {
          DbStrings.userId: userId,
          DbStrings.appId: appId,
        },
      );

      AppLogger.database('User_app registration deleted successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete user_app registration: $e',
        name: 'UserAppRepository',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Gets all app registrations for a user
  /// 
  /// Returns list of all apps the user has access to.
  /// Returns empty list on failure.
  Future<List<UserAppModel>> getUserAppRegistrations(String userId) async {
    try {
      AppLogger.database('Getting all user_app registrations for user: $userId');

      final dataList = await SupabaseService.select(
        DbStrings.userAppsTable,
        filters: {DbStrings.userId: userId},
        orderBy: DbStrings.createdAt,
        ascending: false,
      );

      final userApps = dataList
          .map((data) => UserAppModel.fromJson(data))
          .toList();

      AppLogger.database('Found ${userApps.length} user_app registrations');
      return userApps;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get user_app registrations: $e',
        name: 'UserAppRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Checks if user has registrations for other apps (excluding current app)
  /// 
  /// Used during account deletion to determine if we should delete the auth user.
  /// Returns true if user has other app registrations, false otherwise.
  Future<bool> hasOtherAppRegistrations(
    String userId,
    String currentAppId,
  ) async {
    try {
      AppLogger.database(
        'Checking for other app registrations for user: $userId (excluding $currentAppId)',
      );

      final allRegistrations = await getUserAppRegistrations(userId);
      
      // Filter out current app
      final otherRegistrations = allRegistrations
          .where((userApp) => userApp.appId != currentAppId)
          .toList();

      final hasOthers = otherRegistrations.isNotEmpty;
      
      AppLogger.database(
        'User has ${otherRegistrations.length} other app registrations: $hasOthers',
      );

      return hasOthers;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to check other app registrations: $e',
        name: 'UserAppRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Creates a new user_app registration
  /// 
  /// Used when granting app access to an existing user.
  /// Throws on failure (caller should handle via NetworkExceptions).
  Future<UserAppModel> createUserAppRegistration({
    required String userId,
    required String appId,
    required String role,
  }) async {
    try {
      AppLogger.database(
        'Creating user_app registration for user: $userId, app: $appId, role: $role',
      );

      final dataList = await SupabaseService.insert(
        DbStrings.userAppsTable,
        {
          DbStrings.userId: userId,
          DbStrings.appId: appId,
          DbStrings.role: role,
          DbStrings.isActive: true,
          DbStrings.metadata: {},
        },
      );

      if (dataList.isEmpty) {
        throw Exception('Failed to create user_app registration: No data returned');
      }

      final userApp = UserAppModel.fromJson(dataList.first);
      AppLogger.database('User_app registration created: ${userApp.id}');
      return userApp;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to create user_app registration: $e',
        name: 'UserAppRepository',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Updates a user_app registration's status or role
  /// 
  /// Throws on failure (caller should handle via NetworkExceptions).
  Future<UserAppModel> updateUserAppRegistration({
    required String userId,
    required String appId,
    bool? isActive,
    String? role,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      AppLogger.database(
        'Updating user_app registration for user: $userId, app: $appId',
      );

      final updateData = <String, dynamic>{
        DbStrings.updatedAt: DateTime.now().toIso8601String(),
      };

      if (isActive != null) updateData[DbStrings.isActive] = isActive;
      if (role != null) updateData[DbStrings.role] = role;
      if (metadata != null) updateData[DbStrings.metadata] = metadata;

      final dataList = await SupabaseService.update(
        DbStrings.userAppsTable,
        updateData,
        filters: {
          DbStrings.userId: userId,
          DbStrings.appId: appId,
        },
      );

      if (dataList.isEmpty) {
        throw Exception('Failed to update user_app registration: No data returned');
      }

      final userApp = UserAppModel.fromJson(dataList.first);
      AppLogger.database('User_app registration updated: ${userApp.id}');
      return userApp;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to update user_app registration: $e',
        name: 'UserAppRepository',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
