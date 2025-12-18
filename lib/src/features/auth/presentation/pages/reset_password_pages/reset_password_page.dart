import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/common_button.dart';
import 'package:park_my_whip/src/core/widgets/custom_text_field.dart';
import 'package:park_my_whip/src/features/auth/presentation/widgets/password_validation_rules.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/auth_state.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = getIt<AuthCubit>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: BlocBuilder<AuthCubit, AuthState>(
            buildWhen: (previous, current) =>
                previous.resetPasswordError != current.resetPasswordError ||
                previous.resetConfirmPasswordError != current.resetConfirmPasswordError ||
                previous.isResetPasswordButtonEnabled != current.isResetPasswordButtonEnabled ||
                previous.isLoading != current.isLoading ||
                previous.resetPasswordFieldTrigger != current.resetPasswordFieldTrigger,
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  verticalSpace(50),
                  Text(
                    AuthStrings.resetYourPassword,
                    style: AppTextStyles.urbanistFont34Grey800SemiBold1_2,
                  ),
                  verticalSpace(24),
                  CustomTextField(
                    title: AuthStrings.passwordLabel,
                    hintText: '',
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                    controller: cubit.resetPasswordController,
                    validator: (_) => state.resetPasswordError,
                    onChanged: (_) => cubit.onResetPasswordFieldChanged(),
                    isPassword: true,
                  ),
                  verticalSpace(20),
                  CustomTextField(
                    title: AuthStrings.confirmPasswordLabel,
                    hintText: '',
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    controller: cubit.resetConfirmPasswordController,
                    validator: (_) => state.resetConfirmPasswordError,
                    onChanged: (_) => cubit.onResetPasswordFieldChanged(),
                    isPassword: true,
                  ),
                  verticalSpace(24),
                  PasswordValidationRules(
                    password: cubit.resetPasswordController.text,
                  ),
                  Spacer(),
                  CommonButton(
                    text: state.isLoading
                        ? 'Resetting...'
                        : AuthStrings.continueText,
                    onPressed: () =>
                        cubit.validateResetPasswordForm(context: context),
                    isEnabled:
                        state.isResetPasswordButtonEnabled && !state.isLoading,
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

