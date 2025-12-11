import 'package:flutter/material.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/features/home/data/models/active_reports_model.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/single_active_report.dart';

class AllActiveReports extends StatelessWidget {
  const AllActiveReports({super.key, required this.activeReports});
  final List<ActiveReportModel> activeReports;

  @override
  Widget build(BuildContext context) {
    return activeReports.isEmpty
        ? Center(
            child: Text(
              HomeStrings.noActiveReports,
              style: AppTextStyles.urbanistFont14Gray800Regular1_4,
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return SingleActiveReport(activeReportData: activeReports[index]);
            },
            itemCount: activeReports.length,
          );
  }
}
