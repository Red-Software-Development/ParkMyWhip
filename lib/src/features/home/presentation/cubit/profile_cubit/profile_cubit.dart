import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/dashboard_cubit/dashboard_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/profile_cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState());

  void changeEmail() {
    debugPrint('Change email tapped');
    // TODO: Implement change email functionality
  }

  void changePassword() {
    debugPrint('Change password tapped');
    // TODO: Implement change password functionality
  }

  void logOut() {
    debugPrint('Log out tapped');
    // TODO: Implement logout functionality
  }

  void deleteAccount() {
    debugPrint('Delete account tapped');
    // TODO: Implement delete account functionality
  }

  void navigateToPatrol() {
    getIt<DashboardCubit>().changePage(0);
  }
}
