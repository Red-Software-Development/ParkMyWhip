import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';

class ReportSmallContainer extends StatelessWidget {
  const ReportSmallContainer({super.key, required this.child, this.color});

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColor.gray20),
        color: color ?? AppColor.gray10,
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.5.h),
      child: child,
    );
  }
}
