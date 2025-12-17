import 'package:flutter/material.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/routes/names.dart';
import 'package:park_my_whip/src/core/widgets/common_button.dart';

/// Error page shown when password reset link is expired or invalid
class ResetLinkErrorPage extends StatelessWidget {
  final String? errorMessage;

  const ResetLinkErrorPage({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColor.richRed.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColor.richRed,
                  ),
                ),
                
                verticalSpace(24),
                
                // Title
                Text(
                  AuthStrings.linkExpired,
                  style: AppTextStyles.urbanistFont24Grey800SemiBold1.copyWith(
                    color: AppColor.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                verticalSpace(12),
                
                // Error message
                Text(
                  errorMessage ?? AuthStrings.linkExpiredMessage,
                  style: AppTextStyles.urbanistFont16Grey800Regular1_3.copyWith(
                    color: AppColor.grey700,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                verticalSpace(8),
                
                // Instruction
                Text(
                  AuthStrings.linkExpiredInstruction,
                  style: AppTextStyles.urbanistFont16Grey800Regular1_3.copyWith(
                    color: AppColor.grey700,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                verticalSpace(32),
                
                // Go to login button
                CommonButton(
                  text: AuthStrings.goToLoginButton,
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      RoutesName.login,
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
