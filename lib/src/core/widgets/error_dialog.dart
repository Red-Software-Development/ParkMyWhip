import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';

/// Reusable error dialog that follows the app's design system
/// Used for displaying backend errors when there's no UI space for inline error messages
class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    super.key,
    required this.errorMessage,
    this.title = 'Error',
    this.onDismiss,
  });

  final String errorMessage;
  final String title;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColor.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                color: AppColor.redBG,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: AppColor.richRed,
                size: 32.sp,
              ),
            ),
            verticalSpace(16),

            // Title
            Text(
              title,
              style: AppTextStyles.urbanistFont18Grey800SemiBold1_2,
              textAlign: TextAlign.center,
            ),
            verticalSpace(8),

            // Error message
            Text(
              errorMessage,
              style: AppTextStyles.urbanistFont14Grey700Regular1_28,
              textAlign: TextAlign.center,
            ),
            verticalSpace(24),

            // Dismiss button
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDismiss?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.richRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'OK',
                  style: AppTextStyles.urbanistFont16WhiteRegular1_375,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
