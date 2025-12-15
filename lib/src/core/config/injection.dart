import 'package:get_it/get_it.dart';
import 'package:park_my_whip/src/core/helpers/shared_pref_helper.dart';
import 'package:park_my_whip/src/core/services/supabase_user_service.dart';
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
  // External

  // Services
  getIt.registerLazySingleton<SharedPrefHelper>(
    () => SharedPrefHelper(),
  );
  getIt.registerLazySingleton<SupabaseUserService>(
    () => SupabaseUserService(sharedPrefHelper: getIt<SharedPrefHelper>()),
  );

  // Repositories

  // Use Cases

  // Validators
  getIt.registerLazySingleton<Validators>(() => Validators());

  // Cubits
  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(validators: getIt<Validators>()),
  );

  getIt.registerLazySingleton<DashboardCubit>(() => DashboardCubit());
  getIt.registerLazySingleton<PatrolCubit>(() => PatrolCubit());
  getIt.registerLazySingleton<ProfileCubit>(() => ProfileCubit());
  getIt.registerLazySingleton<ReportsCubit>(() => ReportsCubit());
  getIt.registerLazySingleton<TowCubit>(() => TowCubit());
  getIt.registerLazySingleton<HistoryCubit>(() => HistoryCubit());
}
