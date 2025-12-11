import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';

/// Widget displayed while image is being loaded/processed
class ImageLoadingWidget extends StatelessWidget {
  const ImageLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 240.h,
      decoration: BoxDecoration(
        color: AppColor.cardBorder,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Small image icon
            Icon(Icons.image, size: 48.sp, color: AppColor.grey400),
            SizedBox(height: 16.h),
            // // Loading indicator
            // SizedBox(
            //   width: 32.w,
            //   height: 32.h,
            //   child: CircularProgressIndicator(
            //     strokeWidth: 3.w,
            //     valueColor: AlwaysStoppedAnimation<Color>(AppColor.redDark),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
