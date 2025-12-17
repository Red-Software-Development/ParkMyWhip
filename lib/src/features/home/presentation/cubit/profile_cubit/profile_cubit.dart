import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/dashboard_cubit/dashboard_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/profile_cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState());

  void changeEmail() {
    log('Change email tapped', name: 'ProfileCubit', level: 800);
    // TODO: Implement change email functionality
  }

  void changePassword() {
    log('Change password tapped', name: 'ProfileCubit', level: 800);
    // TODO: Implement change password functionality
  }

  void logOut() {
    log('Log out tapped', name: 'ProfileCubit', level: 800);
    // TODO: Implement logout functionality
  }

  void deleteAccount() {
    log('Delete account tapped', name: 'ProfileCubit', level: 800);
    // TODO: Implement delete account functionality
  }

  void navigateToPatrol() {
    getIt<DashboardCubit>().changePage(0);
  }
}
