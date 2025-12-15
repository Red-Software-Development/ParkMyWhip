import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/common_app_bar_no_scaffold.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/history_cubit/history_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/history_cubit/history_state.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/common/filter_section.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/history_widgets/all_towing_history.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/history_widgets/history_detail_content.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/filter_bottom_sheet.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        final cubit = context.read<HistoryCubit>();
        
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (!didPop) {
              cubit.handleBackPress();
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                CommonAppBarNoScaffold(onBackPress: cubit.handleBackPress),
                Expanded(
                  child: state.showDetail && state.selectedEntry != null
                      ? HistoryDetailContent(entry: state.selectedEntry!)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            verticalSpace(24),
                            Text(
                              HomeStrings.historyOfTows,
                              style: AppTextStyles.urbanistFont28Grey800SemiBold1,
                            ),
                            verticalSpace(12),
                            FilterSection(
                              activeFilters: cubit.getActiveFilterLabels(),
                              onFilterPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => FilterBottomSheet(
                                    currentCriteria: state.filterCriteria,
                                    onApplyFilter: cubit.applyFilter,
                                  ),
                                );
                              },
                              onRemoveFilter: cubit.removeFilter,
                            ),
                            Expanded(
                              child: AllTowingHistory(
                                towingHistory: state.towingHistory,
                                isLoading: state.isLoadingHistory,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
