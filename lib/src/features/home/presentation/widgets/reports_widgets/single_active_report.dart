import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/constants/tow_my_whip_icons_icons.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/common_form_button.dart';
import 'package:park_my_whip/src/core/widgets/common_form_text_button.dart';
import 'package:park_my_whip/src/features/home/data/models/active_reports_model.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/car_details_and_submit_time.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/id_and_admin_role.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/plate_number_and_reported_by.dart';

class SingleActiveReport extends StatelessWidget {
  const SingleActiveReport({super.key, required this.activeReportData});
  final ActiveReportModel activeReportData;

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
              id: activeReportData.id,
              adminRole: activeReportData.adminRole,
            ),
            verticalSpace(8),
            CarDetailsAndSubmitTime(
              carDetails: activeReportData.carDetails,
              submitTime: activeReportData.submitTime,
            ),
            verticalSpace(12),
            Container(height: 1, color: AppColor.gray20),
            verticalSpace(12),
            PlateNumberAndReportedBy(
              plateNumber: activeReportData.plateNumber,
              reportedBy: activeReportData.reportedBy,
            ),
            verticalSpace(12),
            additionalNotesAndAttachedImages(),
            verticalSpace(12),
            Container(height: 1, color: AppColor.gray20),
            verticalSpace(12),
            dismissAndViewButtons(),
          ],
        ),
      ),
    );
  }

  Widget additionalNotesAndAttachedImages() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              HomeStrings.additionalNotesLabel,
              style: AppTextStyles.urbanistFont10Grey700Regular1_3,
            ),
            Spacer(),
            Text(
              HomeStrings.attachedImages,
              style: AppTextStyles.urbanistFont10Grey700Regular1_3,
            ),
          ],
        ),
        verticalSpace(4),
        Row(
          children: [
            Text(
              '“${activeReportData.additionalNotes}”',
              style: AppTextStyles.urbanistFont14Grey800Bold1,
            ),
            Spacer(),
            imageContainer(),
          ],
        ),
      ],
    );
  }

  Widget imageContainer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColor.redDark.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Icon(TowMyWhipIcons.image, color: AppColor.richRed, size: 16),
          horizontalSpace(4),
          Text(
            activeReportData.attachedImage,
            style: AppTextStyles.urbanistFont12RedDarkLight1_25,
          ),
        ],
      ),
    );
  }

  Widget dismissAndViewButtons() {
    return Row(
      children: [
        Expanded(
          child: CommonFormTextButton(
            text: HomeStrings.dismissAction,
            onPressed: () {},
          ),
        ),
        horizontalSpace(8),
        Expanded(
          child: CommonFormButton(text: HomeStrings.view, onPressed: () {}),
        ),
      ],
    );
  }
}
