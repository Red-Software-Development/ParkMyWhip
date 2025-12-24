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
import 'package:park_my_whip/src/core/widgets/common_app_bar.dart';
import 'package:park_my_whip/src/features/auth/presentation/widgets/password_validation_rules.dart';

class CreatePasswordPage extends StatelessWidget {
  const CreatePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = getIt<AuthCubit>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CommonAppBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: BlocBuilder<AuthCubit, AuthState>(
            buildWhen: (previous, current) =>
                previous.createPasswordError != current.createPasswordError ||
                previous.confirmPasswordError != current.confirmPasswordError ||
                previous.isCreatePasswordButtonEnabled != current.isCreatePasswordButtonEnabled ||
                previous.isLoading != current.isLoading ||
                previous.createPasswordFieldTrigger != current.createPasswordFieldTrigger ||
                previous.errorMessage != current.errorMessage,
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  verticalSpace(12),
                  Text(
                    AuthStrings.createPassword,
                    style: AppTextStyles.urbanistFont34Grey800SemiBold1_2,
                  ),
                  verticalSpace(24),
                  CustomTextField(
                    title: AuthStrings.createPassword,
                    hintText: '',
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                    controller: cubit.createPasswordController,
                    validator: (_) => state.createPasswordError,
                    onChanged: (_) => cubit.onCreatePasswordFieldChanged(),
                    isPassword: true,
                  ),
                  verticalSpace(20),
                  CustomTextField(
                    title: AuthStrings.confirmPasswordLabel,
                    hintText: '',
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    controller: cubit.confirmPasswordController,
                    validator: (_) => state.confirmPasswordError,
                    onChanged: (_) => cubit.onCreatePasswordFieldChanged(),
                    isPassword: true,
                  ),
                   verticalSpace(4),
                  Visibility(
                    visible: state.errorMessage != null,
                    child: Text(
                      state.errorMessage ?? '',
                      style: AppTextStyles.urbanistFont12Red500Regular1_5,
                    ),
                  ),
                  verticalSpace(18),
                  PasswordValidationRules(
                    password: cubit.createPasswordController.text,
                  ),
                 
                  Spacer(),
                  CommonButton(
                    text: state.isLoading ? 'Creating Account...' : AuthStrings.continueText,
                    onPressed: () => cubit.validateCreatePasswordForm(context: context),
                    isEnabled: state.isCreatePasswordButtonEnabled && !state.isLoading,
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
