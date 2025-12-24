import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/common_app_bar.dart';
import 'package:park_my_whip/src/core/widgets/common_button.dart';
import 'package:park_my_whip/src/core/widgets/custom_text_field.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/sign_up_cubit/sign_up_cubit.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/sign_up_cubit/sign_up_state.dart';
import 'package:park_my_whip/src/features/auth/presentation/widgets/already_have_account_text.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: BlocBuilder<SignUpCubit, SignUpState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  verticalSpace(12),
                  Text(
                    AuthStrings.welcomeTitle,
                    style: AppTextStyles.urbanistFont34Grey800SemiBold1_2,
                  ),
                  verticalSpace(8),
                  Text(
                    AuthStrings.createAccount,
                    style: AppTextStyles.urbanistFont14Gray800Regular1_4,
                  ),
                  verticalSpace(24),
                  CustomTextField(
                    title: AuthStrings.nameLabel,
                    hintText: AuthStrings.nameHint,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    controller: getIt<SignUpCubit>().signUpNameController,
                    validator: (_) => state.signUpNameError,
                    onChanged: (_) => getIt<SignUpCubit>().onSignUpFieldChanged(),
                  ),
                  verticalSpace(20),
                  CustomTextField(
                    title: AuthStrings.emailLabel,
                    hintText: AuthStrings.emailHint,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    controller: getIt<SignUpCubit>().signUpEmailController,
                    validator: (_) => state.signUpEmailError,
                    onChanged: (_) => getIt<SignUpCubit>().onSignUpFieldChanged(),
                  ),
                  verticalSpace(4),
                  Visibility(
                    visible: state.errorMessage != null,
                    child: Text(
                      state.errorMessage ?? '',
                      style: AppTextStyles.urbanistFont12Red500Regular1_5,
                    ),
                  ),
                  const Spacer(),
                  AlreadyHaveAccountText(),
                  verticalSpace(16),
                  CommonButton(
                    text: AuthStrings.continueText,
                    onPressed: () =>
                        getIt<SignUpCubit>().validateSignupForm(context: context),
                    isEnabled: state.isSignUpButtonEnabled,
                    isLoading: state.isLoading,
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
