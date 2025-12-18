# Park My Whip Resident App - Architecture & Development Guidelines

## Overview
This document serves as a comprehensive guideline for building the **Park My Whip Resident App** using the same architectural patterns, styling, and conventions as the existing Park My Whip admin app. This ensures consistency across both applications and facilitates code sharing where appropriate.

---

## Table of Contents
1. [Project Structure](#project-structure)
2. [Architecture Pattern](#architecture-pattern)
3. [State Management](#state-management)
4. [Core Module (Shared)](#core-module-shared)
5. [Feature Module Structure](#feature-module-structure)
6. [Styling System](#styling-system)
7. [Routing System](#routing-system)
8. [Backend Integration](#backend-integration)
9. [Dependency Injection](#dependency-injection)
10. [Error Handling](#error-handling)
11. [Code Conventions](#code-conventions)

---

## Project Structure

```
lib/
├── main.dart
├── park_my_whip_resident_app.dart
├── supabase/
│   └── supabase_config.dart
└── src/
    ├── core/                           # Shared across both apps
    │   ├── app_style/
    │   │   └── app_theme.dart          # ✅ USE SAME
    │   ├── constants/
    │   │   ├── colors.dart             # ✅ USE SAME
    │   │   ├── text_style.dart         # ✅ USE SAME
    │   │   ├── assets.dart             # App-specific assets
    │   │   └── strings.dart            # ⚠️  App-specific strings
    │   ├── helpers/
    │   │   ├── spacing.dart            # ✅ USE SAME
    │   │   └── shared_pref_helper.dart # ✅ USE SAME
    │   ├── widgets/                    # Reusable common widgets
    │   │   ├── common_button.dart      # ✅ USE SAME
    │   │   ├── common_app_bar.dart     # ✅ USE SAME
    │   │   ├── custom_text_field.dart  # ✅ USE SAME
    │   │   └── error_dialog.dart       # ✅ USE SAME
    │   ├── routes/
    │   │   ├── router.dart             # ⚠️  App-specific routes
    │   │   └── names.dart              # ⚠️  App-specific route names
    │   ├── networking/
    │   │   └── network_exceptions.dart # ✅ USE SAME
    │   ├── config/
    │   │   ├── injection.dart          # ⚠️  App-specific DI setup
    │   │   └── config.dart             # App config
    │   ├── models/
    │   │   ├── common_model.dart
    │   │   └── supabase_user_model.dart
    │   └── services/
    │       ├── supabase_user_service.dart
    │       └── deep_link_service.dart
    │
    └── features/                       # ⚠️  App-specific features
        ├── auth/                       # Can reuse auth feature entirely
        │   ├── data/
        │   │   └── data_sources/
        │   ├── domain/
        │   │   └── validators.dart
        │   └── presentation/
        │       ├── cubit/
        │       ├── pages/
        │       └── widgets/
        │
        └── resident/                   # NEW: Resident-specific features
            ├── parking/                # Example feature
            │   ├── data/
            │   │   ├── models/
            │   │   └── data_sources/
            │   ├── domain/
            │   └── presentation/
            │       ├── cubit/
            │       ├── pages/
            │       └── widgets/
            └── ...
```

### Legend:
- ✅ **USE SAME**: Identical files shared between apps
- ⚠️ **APP-SPECIFIC**: Different for resident app

---

## Architecture Pattern

### Clean Architecture with BLoC Pattern

The app follows **Clean Architecture** principles with clear separation of concerns:

```
Presentation Layer (UI)
    ↓
Business Logic Layer (Cubit/State)
    ↓
Data Layer (Data Sources, Models)
    ↓
External Services (Supabase, APIs)
```

### Layer Responsibilities:

#### 1. **Presentation Layer** (`presentation/`)
- **Pages**: Stateless widgets that render UI
- **Widgets**: Reusable UI components
- **Cubit**: Business logic and state management

#### 2. **Domain Layer** (`domain/`)
- Validators
- Business rules
- Use cases (optional for simple features)

#### 3. **Data Layer** (`data/`)
- **Models**: Data structures with `fromJson`, `toJson`, `copyWith`
- **Data Sources**: API/Database communication

---

## State Management

### BLoC Pattern with Cubit

**Key Principles:**
1. Use **Cubit** (simpler than Bloc) for state management
2. All pages are **StatelessWidget**
3. State is managed entirely through Cubit
4. Use **Equatable** for efficient state comparison

### Cubit Structure

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// State class - Always extends Equatable
class ParkingState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<Parking>? parkingSpots;
  final bool isButtonEnabled;

  const ParkingState({
    this.isLoading = false,
    this.errorMessage,
    this.parkingSpots,
    this.isButtonEnabled = false,
  });

  // Always implement copyWith
  ParkingState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Parking>? parkingSpots,
    bool? isButtonEnabled,
  }) {
    return ParkingState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      parkingSpots: parkingSpots ?? this.parkingSpots,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
    );
  }

  // Always implement props for Equatable
  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    parkingSpots,
    isButtonEnabled,
  ];
}

// Cubit class
class ParkingCubit extends Cubit<ParkingState> {
  ParkingCubit({
    required this.parkingDataSource,
  }) : super(const ParkingState());

  final ParkingDataSource parkingDataSource;

  // Text controllers (if needed for forms)
  final TextEditingController spotNumberController = TextEditingController();

  // Methods to update state
  void onFieldChanged() {
    final hasSpot = spotNumberController.text.trim().isNotEmpty;
    if (state.isButtonEnabled != hasSpot) {
      emit(state.copyWith(isButtonEnabled: hasSpot));
    }
  }

  Future<void> loadParkingSpots() async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      
      final spots = await parkingDataSource.getParkingSpots();
      
      emit(state.copyWith(
        isLoading: false,
        parkingSpots: spots,
      ));
    } catch (e) {
      final errorMessage = NetworkExceptions.getSupabaseExceptionMessage(e);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      ));
    }
  }

  // Always dispose controllers
  @override
  Future<void> close() {
    spotNumberController.dispose();
    return super.close();
  }
}
```

### Page Structure (Stateless with BlocBuilder)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ParkingPage extends StatelessWidget {
  const ParkingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parking')),
      body: BlocBuilder<ParkingCubit, ParkingState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // UI elements here
              CustomTextField(
                controller: getIt<ParkingCubit>().spotNumberController,
                onChanged: (_) => getIt<ParkingCubit>().onFieldChanged(),
              ),
              CommonButton(
                text: 'Submit',
                onPressed: () => getIt<ParkingCubit>().loadParkingSpots(),
                isEnabled: state.isButtonEnabled && !state.isLoading,
              ),
            ],
          );
        },
      ),
    );
  }
}
```

---

## Core Module (Shared)

### Colors (`lib/src/core/constants/colors.dart`)

**✅ USE EXACTLY AS-IS** - All colors are centrally defined:

```dart
class AppColor {
  static Color black = const Color(0xFF1C1C1E);
  static Color white = const Color(0xFFFFFFFF);
  static Color gray = const Color(0xFF48484A);
  static Color richRed = const Color(0xFFC8102E);      // Primary color
  static Color red = const Color(0xFFF73541);
  static Color green = const Color(0xFF008923);
  // ... more colors
}
```

**Rules:**
- Never hardcode colors in widgets
- Always reference `AppColor.colorName`
- Define new colors here if needed for resident app

---

### Text Styles (`lib/src/core/constants/text_style.dart`)

**✅ USE EXACTLY AS-IS** - All text styles are predefined:

```dart
class FontWeightHelper {
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

class AppTextStyles {
  static TextStyle urbanistFont34Grey800SemiBold1_2 = GoogleFonts.urbanist(
    fontSize: 34.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColor.grey800,
    height: 41 / 34, // 1.2
    letterSpacing: 0.37,
  );
  // ... 50+ predefined text styles
}
```

**Naming Convention:** `{fontFamily}Font{size}{color}{weight}{lineHeight}`
- Example: `urbanistFont16Grey800Regular1_3`

**Rules:**
- Never create inline TextStyle
- Always use predefined styles from `AppTextStyles`
- Use `flutter_screenutil` for responsive sizing (`.sp`, `.h`, `.w`)

---

### App Theme (`lib/src/core/app_style/app_theme.dart`)

**✅ USE EXACTLY AS-IS** - Centralized theme configuration:

```dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColor.white,
      primaryColor: AppColor.richRed,
      colorScheme: ColorScheme.light(...),
      fontFamily: 'Urbanist',
      textTheme: TextTheme(...),
      appBarTheme: AppBarTheme(...),
      elevatedButtonTheme: ElevatedButtonThemeData(...),
      inputDecorationTheme: InputDecorationTheme(...),
    );
  }
}
```

---

### Strings (`lib/src/core/constants/strings.dart`)

**⚠️ APP-SPECIFIC** - Organize strings by feature:

```dart
class AppStrings {
  static const String appName = 'ParkMyWhip Resident';
}

class AuthStrings {
  static const String welcomeTitle = 'Welcome to ParkMyWhip Resident!';
  static const String createAccount = 'Create your account';
  // ... all auth-related strings
}

class ParkingStrings {
  static const String myParkingSpot = 'My Parking Spot';
  static const String spotNumber = 'Spot Number';
  // ... all parking-related strings
}

class SharedPrefStrings {
  static const String userId = 'user_id';
  static const String userProfile = 'user_profile';
}
```

**Rules:**
- Group strings by feature (class per feature)
- Use clear, descriptive names
- No hardcoded strings in UI code

---

### Common Widgets (`lib/src/core/widgets/`)

**✅ REUSE THESE WIDGETS:**

#### 1. **CommonButton**
```dart
CommonButton(
  text: 'Submit',
  onPressed: () => doSomething(),
  isEnabled: true,
  leadingIcon: Icons.add,  // Optional
  trailingIcon: Icons.arrow_forward,  // Optional
  color: AppColor.richRed,  // Optional, defaults to richRed
)
```

#### 2. **CustomTextField**
```dart
CustomTextField(
  title: 'Email',
  hintText: 'Enter your email',
  controller: emailController,
  validator: (_) => state.emailError,
  onChanged: (_) => cubit.onFieldChanged(),
  keyboardType: TextInputType.emailAddress,
  isPassword: false,
)
```

#### 3. **CommonAppBar**
```dart
CommonAppBar(
  title: 'Page Title',
  showBackButton: true,
  actions: [
    IconButton(icon: Icon(Icons.settings), onPressed: () {}),
  ],
)
```

#### 4. **ErrorDialog**
```dart
showDialog(
  context: context,
  builder: (_) => ErrorDialog(
    title: 'Error',
    errorMessage: 'Something went wrong',
    onDismiss: () => Navigator.pop(context),
  ),
);
```

---

### Spacing Helper (`lib/src/core/helpers/spacing.dart`)

**✅ USE EXACTLY AS-IS:**

```dart
// Instead of: SizedBox(height: 16)
verticalSpace(16)

// Instead of: SizedBox(width: 8)
horizontalSpace(8)
```

**Benefits:** Responsive spacing with `flutter_screenutil`

---

## Routing System

### Route Names (`lib/src/core/routes/names.dart`)

**⚠️ APP-SPECIFIC** - Define all route constants:

```dart
class RoutesName {
  // Auth routes
  static const initial = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const dashboard = '/dashboard';
  
  // Feature routes (resident-specific)
  static const parkingSpot = '/parking-spot';
  static const guestPasses = '/guest-passes';
  static const myVehicles = '/my-vehicles';
  static const violations = '/violations';
}
```

---

### Router (`lib/src/core/routes/router.dart`)

**⚠️ APP-SPECIFIC** - Configure all routes:

```dart
class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  /// Determines initial route based on authentication
  static Future<String> getInitialRoute() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        final userService = getIt<SupabaseUserService>();
        final cachedUser = await userService.getCachedUser();
        if (cachedUser != null && cachedUser.emailVerified) {
          return RoutesName.dashboard;
        }
      }
      return RoutesName.login;
    } catch (e) {
      return RoutesName.login;
    }
  }

  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<AuthCubit>(),
            child: const LoginPage(),
          ),
        );
      
      case RoutesName.dashboard:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<DashboardCubit>(),
            child: const DashboardPage(),
          ),
        );
      
      // Add more routes here
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
```

**Routing Pattern:**
- Use named routes
- Provide Cubits via `BlocProvider.value` in router
- Always use `getIt<CubitName>()` for dependency injection

---

## Backend Integration

### Supabase Configuration

**✅ USE SAME PATTERN:**

```dart
// lib/supabase/supabase_config.dart
class SupabaseConfig {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'YOUR_SUPABASE_URL',
      anonKey: 'YOUR_SUPABASE_ANON_KEY',
    );
  }
}

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  setupDependencyInjection();
  runApp(MyApp());
}
```

---

### Data Models

**Pattern for all data models:**

```dart
class ParkingSpot {
  final String id;
  final String spotNumber;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ParkingSpot({
    required this.id,
    required this.spotNumber,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  // From JSON (Supabase)
  factory ParkingSpot.fromJson(Map<String, dynamic> json) {
    return ParkingSpot(
      id: json['id'] as String,
      spotNumber: json['spot_number'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spot_number': spotNumber,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Copy with
  ParkingSpot copyWith({
    String? id,
    String? spotNumber,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ParkingSpot(
      id: id ?? this.id,
      spotNumber: spotNumber ?? this.spotNumber,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

**Requirements:**
- All models must have `fromJson`, `toJson`, and `copyWith`
- Use `DateTime` for timestamp fields
- Field names match Supabase schema (snake_case in JSON, camelCase in Dart)

---

### Data Sources

**Pattern for all data sources:**

```dart
abstract class ParkingDataSource {
  Future<List<ParkingSpot>> getUserParkingSpots(String userId);
  Future<ParkingSpot> createParkingSpot(String userId, String spotNumber);
  Future<void> deleteParkingSpot(String spotId);
}

class SupabaseParkingDataSource implements ParkingDataSource {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<ParkingSpot>> getUserParkingSpots(String userId) async {
    try {
      final response = await _supabase
          .from('parking_spots')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ParkingSpot.fromJson(json))
          .toList();
    } catch (e) {
      log('Error fetching parking spots: $e', name: 'ParkingDataSource', level: 900);
      rethrow;
    }
  }

  @override
  Future<ParkingSpot> createParkingSpot(String userId, String spotNumber) async {
    try {
      final response = await _supabase
          .from('parking_spots')
          .insert({
            'user_id': userId,
            'spot_number': spotNumber,
          })
          .select()
          .single();

      return ParkingSpot.fromJson(response);
    } catch (e) {
      log('Error creating parking spot: $e', name: 'ParkingDataSource', level: 900);
      rethrow;
    }
  }

  @override
  Future<void> deleteParkingSpot(String spotId) async {
    try {
      await _supabase
          .from('parking_spots')
          .delete()
          .eq('id', spotId);
    } catch (e) {
      log('Error deleting parking spot: $e', name: 'ParkingDataSource', level: 900);
      rethrow;
    }
  }
}
```

**Pattern:**
1. Define abstract interface
2. Implement Supabase-specific version
3. Always use try-catch with logging
4. Rethrow exceptions (handled by Cubit)

---

## Dependency Injection

### Setup (`lib/src/core/config/injection.dart`)

**⚠️ APP-SPECIFIC** - Register all dependencies:

```dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  // Services
  getIt.registerLazySingleton<SharedPrefHelper>(
    () => SharedPrefHelper(),
  );
  
  getIt.registerLazySingleton<SupabaseUserService>(
    () => SupabaseUserService(sharedPrefHelper: getIt<SharedPrefHelper>()),
  );

  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => SupabaseAuthRemoteDataSource(),
  );
  
  getIt.registerLazySingleton<ParkingDataSource>(
    () => SupabaseParkingDataSource(),
  );

  // Validators
  getIt.registerLazySingleton<Validators>(() => Validators());

  // Cubits
  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      validators: getIt<Validators>(),
      supabaseUserService: getIt<SupabaseUserService>(),
      authRemoteDataSource: getIt<AuthRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<ParkingCubit>(
    () => ParkingCubit(
      parkingDataSource: getIt<ParkingDataSource>(),
    ),
  );
}
```

**Usage in code:**
```dart
// Access cubit
getIt<ParkingCubit>().loadData();

// Access service
final user = await getIt<SupabaseUserService>().getCachedUser();
```

---

## Error Handling

### Network Exceptions (`lib/src/core/networking/network_exceptions.dart`)

**✅ USE EXACTLY AS-IS** - Centralized error handling:

```dart
// In Cubit
try {
  emit(state.copyWith(isLoading: true));
  final result = await dataSource.fetchData();
  emit(state.copyWith(isLoading: false, data: result));
} catch (e) {
  log('Error: $e', name: 'MyCubit', level: 900, error: e);
  final errorMessage = NetworkExceptions.getSupabaseExceptionMessage(e);
  emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
}

// Show dialog for critical errors
try {
  await criticalOperation();
} catch (e) {
  NetworkExceptions.showErrorDialog(e, title: 'Failed to Save');
}
```

**Features:**
- Translates technical errors to user-friendly messages
- Handles Supabase Auth, Postgrest, and Storage exceptions
- Provides dialog helper for critical errors

---

## Code Conventions

### Dart Style Rules

1. **Imports**
   ```dart
   // ✅ Always use absolute imports
   import 'package:park_my_whip_resident/src/features/auth/presentation/pages/login_page.dart';
   
   // ❌ Never use relative imports
   import '../pages/login_page.dart';
   ```

2. **Widget Organization**
   ```dart
   // ✅ Extract reusable widgets as public classes
   class UserInfoCard extends StatelessWidget {
     const UserInfoCard({super.key, required this.user});
     final User user;
     
     @override
     Widget build(BuildContext context) => Card(...);
   }
   
   // ❌ Don't create widget-returning functions
   Widget _buildUserCard(User user) => Card(...);
   ```

3. **Concise Code**
   ```dart
   // ✅ Use expression body for simple functions
   String getGreeting() => 'Hello!';
   
   // ✅ Avoid unnecessary trailing commas in simple cases
   Text('Hello', style: TextStyle(fontSize: 16))
   
   // ✅ Use trailing commas only for multi-line widget trees
   Column(
     children: [
       Text('Line 1'),
       Text('Line 2'),
     ],  // Trailing comma here for formatting
   )
   ```

4. **Avoid Overflow**
   ```dart
   // In Row/Column, wrap dynamic content
   Row(
     children: [
       Expanded(child: Text(dynamicText)),  // ✅ Prevents overflow
     ],
   )
   
   // For TextFields, wrap in SingleChildScrollView
   SingleChildScrollView(
     child: Column(
       children: [
         TextField(),
       ],
     ),
   )
   ```

5. **Responsive Design**
   ```dart
   // ✅ Always use flutter_screenutil
   SizedBox(height: 16.h, width: 100.w)
   Text('Hello', style: TextStyle(fontSize: 14.sp))
   BorderRadius.circular(8.r)
   
   // ❌ Never use raw values
   SizedBox(height: 16, width: 100)
   ```

6. **State Management**
   ```dart
   // ✅ Pages are always StatelessWidget
   class MyPage extends StatelessWidget {
     const MyPage({super.key});
     
     @override
     Widget build(BuildContext context) {
       return BlocBuilder<MyCubit, MyState>(
         builder: (context, state) => Scaffold(...),
       );
     }
   }
   ```

7. **Controllers**
   ```dart
   // ✅ Controllers live in Cubit, not in pages
   class MyCubit extends Cubit<MyState> {
     final TextEditingController emailController = TextEditingController();
     
     @override
     Future<void> close() {
       emailController.dispose();
       return super.close();
     }
   }
   ```

8. **Logging**
   ```dart
   // ✅ Use dart:developer log
   import 'dart:developer';
   
   log('User logged in: $userId', name: 'AuthCubit', level: 1000);
   log('Error occurred: $e', name: 'AuthCubit', level: 900, error: e);
   
   // For debugging visible to user
   debugPrint('Debug info: $data');
   ```

---

## Feature Module Structure

### Example: Parking Feature

```
lib/src/features/parking/
├── data/
│   ├── models/
│   │   └── parking_spot_model.dart
│   └── data_sources/
│       └── supabase_parking_data_source.dart
├── domain/
│   └── validators.dart  (if needed)
└── presentation/
    ├── cubit/
    │   ├── parking_cubit.dart
    │   └── parking_state.dart
    ├── pages/
    │   ├── parking_dashboard_page.dart
    │   └── add_parking_spot_page.dart
    └── widgets/
        ├── parking_spot_card.dart
        └── parking_status_badge.dart
```

**File Naming:**
- Models: `{entity}_model.dart` (e.g., `parking_spot_model.dart`)
- Data sources: `supabase_{feature}_data_source.dart`
- Cubits: `{feature}_cubit.dart` and `{feature}_state.dart`
- Pages: `{description}_page.dart` (e.g., `add_parking_spot_page.dart`)
- Widgets: `{description}_widget.dart` or `{description}.dart`

---

## Required Dependencies

### pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^9.1.1
  equatable: ^2.0.7

  # Dependency Injection
  get_it: ^9.2.0

  # UI & Fonts
  flutter_screenutil: ^5.9.3
  google_fonts: ^6.3.2

  # Local Storage
  shared_preferences: ^2.2.3
  flutter_secure_storage: ^10.0.0

  # Supabase Backend
  supabase_flutter: '>=1.10.0'

  # Utilities
  intl: ^0.19.0
  pin_code_fields: ^8.0.1  # For OTP
  file_picker: '>=8.1.2'
  image_picker: '>=1.1.2'
  shimmer: ^3.0.0
  app_links: ^6.4.1  # Deep links

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  flutter_native_splash: ^2.4.7
```

---

## Styling System Summary

### Key Principles:
1. **Never hardcode colors** - Always use `AppColor.colorName`
2. **Never hardcode text styles** - Always use `AppTextStyles.styleName`
3. **Use responsive units** - Always use `.sp`, `.h`, `.w`, `.r` from flutter_screenutil
4. **Centralized theme** - Configure once in `AppTheme`, reference everywhere
5. **Spacing helper** - Use `verticalSpace()` and `horizontalSpace()`
6. **Common widgets** - Reuse `CommonButton`, `CustomTextField`, etc.

### Color Palette:
- **Primary**: `AppColor.richRed` (#C8102E)
- **Background**: `AppColor.white` (#FFFFFF)
- **Text Primary**: `AppColor.grey800` (#12181C)
- **Text Secondary**: `AppColor.grey700` (#364753)
- **Success**: `AppColor.green` (#008923)
- **Error**: `AppColor.red` (#F73541)

### Typography:
- **Primary Font**: Urbanist (Google Fonts)
- **Secondary Fonts**: Plus Jakarta Sans, Figtree (for specific use cases)
- **Responsive Sizing**: Uses flutter_screenutil for all sizes

---

## Common Patterns Summary

### 1. Loading State
```dart
// In Cubit
emit(state.copyWith(isLoading: true));
// ... do work
emit(state.copyWith(isLoading: false, data: result));

// In UI
if (state.isLoading) {
  return const Center(child: CircularProgressIndicator());
}
```

### 2. Form Validation
```dart
// In Cubit
void onFieldChanged() {
  final isValid = emailController.text.isNotEmpty;
  if (state.isButtonEnabled != isValid) {
    emit(state.copyWith(isButtonEnabled: isValid));
  }
}

Future<void> submitForm() async {
  final emailError = validators.emailValidator(emailController.text);
  if (emailError != null) {
    emit(state.copyWith(emailError: emailError));
    return;
  }
  // Proceed with submission
}

// In UI
CustomTextField(
  controller: getIt<MyCubit>().emailController,
  validator: (_) => state.emailError,
  onChanged: (_) => getIt<MyCubit>().onFieldChanged(),
)

CommonButton(
  text: 'Submit',
  onPressed: () => getIt<MyCubit>().submitForm(),
  isEnabled: state.isButtonEnabled && !state.isLoading,
)
```

### 3. Navigation
```dart
// From Cubit
Navigator.pushNamed(context, RoutesName.dashboard);
Navigator.pushReplacementNamed(context, RoutesName.login);
Navigator.pop(context);
```

### 4. Data Fetching
```dart
// In Cubit
Future<void> loadData() async {
  try {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    
    final data = await dataSource.fetchData();
    
    emit(state.copyWith(isLoading: false, data: data));
  } catch (e) {
    log('Error: $e', name: 'MyCubit', level: 900, error: e);
    final errorMessage = NetworkExceptions.getSupabaseExceptionMessage(e);
    emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
  }
}
```

---

## Checklist for New Features

When creating a new feature, ensure:

- [ ] Data models have `fromJson`, `toJson`, and `copyWith`
- [ ] State class extends `Equatable` with all fields in `props`
- [ ] State has `copyWith` method
- [ ] Cubit disposes all `TextEditingController`s in `close()`
- [ ] Pages are `StatelessWidget` with `BlocBuilder`
- [ ] All colors use `AppColor.*`
- [ ] All text styles use `AppTextStyles.*`
- [ ] All sizes use `.sp`, `.h`, `.w`, `.r`
- [ ] All strings defined in `strings.dart`
- [ ] Routes defined in `routes/names.dart`
- [ ] Routes registered in `routes/router.dart`
- [ ] Dependencies registered in `config/injection.dart`
- [ ] Error handling uses `NetworkExceptions`
- [ ] Logging uses `dart:developer` log
- [ ] Absolute imports (no relative imports)
- [ ] Reusable widgets are public classes (not functions)

---

## Migration from Admin App

### What to Copy Directly:
1. Entire `lib/src/core/` folder (except `routes/` and `strings.dart`)
2. Auth feature (`lib/src/features/auth/`) if login/signup is identical
3. Supabase configuration pattern

### What to Modify:
1. `strings.dart` - Update for resident-specific terminology
2. `routes/` - Define resident app routes
3. `injection.dart` - Register resident-specific dependencies
4. Feature folders - Create new features for resident functionality

### What to Create New:
1. All resident-specific features (parking, guest passes, violations, etc.)
2. Resident dashboard structure
3. Resident-specific data models

---

## Best Practices Recap

1. **Separation of Concerns**: UI → Cubit → Data Source → Backend
2. **Single Responsibility**: Each class has one clear purpose
3. **Testability**: Business logic in Cubit, UI is stateless
4. **Reusability**: Common widgets, centralized styling
5. **Maintainability**: Clear structure, consistent patterns
6. **Performance**: Lazy singletons, efficient state updates
7. **User Experience**: Loading states, error messages, responsive design
8. **Code Quality**: No hardcoded values, comprehensive logging

---

## Example: Complete Feature Implementation

See the **auth** feature in the existing app as a reference for the complete implementation pattern. It demonstrates:
- Complete flow from UI → Cubit → Data Source → Supabase
- Form validation and state management
- Multi-step flows (signup → OTP → create password)
- Error handling and loading states
- Navigation between pages
- Supabase authentication integration

Study `lib/src/features/auth/` for a complete working example of all patterns described in this document.

---

## Support & Questions

When implementing the resident app:
1. Reference this document for architectural decisions
2. Look at the existing admin app's auth feature as a working example
3. Maintain consistency with the patterns established here
4. Reuse core modules whenever possible to reduce duplication

This architecture ensures both apps maintain consistency while allowing flexibility for app-specific features.
