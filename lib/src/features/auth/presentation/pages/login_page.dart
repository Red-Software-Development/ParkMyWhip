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
import 'package:park_my_whip/src/features/auth/presentation/widgets/dont_have_account_text.dart';
import 'package:park_my_whip/src/features/auth/presentation/widgets/forgot_password.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
                    AuthStrings.welcomeBack,
                    style: AppTextStyles.urbanistFont34Grey800SemiBold1_2,
                  ),
                  verticalSpace(8),
                  Text(
                    AuthStrings.loginToApp,
                    style: AppTextStyles.urbanistFont15LightGrayRegular1_33,
                  ),
                  verticalSpace(24),
                  CustomTextField(
                    title: AuthStrings.emailLabel,
                    hintText: AuthStrings.emailHint,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    controller: getIt<AuthCubit>().loginEmailController,
                    validator: (_) => state.loginEmailError,
                    onChanged: (_) => getIt<AuthCubit>().onLoginFieldChanged(),
                  ),
                  verticalSpace(20),
                  CustomTextField(
                    title: AuthStrings.passwordLabel,
                    hintText: '',
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    isPassword: true,
                    controller: getIt<AuthCubit>().loginPasswordController,
                    validator: (_) => state.loginPasswordError,
                    onChanged: (_) => getIt<AuthCubit>().onLoginFieldChanged(),
                  ),
                  verticalSpace(4),
                  Visibility(
                    visible: state.loginGeneralError != null,
                    child: Text(
                      state.loginGeneralError ?? '',
                      style: AppTextStyles.urbanistFont12Red500Regular1_5,
                    ),
                  ),
                  verticalSpace(15),
                  ForgotPassword(),
                  Spacer(),
                  DontHaveAccountText(),
                  verticalSpace(24),
                  CommonButton(
                    text: AuthStrings.login,
                    onPressed: () =>
                        getIt<AuthCubit>().validateLoginForm(context: context),
                    isEnabled: state.isLoginButtonEnabled,
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
