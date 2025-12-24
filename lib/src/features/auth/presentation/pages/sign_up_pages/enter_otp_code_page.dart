import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/common_button.dart';
import 'package:park_my_whip/src/core/helpers/countdown_helper.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/sign_up_cubit/sign_up_cubit.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/sign_up_cubit/sign_up_state.dart';
import 'package:park_my_whip/src/features/auth/presentation/widgets/otp_widget.dart';

class EnterOtpCodePage extends StatefulWidget {
  const EnterOtpCodePage({super.key});

  @override
  State<EnterOtpCodePage> createState() => _EnterOtpCodePageState();
}

class _EnterOtpCodePageState extends State<EnterOtpCodePage> {
  @override
  void initState() {
    super.initState();
    // Send OTP when page loads and start countdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SignUpCubit>().sendOtpOnPageLoad(context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: BlocBuilder<SignUpCubit, SignUpState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  verticalSpace(50),
                  Text(
                    AuthStrings.otpTitle,
                    style: AppTextStyles.urbanistFont34Grey800SemiBold1_2,
                  ),
                  verticalSpace(8),
                  Text(
                    AuthStrings.otpSubtitle,
                    style: AppTextStyles.urbanistFont15LightGrayRegular1_33,
                  ),
                  verticalSpace(24),
                  OtpWidget(
                    errorMessage: state.otpError,
                    onChanged: (text) {
                      context.read<SignUpCubit>().onOtpFieldChanged(text: text);
                    },
                  ),
                  Spacer(),
                  // Resend button or countdown
                  Center(
                    child: state.canResendOtp
                        ? TextButton(
                            onPressed: state.isLoading
                                ? null
                                : () => context.read<SignUpCubit>().resendOtp(context: context),
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
                        : Text(
                            '${AuthStrings.resendIn} ${CountdownHelper.formatCountdownTime(state.otpResendCountdownSeconds)}',
                            style: AppTextStyles.urbanistFont16RichRedSemiBold1_2,
                          ),
                  ),
                  verticalSpace(12),
                  CommonButton(
                    text: state.isLoading ? 'Verifying...' : AuthStrings.continueText,
                    onPressed: () {
                      context.read<SignUpCubit>().continueFromOTPPage(context: context);
                    },
                    isEnabled: state.isOtpButtonEnabled && !state.isLoading,
                  ),
                  verticalSpace(16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
