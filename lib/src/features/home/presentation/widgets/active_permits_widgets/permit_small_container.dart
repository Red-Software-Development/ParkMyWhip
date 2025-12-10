import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';

class PermitSmallContainer extends StatelessWidget {
  const PermitSmallContainer({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColor.gray20),
        color: AppColor.gray10,
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: child,
    );
  }
}
