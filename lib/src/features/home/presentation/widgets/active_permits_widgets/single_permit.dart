import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/features/home/data/models/permit_data_model.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/active_permits_widgets/permit_small_container.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/active_permits_widgets/permits_found.dart';

class SinglePermit extends StatelessWidget {
  const SinglePermit({
    super.key,
    required this.permit,
    required this.showPermissionFound,
  });
  final PermitModel permit;
  final bool showPermissionFound;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColor.gray20),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              idAndPermitWithDate(),
              verticalSpace(8),
              Text(
                permit.vehicleInfo.model,
                style: AppTextStyles.urbanistFont16Grey800Bold1,
              ),
              Text(
                '${permit.vehicleInfo.year} - ${permit.vehicleInfo.color}',
                style: AppTextStyles.urbanistFont12Grey800Regular1_64,
              ),
              verticalSpace(12),
              Container(height: 1, color: AppColor.gray20),
              verticalSpace(12),
              plateNumberAndSpotNumber(),
            ],
          ),
        ),
        verticalSpace(12),
        Visibility(visible: showPermissionFound, child: PermitsFound()),
      ],
    );
  }

  Widget idAndPermitWithDate() {
    return Row(
      children: [
        PermitSmallContainer(
          child: Text(
            'ID: ${permit.id}',
            style: AppTextStyles.urbanistFont10Grey800SemiBold1_54,
          ),
        ),
        horizontalSpace(4),
        PermitSmallContainer(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: HomeStrings.permit,
                  style: AppTextStyles.urbanistFont10Grey700Medium1_54,
                ),
                TextSpan(
                  text: permit.permitType,
                  style: AppTextStyles.urbanistFont10Grey800SemiBold1_54,
                ),
              ],
            ),
          ),
        ),
        Spacer(),
        PermitSmallContainer(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: HomeStrings.expires,
                  style: AppTextStyles.urbanistFont10Grey700Medium1_54,
                ),
                TextSpan(
                  text: DateFormat('dd/MM/yyyy').format(permit.expiryDate),
                  style: AppTextStyles.urbanistFont10Grey800SemiBold1_54,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget plateNumberAndSpotNumber() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              HomeStrings.plateNumber,
              style: AppTextStyles.urbanistFont10Grey700Regular1_3,
            ),
            Spacer(),
            Text(
              HomeStrings.spotNumber,
              style: AppTextStyles.urbanistFont10Grey700Regular1_3,
            ),
          ],
        ),
        verticalSpace(2),
        Row(
          children: [
            Text(
              permit.plateSpotInfo.plateNumber,
              style: AppTextStyles.urbanistFont14Grey800Bold1,
            ),
            Spacer(),
            Text(
              permit.plateSpotInfo.spotNumber,
              style: AppTextStyles.urbanistFont14Grey800Bold1,
            ),
          ],
        ),
      ],
    );
  }
}
