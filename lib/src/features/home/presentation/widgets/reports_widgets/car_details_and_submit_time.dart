import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';

class CarDetailsAndSubmitTime extends StatelessWidget {
  const CarDetailsAndSubmitTime({
    super.key,
    required this.carDetails,
    required this.submitTime,
  });
  final String carDetails;
  final DateTime submitTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(carDetails, style: AppTextStyles.urbanistFont16Grey800Bold1),
        verticalSpace(8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: HomeStrings.submitTimeLabel,
                style: AppTextStyles.urbanistFont10Grey700Regular1_3,
              ),
              TextSpan(
                text: DateFormat('dd/MM/yyyy, HH:mm:ss').format(submitTime),
                style: AppTextStyles.urbanistFont10Grey800SemiBold1_54,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
