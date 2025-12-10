import 'package:flutter/material.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/dashboard_cubit/dashboard_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/dashboard_nav_bar.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = getIt<DashboardCubit>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: PageView(
          controller: cubit.pageController,
          onPageChanged: cubit.scrollChangePage,
          children: cubit.homeBodes,
        ),
      ),
      bottomNavigationBar: DashboardBottomBar(),
    );
  }
}
