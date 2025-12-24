import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/assets.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/common_button.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/reset_password_cubit/reset_password_cubit.dart';

/// Success page displayed after successfully resetting password
class PasswordResetSuccessPage extends StatelessWidget {
  const PasswordResetSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        Assets.assetsImagesTowingConfirmed,
                        width: 220.w,
                        height: 220.h,
                      ),
                      verticalSpace(32),
                      Text(
                        AuthStrings.passwordResetSuccess,
                        style: AppTextStyles.urbanistFont28Grey800SemiBold1,
                      ),
                      verticalSpace(8),
                      Text(
                        AuthStrings.passwordResetSuccessMessage,
                        style: AppTextStyles.urbanistFont15Grey700Regular1_33,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w).copyWith(bottom: 16.h),
              child: CommonButton(
                text: AuthStrings.goToLogin,
                onPressed: () => context.read<ResetPasswordCubit>().navigateFromResetSuccessToLogin(context: context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
