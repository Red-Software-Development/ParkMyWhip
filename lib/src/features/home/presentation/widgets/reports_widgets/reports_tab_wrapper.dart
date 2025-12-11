import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/report_cubit/reports_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/report_cubit/reports_state.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/all_active_reports.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/all_history_reports.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/reports_tap_header.dart';

class ReportsTabWrapper extends StatefulWidget {
  const ReportsTabWrapper({super.key});

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
  }

  void _onTabChanged() {
    if (_controller.indexIsChanging) return;
    if (_controller.index == 0) {
      getIt<ReportsCubit>().loadActiveReports();
    } else if (_controller.index == 1) {
      getIt<ReportsCubit>().loadHistoryReports();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          /// ----- TAB BAR -----
          ReportsTapHeader(controller: _controller),
          BlocBuilder<ReportsCubit, ReportsState>(
            builder: (context, state) {
              return Expanded(
                child: TabBarView(
                  controller: _controller,
                  children: [
                    AllActiveReports(activeReports: state.activeReports),
                    AllHistoryReports(historyReports: state.historyReports),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
