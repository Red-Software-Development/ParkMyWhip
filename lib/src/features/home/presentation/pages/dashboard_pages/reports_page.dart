import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/common_app_bar_no_scaffold.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/report_cubit/reports_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/reports_tab_wrapper.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReportsCubit>();
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ReportsTabWrapper(
        cubit: cubit,
        builder: (context, currentTabIndex, onBackPress) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              if (!didPop) {
                onBackPress();
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonAppBarNoScaffold(onBackPress: onBackPress),
                verticalSpace(12),
                Text(
                  HomeStrings.reports,
                  style: AppTextStyles.urbanistFont24Grey800SemiBold1,
                ),
                verticalSpace(12),
              ],
            ),
          );
        },
      ),
    );
  }
}
