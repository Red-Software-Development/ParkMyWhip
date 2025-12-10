import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';

class CommonButton extends StatelessWidget {
  const CommonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String text;
  final VoidCallback onPressed;
  final bool isEnabled;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.h,

      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppColor.richRed : AppColor.redLight,
          disabledBackgroundColor: AppColor.redLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 11.h),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon!, color: AppColor.white, size: 24),
              horizontalSpace(8),
            ],
            Text(text, style: AppTextStyles.urbanistFont18WhiteRegular1_375),
            if (trailingIcon != null) ...[
              horizontalSpace(8),
              Icon(trailingIcon!, color: AppColor.white, size: 24),
            ],
          ],
        ),
      ),
    );
  }
}
