import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';

class CommonFormButton extends StatelessWidget {
  const CommonFormButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.color,
  });

  final String text;
  final VoidCallback onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28.h,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColor.redDark,
          disabledBackgroundColor: AppColor.redLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.zero,
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon!, color: AppColor.white, size: 24),
              horizontalSpace(8),
            ],
            Text(text, style: AppTextStyles.urbanistFont10WhiteMedium1),
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
