import 'package:flutter/material.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/constants/tow_my_whip_icons_icons.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/common_button.dart';
import 'package:park_my_whip/src/core/widgets/common_secondary_button.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/patrol_cubit/patrol_cubit.dart';

class NoPermitsFound extends StatelessWidget {
  const NoPermitsFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          verticalSpace(12),
          Row(
            children: [
              horizontalSpace(12),
              Icon(TowMyWhipIcons.close, color: AppColor.red, size: 16),
              horizontalSpace(12),
              Text(
                HomeStrings.noPermitFound,
                style: AppTextStyles.urbanistFont18RedMedium1_25,
              ),
            ],
          ),
          Spacer(),
          CommonButton(
            text: HomeStrings.towCar,
            onPressed: () => getIt<PatrolCubit>().navigateToTowCar(),
            leadingIcon: TowMyWhipIcons.towACar,
          ),
          verticalSpace(12),
          CommonSecondaryButton(
            text: HomeStrings.backToSite,
            onPressed: () => getIt<PatrolCubit>().clearPermitSearch(),
            leadingIcon: TowMyWhipIcons.backIcon,
            iconSize: 16,
          ),
          verticalSpace(20),
        ],
      ),
    );
  }
}
