import 'package:flutter/material.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/common_button.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/tow_cubit/tow_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/tow_cubit/tow_state.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/tow_this_car_widgets/phase_progress_indicator.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/tow_this_car_widgets/violation_option_item.dart';

class Phase2SelectViolation extends StatelessWidget {
  const Phase2SelectViolation({super.key, required this.state});

  final TowState state;

  @override
  Widget build(BuildContext context) {
    final violationOptions = [
      HomeStrings.unauthorizedParking,
      HomeStrings.parkedInReservedZone,
      HomeStrings.expiredPermit,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpace(24),
        Text(
          HomeStrings.newTowingEntry,
          style: AppTextStyles.urbanistFont14Grey700Regular1_28,
        ),
        verticalSpace(16),
        Text(
          HomeStrings.selectViolationReason,
          style: AppTextStyles.urbanistFont24Grey800SemiBold1,
        ),
        verticalSpace(32),
        ...violationOptions.map(
          (option) => ViolationOptionItem(
            title: option,
            isSelected: state.selectedViolation == option,
            onTap: () => getIt<TowCubit>().selectViolation(option),
          ),
        ),
        const Spacer(),
        PhaseProgressIndicator(currentPhase: 2),
        verticalSpace(16),
        CommonButton(
          text: HomeStrings.next,
          onPressed: () => getIt<TowCubit>().validateAndProceedPhase2(),
          isEnabled: state.isViolationButtonEnabled,
        ),
        verticalSpace(24),
      ],
    );
  }
}
