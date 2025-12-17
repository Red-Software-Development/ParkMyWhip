import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/common_button.dart';
import 'package:park_my_whip/src/core/widgets/custom_text_field.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/auth_state.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final cubit = getIt<AuthCubit>();
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
                  _PasswordValidationRules(
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

class _PasswordValidationRules extends StatelessWidget {
  final String password;

  const _PasswordValidationRules({required this.password});

  @override
  Widget build(BuildContext context) {
    final hasMinLength = password.length >= 12;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ValidationRule(
          text: AuthStrings.passwordMinCharacters,
          isValid: hasMinLength,
        ),
        verticalSpace(8),
        _ValidationRule(
          text: AuthStrings.passwordUppercase,
          isValid: hasUppercase,
        ),
        verticalSpace(8),
        _ValidationRule(
          text: AuthStrings.passwordLowercase,
          isValid: hasLowercase,
        ),
        verticalSpace(8),
        _ValidationRule(
          text: AuthStrings.passwordNumber,
          isValid: hasNumber,
        ),
      ],
    );
  }
}

class _ValidationRule extends StatelessWidget {
  final String text;
  final bool isValid;

  const _ValidationRule({
    required this.text,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          size: 20.sp,
          color: isValid ? Colors.green : Colors.red,
        ),
        horizontalSpace(8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.urbanistFont14Grey600Regular1_5,
          ),
        ),
      ],
    );
  }
}
