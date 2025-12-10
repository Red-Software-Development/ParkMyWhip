import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/constants/tow_my_whip_icons_icons.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/dashboard_cubit/dashboard_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/dashboard_cubit/dashboard_state.dart';

class DashboardBottomBar extends StatelessWidget {
  const DashboardBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 1, color: AppColor.neutral30),
            BottomNavigationBar(
              backgroundColor: AppColor.white,
              elevation: 0,
              //selectedItemColor: AppColor.darkBlue,
              selectedLabelStyle:
                  AppTextStyles.figtreeFont12Primary70SemiBold1_33,
              unselectedLabelStyle:
                  AppTextStyles.figtreeFont12LightGrayMedium1_33,
              items: [
                _bottomNavBarItem(
                  icon: TowMyWhipIcons.map,
                  label: HomeStrings.patrol,
                  isSelected: state.currentIndex == 0,
                ),
                _bottomNavBarItem(
                  icon: TowMyWhipIcons.reports,
                  label: HomeStrings.reports,
                  isSelected: state.currentIndex == 1,
                ),
                _bottomNavBarItem(
                  icon: TowMyWhipIcons.towACar,
                  label: HomeStrings.towCar,
                  isSelected: state.currentIndex == 2,
                ),
                _bottomNavBarItem(
                  icon: TowMyWhipIcons.history,
                  label: HomeStrings.history,
                  isSelected: state.currentIndex == 3,
                ),
                _bottomNavBarItem(
                  icon: TowMyWhipIcons.profile,
                  label: HomeStrings.profile,
                  isSelected: state.currentIndex == 4,
                ),
              ],
              currentIndex: state.currentIndex,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                getIt<DashboardCubit>().navBarChangePage(index);
              },
            ),
          ],
        );
      },
    );
  }

  BottomNavigationBarItem _bottomNavBarItem({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: isSelected ? AppColor.richRed : AppColor.lightGray,
      ),
      label: label,
    );
  }
}
