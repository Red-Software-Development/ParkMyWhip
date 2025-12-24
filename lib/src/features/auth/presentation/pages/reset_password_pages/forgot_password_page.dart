import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/common_app_bar_no_scaffold.dart';
import 'package:park_my_whip/src/core/widgets/common_button.dart';
import 'package:park_my_whip/src/core/widgets/custom_text_field.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/reset_password_cubit/reset_password_cubit.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/reset_password_cubit/reset_password_state.dart';
import 'package:park_my_whip/src/core/widgets/common_app_bar.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CommonAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        verticalSpace(24),
                        Text(
                          AuthStrings.confirmYourEmail,
                          style: AppTextStyles.urbanistFont34Grey800SemiBold1_2,
                        ),
                        verticalSpace(8),
                        Text(
                          AuthStrings.resetPasswordSubtitle,
                          style: AppTextStyles.urbanistFont15LightGrayRegular1_33,
                        ),
                        verticalSpace(24),
                        CustomTextField(
                          title: AuthStrings.emailLabel,
                          hintText: AuthStrings.emailHint,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          controller: getIt<ResetPasswordCubit>().forgotPasswordEmailController,
                          validator: (_) => state.forgotPasswordEmailError,
                          onChanged: (_) => getIt<ResetPasswordCubit>().onForgotPasswordFieldChanged(),
                        ),
                        Spacer(),
                        CommonButton(
                          text: state.isLoading ? 'Sending...' : AuthStrings.continueText,
                          onPressed: () => getIt<ResetPasswordCubit>().validateForgotPasswordForm(context: context),
                          isEnabled: state.isForgotPasswordButtonEnabled && !state.isLoading,
                        ),
                        verticalSpace(16),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
