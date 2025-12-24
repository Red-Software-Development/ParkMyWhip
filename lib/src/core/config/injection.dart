import 'package:get_it/get_it.dart';
import 'package:park_my_whip/src/core/helpers/shared_pref_helper.dart';
import 'package:park_my_whip/src/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:park_my_whip/src/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:park_my_whip/src/features/auth/data/data_sources/supabase_auth_remote_data_source.dart';
import 'package:park_my_whip/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:park_my_whip/src/features/auth/data/repositories/user_app_repository.dart';
import 'package:park_my_whip/src/features/auth/data/repositories/user_profile_repository.dart';
import 'package:park_my_whip/src/features/auth/data/services/user_cache_service.dart';
import 'package:park_my_whip/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:park_my_whip/src/features/auth/domain/validators.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/dashboard_cubit/dashboard_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/history_cubit/history_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/patrol_cubit/patrol_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/profile_cubit/profile_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/report_cubit/reports_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/tow_cubit/tow_cubit.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  // ========== Core Layer ==========
  getIt.registerLazySingleton<SharedPrefHelper>(() => SharedPrefHelper());

  // ========== Auth Feature - Data Layer ==========
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(sharedPrefHelper: getIt<SharedPrefHelper>()),
  );
  
  // New architecture: Register services and repositories
  getIt.registerLazySingleton<UserCacheService>(
    () => UserCacheService(sharedPrefHelper: getIt<SharedPrefHelper>()),
  );
  
  getIt.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepository(),
  );
  
  getIt.registerLazySingleton<UserAppRepository>(
    () => UserAppRepository(),
  );
  
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => SupabaseAuthRemoteDataSource(
      userCacheService: getIt<UserCacheService>(),
      userProfileRepository: getIt<UserProfileRepository>(),
      userAppRepository: getIt<UserAppRepository>(),
    ),
  );

  // ========== Auth Feature - Domain Layer ==========
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<Validators>(() => Validators());

  // ========== Auth Feature - Presentation Layer ==========
  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      authRepository: getIt<AuthRepository>(),
      validators: getIt<Validators>(),
    ),
  );

  // ========== Home Feature - Presentation Layer ==========
  getIt.registerLazySingleton<DashboardCubit>(() => DashboardCubit());
  getIt.registerLazySingleton<PatrolCubit>(() => PatrolCubit());
  getIt.registerLazySingleton<ProfileCubit>(
    () => ProfileCubit(authRepository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<ReportsCubit>(() => ReportsCubit());
  getIt.registerLazySingleton<TowCubit>(() => TowCubit());
  getIt.registerLazySingleton<HistoryCubit>(() => HistoryCubit());
}
