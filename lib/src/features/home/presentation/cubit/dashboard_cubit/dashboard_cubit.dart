import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/dashboard_cubit/dashboard_state.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/patrol_cubit/patrol_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/pages/dashboard_pages/history_page.dart';
import 'package:park_my_whip/src/features/home/presentation/pages/dashboard_pages/patrol_page.dart';
import 'package:park_my_whip/src/features/home/presentation/pages/dashboard_pages/profile_page.dart';
import 'package:park_my_whip/src/features/home/presentation/pages/dashboard_pages/reports_page.dart';
import 'package:park_my_whip/src/features/home/presentation/pages/dashboard_pages/tow_a_car_page.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(const DashboardState());
  final PageController pageController = PageController();
  int dashboardIndex = 0;
  bool enableOnChange = true;

  final List<Widget> homeBodes = [
    BlocProvider.value(
      value: getIt<PatrolCubit>()..loadLocationData(),
      child: const PatrolPage(),
    ),
    ReportsPage(),
    TowACarPage(),
    HistoryPage(),
    ProfilePage(),
  ];

  /// used to navigate throw pages.
  void changePage(int index) {
    // if (index == 1) {
    // if the user is on calls page, we need to update the call history
    // getIt<CallHistoryCubit>().getCallHistory();
    // } else if (index == 2) {
    // if the user is on contacts page, we need to set the contacts
    // getIt<ContactsCubit>().setContacts();
    // }
    pageController.jumpToPage(index);
    emit(state.copyWith(currentIndex: index));
  }

  /// to prevent multiple calls to changePage
  void scrollChangePage(int index) {
    if (enableOnChange) {
      changePage(index);
    }
    enableOnChange = true;
  }

  navBarChangePage(int index) {
    enableOnChange = false;
    changePage(index);
  }
}
