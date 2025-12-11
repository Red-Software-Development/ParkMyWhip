import 'package:flutter/material.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/common_button.dart';
import 'package:park_my_whip/src/core/widgets/custom_text_field.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/tow_cubit/tow_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/tow_cubit/tow_state.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/tow_this_car_widgets/phase_progress_indicator.dart';

class Phase1EnterPlateNumber extends StatelessWidget {
  const Phase1EnterPlateNumber({super.key, required this.state});

  final TowState state;

  @override
  Widget build(BuildContext context) {
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
          HomeStrings.enterPlateNumberTitle,
          style: AppTextStyles.urbanistFont24Grey800SemiBold1,
        ),
        verticalSpace(20),
        CustomTextField(
          title: HomeStrings.plateNumber,
          hintText: HomeStrings.plateNumberExample,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          controller: getIt<TowCubit>().plateNumberController,
          validator: (_) => state.plateNumberError,
          onChanged: (_) => getIt<TowCubit>().onPlateNumberFieldChanged(),
        ),
        const Spacer(),
        PhaseProgressIndicator(currentPhase: 1),
        verticalSpace(16),
        CommonButton(
          text: HomeStrings.next,
          onPressed: () => getIt<TowCubit>().validateAndProceedPhase1(),
          isEnabled: state.isPlateNumberButtonEnabled,
        ),
        verticalSpace(24),
      ],
    );
  }
}
