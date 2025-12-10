import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpWidget extends StatelessWidget {
  const OtpWidget({super.key, required this.onChanged, this.errorMessage});
  final Function(String) onChanged;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 17.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PinCodeTextField(
            length: 5,
            hintCharacter: '0',
            obscureText: false,
            hintStyle: AppTextStyles.urbanistFont16Grey800Opacity40Regular1_3,
            textStyle: AppTextStyles.urbanistFont16BlackRegular1_2,
            animationType: AnimationType.fade,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(10.r),
              fieldHeight: 44.h,
              fieldWidth: 44.w,
              activeFillColor: Colors.transparent,
              selectedFillColor: Colors.transparent,
              inactiveFillColor: Colors.transparent,
              activeColor: AppColor.grey300,
              selectedColor: AppColor.grey800,
              inactiveColor: AppColor.grey300,
            ),
            animationDuration: Duration(milliseconds: 300),
            enableActiveFill: true,
            controller: getIt<AuthCubit>().otpController,
            onChanged: (value) {
              onChanged(value);
            },
            beforeTextPaste: (text) {
              return false;
            },
            appContext: context,
          ),
          Text(
            errorMessage ?? '',
            style: AppTextStyles.urbanistFont12Red500Regular1_5,
          ),
        ],
      ),
    );
  }
}

//
