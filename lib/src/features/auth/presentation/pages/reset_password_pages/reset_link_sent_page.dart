import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/assets.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/common_button.dart';
import 'package:park_my_whip/src/core/widgets/error_dialog.dart';
import 'package:park_my_whip/src/core/helpers/countdown_helper.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/reset_password_cubit/reset_password_cubit.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/reset_password_cubit/reset_password_state.dart';

/// Success page displayed after sending password reset email
class ResetLinkSentPage extends StatelessWidget {
  const ResetLinkSentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
      listener: (context, state) {
        // Show error dialog if resend fails
        if (state.forgotPasswordEmailError != null && state.forgotPasswordEmailError!.isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) => ErrorDialog(
              errorMessage: state.forgotPasswordEmailError!,
            ),
          );
        }
      },
      builder: (context, state) {
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
                            AuthStrings.resetLinkSent,
                            style: AppTextStyles.urbanistFont28Grey800SemiBold1,
                          ),
                          verticalSpace(8),
                          Text(
                            AuthStrings.resetLinkSentSubtitle,
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Resend button or countdown
                      if (state.canResendEmail)
                        TextButton(
                          onPressed: state.isLoading ? null : () => context.read<ResetPasswordCubit>().resendPasswordResetEmail(context: context),
                          child: state.isLoading
                              ? SizedBox(
                                  width: 16.w,
                                  height: 16.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColor.richRed,
                                  ),
                                )
                              : Text(
                                  AuthStrings.resend,
                                  style: AppTextStyles.urbanistFont16RichRedSemiBold1_2,
                                ),
                        )
                      else
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Text(
                            '${AuthStrings.resendIn} ${CountdownHelper.formatCountdownTime(state.resendCountdownSeconds)}',
                            style: AppTextStyles.urbanistFont16RichRedSemiBold1_2,
                          ),
                        ),
                      
                      verticalSpace(8),
                      
                      // Go to login button
                      CommonButton(
                        text: AuthStrings.goToLogin,
                        onPressed: () => context.read<ResetPasswordCubit>().navigateFromResetLinkToLogin(context: context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
