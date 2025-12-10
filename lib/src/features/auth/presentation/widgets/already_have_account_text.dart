import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';

class AlreadyHaveAccountText extends StatelessWidget {
  const AlreadyHaveAccountText({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(
          text: AuthStrings.alreadyHaveAccount,
          style: AppTextStyles.urbanistFont15Grey700Regular1_33,
          children: [
            TextSpan(
              text: AuthStrings.signIn,
              style: AppTextStyles.urbanistFont15Grey700SemiBold1_33,
              recognizer: TapGestureRecognizer()
                ..onTap = () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
