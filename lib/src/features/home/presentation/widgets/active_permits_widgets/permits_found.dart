import 'package:flutter/material.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/constants/tow_my_whip_icons_icons.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';

class PermitsFound extends StatelessWidget {
  const PermitsFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(TowMyWhipIcons.correctCheckmark, color: AppColor.green, size: 16),
        horizontalSpace(12),
        Text(
          HomeStrings.permitFound,
          style: AppTextStyles.urbanistFont18GreenMedium1_25,
        ),
      ],
    );
  }
}
