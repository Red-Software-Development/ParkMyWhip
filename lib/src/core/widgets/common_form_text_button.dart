import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';

class CommonFormTextButton extends StatelessWidget {
  const CommonFormTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String text;
  final VoidCallback onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28.h,
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
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
            Text(text, style: AppTextStyles.urbanistFont12RedDarkLight1_25),
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
