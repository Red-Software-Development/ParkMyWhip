import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/constants/tow_my_whip_icons_icons.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/features/home/data/models/location_model.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/patrol_cubit/patrol_cubit.dart';

class PatrolHeaderWidget extends StatelessWidget {
  const PatrolHeaderWidget({super.key, required this.location});
  final LocationModel location;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        getIt<PatrolCubit>().selectLocation(
          locationId: location.id,
          locationTitle: location.title,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColor.gray20),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.title,
                    style: AppTextStyles.urbanistFont16BlackSemiBold1_2,
                  ),
                  verticalSpace(4),
                  Text(
                    location.description,
                    style: AppTextStyles.urbanistFont12Neutral800Regular1,
                  ),
                ],
              ),
            ),
            Icon(TowMyWhipIcons.forwardIcon, color: AppColor.grey700, size: 18),
          ],
        ),
      ),
    );
  }
}
