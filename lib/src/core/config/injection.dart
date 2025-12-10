import 'package:get_it/get_it.dart';
import 'package:park_my_whip/src/features/auth/domain/validators.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/dashboard_cubit/dashboard_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/patrol_cubit/patrol_cubit.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  // External

  // Services

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
}
