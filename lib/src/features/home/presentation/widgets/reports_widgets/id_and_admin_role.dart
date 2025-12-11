import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/report_small_container.dart';

class IdAndAdminRole extends StatelessWidget {
  const IdAndAdminRole({
    super.key,
    required this.id,
    required this.adminRole,
    this.child,
  });
  final String id;
  final String adminRole;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ReportSmallContainer(
          child: Text(
            '#$id',
            style: AppTextStyles.urbanistFont10Grey800SemiBold1_54,
          ),
        ),
        horizontalSpace(4),
        ReportSmallContainer(
          child: Row(
            children: [
              Container(
                width: 5.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: AppColor.black,
                  shape: BoxShape.circle,
                ),
              ),
              horizontalSpace(4),
              Text(
                adminRole,
                style: AppTextStyles.urbanistFont10Grey700Medium1_54,
              ),
              if (child != null) ...[
                Spacer(),
                ReportSmallContainer(color: AppColor.redDark, child: child!),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
