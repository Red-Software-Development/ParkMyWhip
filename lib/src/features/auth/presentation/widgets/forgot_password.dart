import 'package:flutter/material.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,

      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size(0, 0), // prevents extra height
          tapTargetSize:
              MaterialTapTargetSize.shrinkWrap, // reduces tap padding
        ),
        onPressed: () {},
        child: Text(
          AuthStrings.forgotPassword,
          style: AppTextStyles.urbanistFont16RichRedSemiBold1_2,
        ),
      ),
    );
  }
}
