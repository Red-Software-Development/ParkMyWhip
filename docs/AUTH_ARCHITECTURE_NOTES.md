# Auth Architecture Pattern - Documentation

## Overview
This document captures the architectural patterns and structure used in the uploaded files for the authentication feature. These patterns must be followed when fixing/refactoring the auth implementation.

---

## 🏗️ Architecture Pattern

### Three-Layer Repository Pattern

1. **UserCacheService** - Local caching layer
2. **UserProfileRepository** - Database operations for `users` table
3. **UserAppRepository** - Database operations for `user_apps` table

### Key Principle: Separation of Concerns
- Each repository/service has a single, well-defined responsibility
- No RPC functions are used in repository classes - they use `SupabaseService` wrapper
- All database operations go through `SupabaseService` (from `supabase_config.dart`)

---

## 📦 Core Components

### 1. UserCacheService (`user_cache_service.dart`)
**Purpose:** Manages local user data persistence using SharedPreferences

**Dependencies:**
```dart
- SharedPrefHelper (injected via constructor)
- User model (from user_model.dart - NOT found, needs to be created)
- AuthConstants (for cache keys - NOT found, needs to be created)
```

**Key Methods:**
- `cacheUser(User user)` - Saves user data and user ID to local cache
- `getCachedUser()` → `User?` - Retrieves cached user profile
- `getCachedUserId()` → `String?` - Retrieves cached user ID only
- `clearCache()` - Removes all cached user data
- `hasCache()` → `bool` - Checks if user data exists in cache

**Important Notes:**
- ✅ All methods handle errors gracefully (catch/log/don't rethrow)
- ✅ Cache failures should NOT break auth flow
- ✅ Uses `dart:developer` log for logging with `AuthConstants.loggerName`
- ✅ Stores both full user object AND user ID separately for quick access

**Cache Keys Used:**
- `AuthConstants.userProfileCacheKey` - For full user profile JSON
- `AuthConstants.userIdCacheKey` - For user ID string

---

### 2. UserProfileRepository (`user_profile_repository.dart`)
**Purpose:** Handles all CRUD operations for the `users` table

**Database Table:** `users`
**Dependencies:**
```dart
- SupabaseService (from supabase_config.dart)
- SupabaseConfig (for RPC calls only)
- User model
- UserApp model
- AuthConstants
```

**Standard CRUD Methods:**
These use `SupabaseService` wrapper (NO direct Supabase client):
- `getUserProfile(userId, {userApp})` → `User?`
- `getUserProfileData(userId)` → `Map<String, dynamic>?`
- `createUserProfile({userId, email, fullName})`
- `updateUserEmail(userId, email)`
- `deleteUserProfile(userId)`
- `userProfileExists(userId)` → `bool`

**RPC Methods:**
These bypass RLS and use direct `SupabaseConfig.client.rpc()`:

1. **`getUserProfileByEmail(email)`** → `Map<String, dynamic>?`
   - RPC: `get_user_by_email`
   - Params: `{'user_email': email}`
   - Use case: Password reset validation

2. **`checkUserAppAccess({email, appId})`** → `Map<String, dynamic>?`
   - RPC: `get_user_by_email_with_app_check`
   - Params: `{'user_email': email, 'p_app_id': appId}`
   - Returns:
     - `null` - User doesn't exist
     - `{'user': {...}, 'user_app': null}` - User exists but NOT registered for app
     - `{'user': {...}, 'user_app': {...}}` - User is registered for app ✅

3. **`createUserProfileWithApp({userId, email, appId})`** → `Map<String, dynamic>?`
   - RPC: `create_user_profile`
   - Params: `{'p_user_id': userId, 'p_email': email, 'p_app_id': appId}`
   - Creates both `users` and `user_apps` records atomically
   - Returns: `{'user': {...}, 'user_app': {...}}`

4. **`deleteAuthUser()`**
   - RPC: `delete_user`
   - Params: none (uses current auth user)
   - Deletes user from Supabase Auth
   - Should only be called when user has no other app registrations

5. **`checkUserAndGrantAppAccess({email, appId})`** → `Map<String, dynamic>?`
   - RPC: `check_user_and_grant_app_access`
   - Params: `{'user_email': email, 'p_app_id': appId}`
   - Returns:
     - `{'user': null, 'user_app': null}` - User doesn't exist (new user)
     - `{'user': {...}, 'user_app': {...}}` - User exists and was granted access

**Important Notes:**
- ✅ Standard CRUD uses `SupabaseService.select/insert/update/delete`
- ✅ RPC functions use direct `SupabaseConfig.client.rpc()`
- ✅ RPC errors are re-thrown (let caller handle via NetworkExceptions)
- ✅ All operations logged using `dart:developer` log
- ✅ When creating user profile, sets default values:
  - `full_name`: fallback to email prefix if not provided
  - `is_active`: true
  - `metadata`: {}
  - `created_at` and `updated_at`: current timestamp

---

### 3. UserAppRepository (`user_app_repository.dart`)
**Purpose:** Manages user-app registrations (multi-app access control)

**Database Table:** `user_apps`
**Dependencies:**
```dart
- SupabaseService (from supabase_config.dart)
- UserApp model
- AuthConstants
```

**Key Methods:**
- `getUserAppRegistration(userId, appId)` → `UserApp?`
- `deleteUserAppRegistration(userId, appId)`
- `getUserAppRegistrations(userId)` → `List<UserApp>`
- `hasOtherAppRegistrations(userId, currentAppId)` → `bool`

**Important Notes:**
- ✅ All operations use `SupabaseService` wrapper
- ✅ NO RPC functions - simple CRUD only
- ✅ Errors are caught and logged, returns null/empty list on failure
- ✅ Uses filters: `{'user_id': userId, 'app_id': appId}`

---

### 4. SupabaseAuthManager (`supabase_auth_manager.dart`)
**Purpose:** Main authentication manager that orchestrates all auth operations

**Inheritance:**
```dart
class SupabaseAuthManager extends AuthManager with EmailSignInManager
```

**Dependencies (Injected via Constructor):**
```dart
- SharedPrefHelper (required)
- UserProfileRepository (optional, defaults to const UserProfileRepository())
- UserAppRepository (optional, defaults to const UserAppRepository())
- UserCacheService (created internally from SharedPrefHelper)
```

**Constructor Pattern:**
```dart
SupabaseAuthManager({
  required SharedPrefHelper sharedPrefHelper,
  UserProfileRepository? userProfileRepository,
  UserAppRepository? userAppRepository,
})
```

---

## 🔐 Authentication Flows (CRITICAL - MUST FOLLOW)

### 1. SIGN IN FLOW (`signInWithEmail`)

**Step-by-Step Logic:**

```dart
async signInWithEmail(String email, String password) → User?
```

**Step 1: Pre-Authentication Validation**
- ✅ Call `UserProfileRepository.checkUserAppAccess(email, appId)` BEFORE auth
- ✅ Check if user exists in database (`userData != null`)
- ✅ Check if user is registered for this app (`userAppData != null`)
- ✅ Check if user is active (`userAppData['is_active'] == true`)
- ✅ Throw specific error messages for each failure case:
  - User doesn't exist: "No account found with this email address. Please sign up first."
  - Not registered for app: "Your account is not registered for this app. Try signing up."
  - Account deactivated: "Your account has been deactivated. Please contact support."

**Step 2: Authenticate with Supabase**
```dart
final response = await SupabaseConfig.auth.signInWithPassword(
  email: email,
  password: password,
);
```

**Step 3: Fetch User Data**
- Call `UserProfileRepository.getUserProfile(userId)`
- Call `UserAppRepository.getUserAppRegistration(userId, appId)`
- Verify both exist (should exist since we validated in Step 1)

**Step 4: Combine and Cache**
- Combine user with userApp: `user.copyWith(userApp: userApp)`
- Cache: `UserCacheService.cacheUser(userWithApp)`
- Return user

**Error Handling:**
- Catch `AuthException` → Convert via `NetworkExceptions.getSupabaseExceptionMessage()`
- Catch generic `Exception` → Rethrow
- Catch all others → Convert via `NetworkExceptions.getSupabaseExceptionMessage()`

---

### 2. SIGN UP FLOW (Multi-Step Process)

#### 2A. CHECK SIGNUP ELIGIBILITY (`checkSignupEligibility`)

```dart
async checkSignupEligibility(String email) → SignupEligibilityResult
```

**Logic:**
- Call `UserProfileRepository.checkUserAndGrantAppAccess(email, appId)`
- Returns `{'user': null, 'user_app': null}` → New user (proceed with signup)
- Returns `{'user': {...}, 'user_app': {...}}` → Existing user from another app (now has access)

**Return Values:**
```dart
SignupEligibilityResult(
  status: SignupEligibilityStatus.existingUser,  // or .newUser
  message: "Message here",
)
```

**Important:**
- If existing user: Auto-grant app access via RPC
- If new user: Continue with signup flow

---

#### 2B. CREATE ACCOUNT (`createAccountWithEmail`)

```dart
async createAccountWithEmail(String email, String password) → User?
```

**Logic:**
1. Call `SupabaseConfig.auth.signUp()` with:
   - email
   - password
   - data: `{'full_name': email.split('@')[0]}`
   - emailRedirectTo: `null` (manual email verification)

2. Return minimal User object via `_userFromAuthUser()`
   - Does NOT create profile/app records yet
   - Profile creation happens after OTP verification

**Important:**
- ✅ Do NOT create database records here
- ✅ Wait for OTP verification to create profile

---

#### 2C. VERIFY OTP (`verifyOtpWithEmail`)

```dart
async verifyOtpWithEmail({
  required String email,
  required String otpCode,
}) → User?
```

**Step-by-Step Logic:**

**Step 1: Verify OTP**
```dart
final response = await SupabaseConfig.auth.verifyOTP(
  email: email,
  token: otpCode,
  type: OtpType.signup,
);
```

**Step 2: Create Profile and App Registration**
- ✅ Call `UserProfileRepository.createUserProfileWithApp(userId, email, appId)`
- ✅ This RPC creates BOTH `users` and `user_apps` records atomically
- ✅ Returns: `{'user': {...}, 'user_app': {...}}`

**Step 3: Parse and Validate**
- Extract `userData` and `userAppData` from RPC response
- Create `UserApp` object: `UserApp.fromJson(userAppData)`
- Validate `userApp.isActive == true`
- If not active → Sign out and throw error

**Step 4: Create User Object and Cache**
- Create User: `User.fromJson(userData, userApp: userApp)`
- Cache: `UserCacheService.cacheUser(user)`
- Return user

**Error Handling:**
- Catch `AuthException` → Convert message
- Catch other errors → Rethrow if Exception, else convert

---

#### 2D. RESEND VERIFICATION EMAIL (`resendVerificationEmail`)

```dart
async resendVerificationEmail({required String email})
```

**Logic:**
- Calls internal `_sendVerificationEmail(email)`
- Uses `SupabaseConfig.auth.signInWithOtp()`
- Sets `emailRedirectTo` via `AuthConstants.verifyEmailRedirectUrl(deepLinkScheme)`

---

### 3. PASSWORD RESET FLOW

#### 3A. REQUEST PASSWORD RESET (`resetPassword`)

```dart
async resetPassword({required String email})
```

**Step-by-Step Validation Logic:**

**Step 1: Check User and App Access**
- Call `UserProfileRepository.checkUserAppAccess(email, appId)`
- Returns: `{'user': {...}, 'user_app': {...}}`

**Step 2: Validate User Exists**
- Check `userData != null`
- Error: "No account found with this email address. Please check your email or sign up."

**Step 3: Validate Email is Verified**
- Call internal `_isUserEmailVerified(userId)`
- Checks if `auth.currentUser.emailConfirmedAt != null`
- Error: "Your email is not verified. Please verify your email before resetting your password."

**Step 4: Validate App Registration**
- Check `userAppData != null`
- Error: "Your account is not registered for this app. Please contact support."

**Step 5: Validate Active Status**
- Check `userAppData['is_active'] == true`
- Error: "Your account has been deactivated. Please contact support."

**Step 6: Send Reset Email**
```dart
await SupabaseConfig.auth.resetPasswordForEmail(
  email,
  redirectTo: AuthConstants.resetPasswordRedirectUrl(deepLinkScheme),
);
```

**Error Handling:**
- Same pattern as sign in (AuthException → convert, else rethrow)

---

#### 3B. UPDATE PASSWORD (`updatePassword`)

```dart
async updatePassword({required String newPassword})
```

**Logic:**
```dart
await SupabaseConfig.auth.updateUser(
  UserAttributes(password: newPassword),
);
```

**Error Handling:**
- Catch `AuthException` → Convert message
- Catch other errors → Convert message

---

### 4. ACCOUNT MANAGEMENT FLOWS

#### 4A. SIGN OUT (`signOut`)

```dart
async signOut()
```

**Logic:**
1. `SupabaseConfig.auth.signOut()`
2. `UserCacheService.clearCache()`

**Error Handling:**
- Catch all → "Failed to sign out. Please try again."

---

#### 4B. DELETE USER (`deleteUser`)

```dart
async deleteUser()
```

**Step-by-Step Logic:**

**Step 1: Get Current User**
- Get `SupabaseConfig.auth.currentUser`
- Validate user is signed in

**Step 2: Delete App Registration**
- Call `UserAppRepository.deleteUserAppRegistration(userId, appId)`

**Step 3: Check Other App Registrations**
- Call `UserAppRepository.hasOtherAppRegistrations(userId, currentAppId)`

**Step 4: Conditional Deletion**
- If NO other apps:
  - Call `UserProfileRepository.deleteUserProfile(userId)`
  - Call `UserProfileRepository.deleteAuthUser()` (RPC to delete from auth.users)
- If HAS other apps:
  - Only delete app registration (keep user profile and auth)

**Step 5: Clear Cache**
- Call `UserCacheService.clearCache()`

**Important Multi-App Logic:**
- ✅ Only delete auth user if no other app registrations
- ✅ Preserve user data if they use other apps

---

#### 4C. UPDATE EMAIL (`updateEmail`)

```dart
async updateEmail({required String email})
```

**Logic:**
1. Update in Supabase Auth: `SupabaseConfig.auth.updateUser(UserAttributes(email: email))`
2. Update in database: `UserProfileRepository.updateUserEmail(userId, email)`

**Error Handling:**
- Catch `AuthException` → Convert message
- Catch other errors → Convert message

---

### 5. HELPER METHODS (Private)

#### `_sendVerificationEmail(String email)`
```dart
await SupabaseConfig.auth.signInWithOtp(
  email: email,
  emailRedirectTo: AuthConstants.verifyEmailRedirectUrl(deepLinkScheme),
);
```

#### `_isUserEmailVerified(String userId)` → `bool`
- Checks if `auth.currentUser.emailConfirmedAt != null`
- If user not currently signed in but exists in users table → assume verified
- Defaults to `true` on error (don't block existing users)

#### `_userFromAuthUser(authUser, {userApp})` → `User`
Creates minimal User object from auth user:
```dart
User(
  id: authUser.id,
  email: authUser.email ?? '',
  fullName: authUser.email?.split('@')[0] ?? 'User',
  phone: authUser.phone,
  avatarUrl: null,
  isActive: true,
  metadata: {},
  createdAt: DateTime.parse(authUser.createdAt),
  updatedAt: DateTime.now(),
  userApp: userApp,
)
```

---

## 🗄️ Database Tables

### `users` Table
```
id: String (UUID, primary key, matches auth.users.id)
email: String
full_name: String
is_active: Boolean
metadata: JSON
created_at: Timestamp
updated_at: Timestamp
```

### `user_apps` Table (Junction Table)
```
id: String (UUID, primary key)
user_id: String (foreign key → users.id)
app_id: String (identifies which app)
role: String
is_active: Boolean
metadata: JSON
created_at: Timestamp
updated_at: Timestamp
```

---

## 📊 Data Models

### UserApp Model (from `user_app_model.dart`)
```dart
class UserAppModel {
  final String id;
  final String userId;
  final String appId;
  final String role;
  final bool isActive;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

**Methods:**
- `fromJson(Map<String, dynamic>)` - Handles null safety and defaults
- `toJson()` - Converts to Map
- `copyWith()` - Immutable updates

**Safe Parsing:**
- ✅ Date parsing handles String/DateTime/invalid values
- ✅ Metadata safely casts from Map to Map<String, dynamic>
- ✅ Logs warnings for invalid data using `AppLogger.warning`

### User Model (MISSING - needs to be created)
Expected structure based on usage in `supabase_auth_manager.dart`:

```dart
class User {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final bool isActive;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserApp? userApp; // Optional - app-specific registration
  
  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    required this.isActive,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.userApp,
  });
  
  factory User.fromJson(Map<String, dynamic> json, {UserApp? userApp}) {
    return User(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'User',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      metadata: _safeMetadata(json['metadata']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      userApp: userApp,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'is_active': isActive,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? avatarUrl,
    bool? isActive,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserApp? userApp,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? Map<String, dynamic>.from(this.metadata),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userApp: userApp ?? this.userApp,
    );
  }
  
  // Safe parsing methods (same as UserAppModel)
  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
  
  static Map<String, dynamic> _safeMetadata(dynamic data) {
    if (data is Map<String, dynamic>) return Map<String, dynamic>.from(data);
    if (data is Map) return Map<String, dynamic>.from(data.cast<String, dynamic>());
    return const <String, dynamic>{};
  }
}
```

**Note:** This is different from `SupabaseUserModel` which is used in the current implementation.

---

## 🔑 Required Constants (MISSING - needs to be created)

### AuthConstants Class
Location: `lib/src/features/auth/data/auth_constants.dart`

```dart
class AuthConstants {
  // Prevent instantiation
  AuthConstants._();
  
  // Logger name
  static const String loggerName = 'Auth';
  
  // Table names
  static const String usersTable = 'users';
  static const String userAppsTable = 'user_apps';
  
  // Cache keys
  static const String userProfileCacheKey = 'user_profile';
  static const String userIdCacheKey = 'user_id';
  
  // Deep link redirect URLs
  static String resetPasswordRedirectUrl(String deepLinkScheme) {
    return '$deepLinkScheme://reset-password';
  }
  
  static String verifyEmailRedirectUrl(String deepLinkScheme) {
    return '$deepLinkScheme://verify-email';
  }
}
```

### AppConfig Class (MISSING - needs to be created or identified)
Location: `lib/src/core/constants/app_config.dart` or similar

Required properties:
```dart
class AppConfig {
  // App identifier for multi-app support
  static const String appId = 'your_app_id_here';
  
  // Deep link scheme (e.g., 'myapp')
  static const String deepLinkScheme = 'your_deep_link_scheme';
  
  // Default role for new users
  static const String defaultRole = 'user'; // or 'resident', 'admin', etc.
}
```

### AuthManager Base Class (MISSING - needs to be created or identified)
Expected structure based on `supabase_auth_manager.dart`:

```dart
abstract class AuthManager {
  Future<User?> signInWithEmail(String email, String password);
  Future<User?> createAccountWithEmail(String email, String password);
  Future<void> signOut();
  Future<void> deleteUser();
  Future<void> updateEmail({required String email});
  Future<void> updatePassword({required String newPassword});
  Future<void> resetPassword({required String email});
}

mixin EmailSignInManager {
  Future<void> resendVerificationEmail({required String email});
  Future<SignupEligibilityResult> checkSignupEligibility(String email);
  Future<User?> verifyOtpWithEmail({
    required String email,
    required String otpCode,
  });
}
```

### SignupEligibilityResult Class (MISSING - needs to be created)
```dart
enum SignupEligibilityStatus {
  newUser,
  existingUser,
}

class SignupEligibilityResult {
  final SignupEligibilityStatus status;
  final String? message;
  
  const SignupEligibilityResult({
    required this.status,
    this.message,
  });
}
```

---

## 🔄 SupabaseService Wrapper Pattern

All standard database operations use the wrapper from `supabase_config.dart`:

```dart
// Select single record
SupabaseService.selectSingle(
  'table_name',
  filters: {'id': userId},
)

// Select multiple records
SupabaseService.select(
  'table_name',
  filters: {'user_id': userId},
  orderBy: 'created_at',
  ascending: false,
  limit: 10,
)

// Insert record
SupabaseService.insert('table_name', data)

// Update record
SupabaseService.update(
  'table_name',
  data,
  filters: {'id': userId},
)

// Delete record
SupabaseService.delete(
  'table_name',
  filters: {'id': userId},
)
```

**RPC calls use direct client:**
```dart
SupabaseConfig.client.rpc('function_name', params: {...})
```

---

## 🎯 Key Architectural Rules

### ✅ DO:
1. Use `SupabaseService` for all standard CRUD operations
2. Use direct `SupabaseConfig.client.rpc()` ONLY for RPC functions
3. Inject dependencies via constructor (dependency injection pattern)
4. Log all operations using `dart:developer` log with appropriate names
5. Handle errors gracefully in cache layer (don't break auth flow)
6. Rethrow errors in repository layer (let caller handle)
7. Use const constructors where possible
8. Validate and sanitize all data from database/JSON
9. Provide default values for optional fields
10. Use filters with Map syntax: `{'field': value}`

### ❌ DON'T:
1. Mix RPC and standard CRUD in the same method
2. Use direct Supabase client for CRUD operations
3. Create new RPC functions unnecessarily
4. Catch and swallow repository errors silently
5. Use relative imports (always use package imports)
6. Create functions that return widgets (use classes)
7. Hardcode table names or cache keys (use constants)

---

## 🔌 Current Implementation Issues

### Problems with `supabase_auth_remote_data_source.dart`:
1. ❌ Has embedded `_UserProfileRepository` class (should be separate)
2. ❌ Mixes too many responsibilities (auth + profile + user_apps)
3. ❌ Doesn't follow the separation pattern from uploaded files
4. ❌ Uses private class instead of public repository
5. ❌ Doesn't use the three-layer pattern (cache + profile + apps)

### What needs to be refactored:
1. Create separate `UserCacheService` instance
2. Use public `UserProfileRepository` instead of private embedded class
3. Use public `UserAppRepository` for app registration logic
4. Remove `_UserProfileRepository` from auth data source
5. Inject repositories via constructor (dependency injection)
6. Create missing `User` model (different from `SupabaseUserModel`)
7. Create `AuthConstants` class with all constants

---

## 📋 Missing Files Checklist

### New Files to Create:
- [ ] `lib/src/core/models/user_model.dart` - Core User model (different from SupabaseUserModel)
- [ ] `lib/src/features/auth/data/auth_constants.dart` - Constants class with cache keys, table names, logger name, deep link URLs
- [ ] `lib/src/core/constants/app_config.dart` - App configuration (appId, deepLinkScheme, defaultRole) - OR identify existing location
- [ ] `lib/src/features/auth/data/auth_manager.dart` - Base AuthManager abstract class + EmailSignInManager mixin
- [ ] `lib/src/features/auth/data/models/signup_eligibility_result.dart` - SignupEligibilityResult and enum

### Files Already Uploaded (Need Integration):
- [x] `lib/src/features/auth/data/data_sources/user_cache_service.dart` ✅
- [x] `lib/src/features/auth/data/data_sources/user_profile_repository.dart` ✅
- [x] `lib/src/features/auth/data/data_sources/user_app_repository.dart` ✅
- [x] `lib/src/features/auth/data/data_sources/supabase_auth_manager.dart` ✅

### Files to Update:
- [ ] `lib/src/features/auth/data/data_sources/supabase_auth_remote_data_source.dart` - Remove embedded `_UserProfileRepository`, use new repositories
- [ ] `lib/src/core/config/injection.dart` - Register new repositories and services
- [ ] `lib/src/core/helpers/shared_pref_helper.dart` - Add missing methods: `saveObject()`, `getObject()`, `remove()` if not present

### Integration Tasks:
- [ ] Wire up `SupabaseAuthManager` in dependency injection
- [ ] Update auth cubit/repository to use new auth manager
- [ ] Test all authentication flows (sign in, sign up, reset password)
- [ ] Verify multi-app support works correctly
- [ ] Test caching and cache clearing

---

## 🚀 Required RPC Functions (Supabase)

These RPC functions must exist in the Supabase database:

1. **`get_user_by_email(user_email TEXT)`**
   - Returns user record by email
   - Bypasses RLS for password reset validation

2. **`get_user_by_email_with_app_check(user_email TEXT, p_app_id TEXT)`**
   - Returns: `{user: jsonb, user_app: jsonb}`
   - Checks if user exists and has app access

3. **`create_user_profile(p_user_id UUID, p_email TEXT, p_app_id TEXT)`**
   - Creates both users and user_apps records
   - Returns: `{user: jsonb, user_app: jsonb}`

4. **`delete_user()`**
   - Deletes current auth user
   - Uses `auth.uid()` to get current user

5. **`check_user_and_grant_app_access(user_email TEXT, p_app_id TEXT)`**
   - Checks if user exists
   - If exists but not registered for app, grants access
   - Returns: `{user: jsonb, user_app: jsonb}`

---

## 🔍 Questions Before Refactoring - ANSWERED ✅

### 1. User Model Strategy ✅
**Question:** How should we handle the User model?
- Currently there's `SupabaseUserModel` in the codebase
- Uploaded files reference a different `User` model

**Your Answer:** ✅ CONFIRMED
- **Current Model:** `SupabaseUserModel` exists at `lib/src/core/models/supabase_user_model.dart`
- **Structure matches uploaded `User` model:**
  ```dart
  const SupabaseUserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone, // phoneNumber in model
    this.avatarUrl,
    required this.emailVerified, // Additional field
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    // NO userApp field currently
  })
  ```
- **Strategy:** Extend `SupabaseUserModel` to add optional `UserAppModel? userApp` field
- **Action:** Add `userApp` field to existing model, keep `SupabaseUserModel` name

---

### 2. AppConfig Location ✅
**Question:** Where is your app configuration stored?

**Your Answer:** ✅ CONFIRMED at `lib/src/core/config/config.dart`
```dart
class AppConfig {
  static const String appId = 'park_my_whip_tow';
  static const String defaultRole = 'user';
  static const String appName = 'Park My Whip - Tow Drivers';
  static const String deepLinkScheme = 'parkmywhip';
}
```
- ✅ All required fields exist
- ✅ Multi-app support ready (appId differentiates apps)

---

### 3. SharedPrefHelper Compatibility ✅
**Question:** SharedPrefHelper method differences

**Your Answer:** ✅ CONFIRMED - Current implementation ALREADY has compatible methods
- **Current at `lib/src/core/helpers/shared_pref_helper.dart`:**
  ```dart
  ✅ setData({required String key, required dynamic value})
  ✅ getString({required String key})
  ✅ removeData(String key)
  ✅ setSecuredString({required String key, required String value})
  ✅ getSecuredString({required String key})
  ✅ clearAllData()
  ✅ clearAllSecuredData()
  ```
- **Action:** Uploaded files use `saveObject()` / `getObject()` but can adapt to use:
  - `setData(key, jsonEncode(object))` for saving
  - `jsonDecode(await getString(key))` for retrieving

---

### 4. Dependency Injection Framework ✅
**Question:** What DI framework/pattern are you using?

**Your Answer:** ✅ CONFIRMED - **GetIt** at `lib/src/core/config/injection.dart`
```dart
final getIt = GetIt.instance;

void setupDependencyInjection() {
  // Already registered:
  ✅ getIt.registerLazySingleton<SharedPrefHelper>()
  ✅ getIt.registerLazySingleton<AuthLocalDataSource>()
  ✅ getIt.registerLazySingleton<AuthRemoteDataSource>()
  ✅ getIt.registerLazySingleton<AuthRepository>()
  ✅ getIt.registerLazySingleton<AuthCubit>()
  
  // Need to add:
  - UserCacheService (uses SharedPrefHelper)
  - UserProfileRepository
  - UserAppRepository
  - SupabaseAuthManager (if needed)
}
```

---

### 5. Integration Strategy ✅
**Question:** How do you want to proceed?

**Your Answer:** ✅ CONFIRMED - **Full refactor** of current auth feature
- Current `supabase_auth_remote_data_source.dart` has embedded `_UserProfileRepository`
- Needs separation into proper layers
- Keep existing `SupabaseUserModel` but extend with `userApp` field
- Use uploaded architecture pattern for clean separation

---

### 6. Backward Compatibility ✅
**Question:** Do you have existing users with cached data?

**Your Answer:** ✅ NOT APPLICABLE
- App is in development phase
- No production users yet
- Can safely change cache keys and model structure

---

### 7. Multi-App Support ✅
**Question:** Is multi-app support critical for your use case?

**Your Answer:** ✅ CRITICAL - Multi-app is REQUIRED
- Files uploaded show perfect multi-app handling
- Current app: `'park_my_whip_tow'` (tow drivers)
- Future apps: residents app, admin app, etc.
- **Action:** Keep all multi-app logic from uploaded files

---

### 8. RPC Functions Status ✅
**Question:** Have these RPC functions been created in Supabase?

**Your Answer:** ✅ CONFIRMED - Already exist and tested
- User confirmed RPC functions are deployed in Supabase
- ✅ `get_user_by_email_with_app_check` - Already used in current code
- Note: Function name in code is `DbStrings.getUserByEmailWithAppCheck`
- All 5 RPC functions from uploaded files are ready

---

### 9. Database Schema ✅
**Question:** Have the database tables been created with correct schema?

**Your Answer:** ✅ CONFIRMED - Tables exist and tested
- `users` table: ✅ Exists with correct schema
- `user_apps` table: ✅ Exists with correct schema
- Current code already uses these tables (see `_UserProfileRepository` in `supabase_auth_remote_data_source.dart`)
- **UserAppModel** already exists at `lib/src/core/models/user_app_model.dart`

---

### 10. AuthManager Location ✅
**Question:** Where should the base `AuthManager` abstract class live?

**Your Answer:** ✅ DECISION: `lib/src/features/auth/domain/auth_manager.dart`
- Domain layer = business logic interfaces
- Auth feature already has `domain/validators.dart` and `domain/repositories/auth_repository.dart`
- Keeps base classes in domain layer (Clean Architecture)

---

## 🔍 Current Implementation Analysis

### What's Already Working ✅
1. **Database Tables:**
   - ✅ `users` table with proper schema
   - ✅ `user_apps` table for multi-app support
   - ✅ UserAppModel exists at `lib/src/core/models/user_app_model.dart`

2. **Infrastructure:**
   - ✅ `SharedPrefHelper` with all necessary methods
   - ✅ `AppConfig` with appId, defaultRole, deepLinkScheme
   - ✅ GetIt dependency injection setup
   - ✅ `NetworkExceptions` for user-friendly error messages

3. **Current Auth Flow (Partial):**
   - ✅ `checkEmailForApp` RPC call in use
   - ✅ `EmailCheckResult` model exists
   - ✅ Multi-app aware signup eligibility check
   - ✅ User profile creation with user_apps record

### What Needs Refactoring 🔨

1. **Embedded Repository Anti-Pattern:**
   ```dart
   // CURRENT (❌ WRONG):
   class SupabaseAuthRemoteDataSource {
     late final _UserProfileRepository _profileRepo; // Private embedded class
   }
   
   class _UserProfileRepository { ... } // Embedded in same file
   ```
   
   **Should be:**
   ```dart
   // CORRECT (✅):
   class SupabaseAuthRemoteDataSource {
     final UserProfileRepository profileRepo; // Injected public repository
     final UserAppRepository userAppRepo; // Injected public repository
     final UserCacheService cacheService; // Injected cache service
   }
   ```

2. **Missing Separation of Concerns:**
   - Current: `_UserProfileRepository` handles BOTH users AND user_apps tables
   - Should: Separate `UserProfileRepository` and `UserAppRepository`

3. **Missing Pre-Auth Validation in Login:**
   - Current: Only checks email availability in signup
   - Should: Validate app access BEFORE authentication attempt (as per uploaded `SupabaseAuthManager`)

4. **Missing Cache Layer:**
   - Current: No dedicated caching service
   - Should: `UserCacheService` with proper error handling

5. **Model Extension Needed:**
   - `SupabaseUserModel` needs `UserAppModel? userApp` field
   - Need to update `copyWith()`, `fromJson()`, `toJson()` methods

### Key Architecture Differences

| Aspect | Current Implementation | Uploaded Architecture | Action |
|--------|----------------------|---------------------|--------|
| Repository structure | Embedded private class | Separate public classes | ✅ Extract |
| Cache layer | None | UserCacheService | ✅ Add |
| User model | SupabaseUserModel (no userApp) | User with userApp | ✅ Extend |
| Login validation | After auth attempt | Before auth attempt | ✅ Add pre-auth check |
| Multi-app logic | Partial (only in profile creation) | Complete (all flows) | ✅ Complete |
| Error handling | Generic | Specific per flow | ✅ Improve |

---

## 📝 Implementation Roadmap

### Phase 1: Preparation ✅ COMPLETE
1. ✅ Review all uploaded files and document patterns
2. ✅ Answer all 10 questions
3. ✅ Verify Supabase RPC functions exist
4. ✅ Verify database schema is correct
5. ✅ Identify existing infrastructure

### Phase 2: Create Missing Files ⏳ READY TO START
**Files to Create:**

1. **`lib/src/features/auth/data/constants/auth_constants.dart`** (NEW)
   - Cache keys: `userProfileCacheKey`, `userIdCacheKey`
   - Table names: `usersTable`, `userAppsTable`
   - Logger name: `loggerName`
   - Deep link URLs: `resetPasswordRedirectUrl()`, `verifyEmailRedirectUrl()`

2. **`lib/src/features/auth/domain/auth_manager.dart`** (NEW)
   - Abstract `AuthManager` base class
   - Mixin `EmailSignInManager`

3. **`lib/src/features/auth/data/models/signup_eligibility_result.dart`** (NEW)
   - `SignupEligibilityStatus` enum
   - `SignupEligibilityResult` class

4. **`lib/src/features/auth/data/services/user_cache_service.dart`** (UPLOAD)
   - Adapt uploaded file to use current `SharedPrefHelper` methods
   - Use `setData(key, jsonEncode(object))` instead of `saveObject()`

5. **`lib/src/features/auth/data/repositories/user_profile_repository.dart`** (UPLOAD)
   - Adapt uploaded file to use `SupabaseUserModel` instead of `User`
   - Keep all RPC functions as-is

6. **`lib/src/features/auth/data/repositories/user_app_repository.dart`** (UPLOAD)
   - Use existing `UserAppModel` from `lib/src/core/models/user_app_model.dart`

**Files to Extend:**

7. **`lib/src/core/models/supabase_user_model.dart`** (EXTEND)
   - Add `UserAppModel? userApp` field
   - Update `copyWith()`, `fromJson()`, `toJson()`

**Files to Refactor:**

8. **`lib/src/features/auth/data/data_sources/supabase_auth_remote_data_source.dart`** (REFACTOR)
   - Remove embedded `_UserProfileRepository` class
   - Inject `UserProfileRepository`, `UserAppRepository`, `UserCacheService`
   - Add pre-auth validation in login
   - Use new architecture patterns

9. **`lib/src/core/config/injection.dart`** (UPDATE)
   - Register `UserCacheService`
   - Register `UserProfileRepository`
   - Register `UserAppRepository`

### Phase 3: Integration ⏳ PENDING
1. Register all services in dependency injection
2. Wire up repositories in `SupabaseAuthRemoteDataSource`
3. Add pre-auth validation to login flow
4. Test all authentication flows
5. Update cache logic to use `UserCacheService`

### Phase 4: Testing ⏳ PENDING
1. ✅ Sign in flow (with pre-auth validation)
2. ✅ Sign up flow (eligibility check → create account → OTP verify)
3. ✅ Password reset flow (all validation steps)
4. ✅ Multi-app scenarios (user exists from another app)
5. ✅ Account deletion (with multi-app logic)
6. ✅ Caching and cache clearing

### Phase 5: Cleanup ⏳ PENDING
1. Remove `_UserProfileRepository` embedded class
2. Update architecture.md with new patterns
3. Add inline code comments
4. Final smoke testing

---

## 📌 Key Takeaways

### ✅ What Makes This Architecture Good:
1. **Separation of Concerns** - Each class has one job
2. **No RPC in Simple Repos** - Only UserProfileRepository uses RPC, others use SupabaseService
3. **Pre-Authentication Validation** - Sign in validates app access BEFORE auth attempt
4. **Multi-App Support** - Users can access multiple apps with single account
5. **Atomic Operations** - User + UserApp created together via RPC
6. **Proper Error Handling** - Different error types handled differently (cache vs repo)
7. **Dependency Injection** - All dependencies injected via constructor
8. **Comprehensive Logging** - Every operation logged with appropriate context

### ⚠️ Critical Implementation Details:
1. **Sign In** - MUST validate app access BEFORE authentication
2. **Sign Up** - Profile/app records created AFTER OTP verification, not before
3. **Password Reset** - MUST validate: user exists → email verified → app registered → active
4. **Delete User** - ONLY delete auth user if no other app registrations
5. **Caching** - Cache failures should NOT break auth flow
6. **Error Messages** - Specific, user-friendly messages for each failure case

### 🚨 Common Pitfalls to Avoid:
1. ❌ Don't create profile records before OTP verification
2. ❌ Don't skip pre-auth validation in sign in
3. ❌ Don't delete auth user if they have other app registrations
4. ❌ Don't use direct Supabase client for CRUD (use SupabaseService wrapper)
5. ❌ Don't catch and swallow repository errors (let caller handle)
6. ❌ Don't hardcode table names or cache keys (use constants)

---

## 🎯 Summary

This document captures the **complete authentication architecture** from your uploaded files:

**Files Analyzed:**
- ✅ `user_cache_service.dart` - Local caching with SharedPreferences
- ✅ `user_profile_repository.dart` - Database operations for users table + RPC functions
- ✅ `user_app_repository.dart` - Database operations for user_apps table
- ✅ `supabase_auth_manager.dart` - Main auth orchestrator with all flows documented

**What's Documented:**
- ✅ Three-layer repository pattern
- ✅ All authentication flows (sign in, sign up, password reset, account management)
- ✅ Step-by-step implementation logic for each flow
- ✅ Error handling patterns
- ✅ Required RPC functions
- ✅ Database schema
- ✅ Missing files and dependencies
- ✅ 10 critical questions to answer before implementation

**Next Action:**
👉 **Answer the 10 questions** in the "Questions Before Refactoring" section so we can proceed with implementation.

---

**Document Created:** December 2024
**Last Updated:** December 2024  
**Status:** ✅ Phase 1 Complete - All Questions Answered - Ready for Implementation

---

## 🎉 FINAL SUMMARY - READY TO PROCEED

### ✅ What We Have Confirmed:

1. **Infrastructure Ready:**
   - ✅ Supabase tables (`users`, `user_apps`) exist and tested
   - ✅ RPC functions deployed and working
   - ✅ `SharedPrefHelper` with all necessary methods
   - ✅ `AppConfig` with multi-app support
   - ✅ `UserAppModel` already exists
   - ✅ GetIt dependency injection in place

2. **Architecture Decisions Made:**
   - ✅ Keep `SupabaseUserModel`, extend with `userApp` field
   - ✅ Use uploaded three-layer pattern (Cache + ProfileRepo + AppRepo)
   - ✅ Full refactor of current auth implementation
   - ✅ Multi-app support is CRITICAL (keep all logic)
   - ✅ No backward compatibility needed (dev phase)

3. **Clear Implementation Plan:**
   - ✅ 9 files identified (3 new, 3 uploaded, 3 modified)
   - ✅ Step-by-step integration roadmap
   - ✅ All auth flows documented in detail

### 🚀 CRITICAL QUESTIONS - ANSWERED ✅

#### **Q1: Uploaded File Adaptations** ✅
Your uploaded files reference classes/methods that need adaptation:
- `User` model → ✅ Use `SupabaseUserModel` 
- `AuthConstants` → ✅ Use existing `DbStrings`, `ErrorStrings`, `AuthConstStrings`
- `saveObject()` / `getObject()` → ✅ Use `setData(key, jsonEncode())` / `jsonDecode(getString())`

**Answer:** ✅ Will ask before each change

---

#### **Q2: RPC Function Names** ✅
Your current code uses:
```dart
DbStrings.getUserByEmailWithAppCheck = 'get_user_by_email_with_app_check'
```

**Answer:** ✅ CONFIRMED - Use `DbStrings.*` constants from `lib/src/core/constants/strings.dart`
- Line 95: `static const String getUserByEmailWithAppCheck = 'get_user_by_email_with_app_check';`

---

#### **Q3: Error Message Source** ✅
Current code uses `ErrorStrings.*` and `AuthConstStrings.*` for messages.

**Answer:** ✅ CONFIRMED - Use existing string constants:
- `ErrorStrings.*` (lines 106-112 in strings.dart)
- `AuthConstStrings.*` (lines 99-103 in strings.dart)
- `DbStrings.*` (lines 72-96 in strings.dart)

---

#### **Q4: Supabase Client Source** ✅
**Answer:** ✅ CONFIRMED - Use `SupabaseConfig` from `lib/supabase/supabase_config.dart`
```dart
SupabaseConfig.client  // Line 21: static SupabaseClient get client
SupabaseConfig.auth    // Line 22: static GoTrueClient get auth
SupabaseService.*      // Lines 26-158: CRUD wrapper methods
```

✅ This is the SAME as `Supabase.instance.client` (line 21 returns it)

---

#### **Q5: Implementation Approach** ✅
**Answer:** ✅ CONFIRMED - **Option A** - Adapt uploaded files to current patterns:
- ✅ Use `SupabaseUserModel` instead of `User`
- ✅ Use existing `DbStrings`, `ErrorStrings`, `AuthConstStrings`
- ✅ Use `SupabaseConfig.client` and `SupabaseConfig.auth`
- ✅ Use `SupabaseService.*` for CRUD operations
- ✅ Ask before making changes

---

### 📊 NEXT STEPS DECISION TREE:

```
IF you answer the 5 questions above:
  ├─ I will create the 3 new files (AuthConstants, AuthManager, SignupEligibilityResult)
  ├─ I will adapt the 3 uploaded files (UserCacheService, UserProfileRepository, UserAppRepository)
  ├─ I will extend SupabaseUserModel with userApp field
  ├─ I will refactor SupabaseAuthRemoteDataSource
  └─ I will update dependency injection

ELSE:
  └─ Wait for your guidance
```

---

### 🔥 MY RECOMMENDATION:

**Answer these 5 questions, then I'll:**
1. ✅ Create all necessary files
2. ✅ Adapt uploaded files to your codebase patterns  
3. ✅ Refactor current implementation
4. ✅ Test all flows
5. ✅ Document changes

**OR tell me:** "Start with Option A and make reasonable assumptions where needed"

---

**WAITING FOR YOUR GO-AHEAD TO PROCEED** 🚦
