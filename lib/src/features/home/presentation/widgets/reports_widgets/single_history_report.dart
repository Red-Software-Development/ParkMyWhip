import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/features/home/data/models/history_report_model.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/car_details_and_submit_time.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/id_and_admin_role.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/plate_number_and_reported_by.dart';

class SingleHistoryReport extends StatelessWidget {
  const SingleHistoryReport({super.key, required this.historyReportModel});
  final HistoryReportModel historyReportModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColor.gray20),
          color: AppColor.veryLightRed,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IdAndAdminRole(
              id: historyReportModel.id,
              adminRole: historyReportModel.adminRole,
              child: Text(
                historyReportModel.expiredReason,
                style: AppTextStyles.urbanistFont12RedLightMedium1_3,
              ),
            ),
            verticalSpace(8),
            CarDetailsAndSubmitTime(
              carDetails: historyReportModel.carDetails,
              submitTime: historyReportModel.submitTime,
            ),
            verticalSpace(12),
            Container(height: 1, color: AppColor.gray20),
            verticalSpace(12),
            PlateNumberAndReportedBy(
              plateNumber: historyReportModel.plateNumber,
              reportedBy: historyReportModel.reportedBy,
            ),
          ],
        ),
      ),
    );
  }
}
