import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/common_button.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/auth_state.dart';
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
    // Send OTP when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<AuthCubit>().sendOtpForEmailVerification();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: BlocBuilder<AuthCubit, AuthState>(
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
                      getIt<AuthCubit>().onOtpFieldChanged(text: text);
                    },
                  ),
                  Spacer(),
                  CommonButton(
                    text: state.isLoading ? 'Verifying...' : AuthStrings.continueText,
                    onPressed: () {
                      getIt<AuthCubit>().continueFromOTPPage(context: context);
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
