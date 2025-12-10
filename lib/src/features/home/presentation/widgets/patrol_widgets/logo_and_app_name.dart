import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/assets.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';

class LogoAndAppName extends StatelessWidget {
  const LogoAndAppName({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(Assets.assetsImagesLogo, width: 40.w, height: 26.h),
        horizontalSpace(12.w),
        Text(
          AppStrings.appName,
          style: AppTextStyles.urbanistFont22RichRedBold1_2,
        ),
      ],
    );
  }
}
