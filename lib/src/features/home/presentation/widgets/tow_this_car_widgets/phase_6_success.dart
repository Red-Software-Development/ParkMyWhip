import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/assets.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/common_button.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/tow_cubit/tow_cubit.dart';

/// Phase 6: Success screen displayed after confirming towing entry
class Phase6Success extends StatelessWidget {
  const Phase6Success({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TowCubit>();
    
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          cubit.handleBackPress();
        }
      },
      child: Container(
        color: AppColor.white,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        Assets.assetsImagesTowingConfirmed,
                        width: 220.w,
                        height: 220.h,
                      ),
                      verticalSpace(32),
                      Text(
                        HomeStrings.towingConfirmed,
                        style: AppTextStyles.urbanistFont28Grey800SemiBold1,
                      ),
                      verticalSpace(8),
                      Text(
                        HomeStrings.towingThankYou,
                        style: AppTextStyles.urbanistFont15Grey700Regular1_33,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w).copyWith(bottom: 16.h),
              child: CommonButton(
                text: HomeStrings.backToHome,
                onPressed: cubit.handleBackPress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
