import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';

/// Widget that displays password validation rules with visual feedback
class PasswordValidationRules extends StatelessWidget {
  final String password;

  const PasswordValidationRules({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final hasMinLength = password.length >= 12;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValidationRule(
          text: AuthStrings.passwordMinCharacters,
          isValid: hasMinLength,
        ),
        verticalSpace(8),
        ValidationRule(
          text: AuthStrings.passwordUppercase,
          isValid: hasUppercase,
        ),
        verticalSpace(8),
        ValidationRule(
          text: AuthStrings.passwordLowercase,
          isValid: hasLowercase,
        ),
        verticalSpace(8),
        ValidationRule(
          text: AuthStrings.passwordNumber,
          isValid: hasNumber,
        ),
      ],
    );
  }
}

/// Widget that displays a single validation rule with check/cross icon
class ValidationRule extends StatelessWidget {
  final String text;
  final bool isValid;

  const ValidationRule({
    super.key,
    required this.text,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_rounded : Icons.clear_rounded,
          size: 20.sp,
          color: isValid ? AppColor.green : AppColor.grey700,
        ),
        horizontalSpace(8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.urbanistFont14Grey600Regular1_5.copyWith(
              color: isValid ? AppColor.green : AppColor.grey700,
            ),
          ),
        ),
      ],
    );
  }
}
