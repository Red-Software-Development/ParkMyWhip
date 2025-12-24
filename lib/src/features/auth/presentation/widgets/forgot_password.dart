import 'package:flutter/material.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/login_cubit/login_cubit.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: () => getIt<LoginCubit>().navigateToForgotPasswordPage(context: context),
        child: Text(
          AuthStrings.forgotPassword,
          style: AppTextStyles.urbanistFont16RichRedSemiBold1_2,
        ),
      ),
    );
  }
}
