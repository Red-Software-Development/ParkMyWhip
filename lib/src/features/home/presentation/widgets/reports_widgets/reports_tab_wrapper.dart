import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/report_cubit/reports_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/report_cubit/reports_state.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/all_active_reports.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/all_history_reports.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/reports_tap_header.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/filter_bottom_sheet.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/common/filter_section.dart';

class ReportsTabWrapper extends StatefulWidget {
  final ReportsCubit cubit;
  final Widget Function(BuildContext context, int currentTabIndex, VoidCallback onBackPress)? builder;
  
  const ReportsTabWrapper({super.key, required this.cubit, this.builder});

  @override
  State<ReportsTabWrapper> createState() => _ReportsTabWrapperState();
}

class _ReportsTabWrapperState extends State<ReportsTabWrapper>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
    _controller.addListener(_onTabChanged);

    // Kick off loading immediately so the shimmer shows before any cached data renders.
    widget.cubit.loadActiveReports();
  }

  void _onTabChanged() {
    if (_controller.indexIsChanging) return;
    widget.cubit.onTabChanged(_controller.index);
  }

  void _handleBackPress() {
    widget.cubit.handleBackPress(_controller.index, (tabIndex) {
      _controller.animateTo(tabIndex);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Expanded(
      child: Column(
        children: [
          /// ----- TAB BAR -----
          ReportsTapHeader(controller: _controller),
          verticalSpace(12),

          /// ----- FILTER SECTION (shown only on History tab) -----
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return _controller.index == 1
                  ? BlocBuilder<ReportsCubit, ReportsState>(
                      bloc: widget.cubit,
                      builder: (context, state) {
                        return FilterSection(
                          activeFilters: widget.cubit.getActiveFilterLabels(),
                          onFilterPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => FilterBottomSheet(
                                currentCriteria: state.filterCriteria,
                                onApplyFilter: (criteria) {
                                  widget.cubit.applyFilter(criteria);
                                },
                              ),
                            );
                          },
                          onRemoveFilter: (filterType) {
                            widget.cubit.removeFilter(filterType);
                          },
                        );
                      },
                    )
                  : const SizedBox.shrink();
            },
          ),
          BlocBuilder<ReportsCubit, ReportsState>(
            bloc: widget.cubit,
            builder: (context, state) {
              return Expanded(
                child: TabBarView(
                  controller: _controller,
                  children: [
                    AllActiveReports(
                      activeReports: state.activeReports,
                      isLoading: state.isLoadingActiveReports,
                    ),
                    AllHistoryReports(
                      historyReports: state.historyReports,
                      isLoading: state.isLoadingHistoryReports,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    if (widget.builder != null) {
      return Column(
        children: [
          widget.builder!(context, _controller.index, _handleBackPress),
          content,
        ],
      );
    }
    
    return content;
  }
}
