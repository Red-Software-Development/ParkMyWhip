import 'package:flutter/material.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/features/home/data/models/history_report_model.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/single_history_report.dart';

class AllHistoryReports extends StatelessWidget {
  const AllHistoryReports({super.key, required this.historyReports});
  final List<HistoryReportModel> historyReports;

  @override
  Widget build(BuildContext context) {
    return historyReports.isEmpty
        ? Center(
            child: Text(
              HomeStrings.noHistoryReports,
              style: AppTextStyles.urbanistFont14Gray800Regular1_4,
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return SingleHistoryReport(
                historyReportModel: historyReports[index],
              );
            },
            itemCount: historyReports.length,
          );
  }
}
