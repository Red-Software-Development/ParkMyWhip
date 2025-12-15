import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/constants/tow_my_whip_icons_icons.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/profile_cubit/profile_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/profile_cubit/profile_state.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/profile_widgets/profile_info_card.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/profile_widgets/profile_action_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final cubit = context.read<ProfileCubit>();
        
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (!didPop) {
              cubit.navigateToPatrol();
            }
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    verticalSpace(24),
                    Text(HomeStrings.yourProfile, style: AppTextStyles.urbanistFont24Grey800SemiBold1),
                    verticalSpace(20),
                    ProfileInfoCard(
                      label: HomeStrings.username,
                      value: state.username,
                    ),
                    verticalSpace(16),
                    ProfileInfoCard(
                      label: HomeStrings.email,
                      value: state.email,
                      hasAction: true,
                      onActionTap: cubit.changeEmail,
                    ),
                    verticalSpace(16),
                    ProfileActionCard(
                      text: HomeStrings.changePassword,
                      icon: TowMyWhipIcons.forwardIcon,
                      iconColor: AppColor.grey800,
                      iconSize: 12.sp,
                      onTap: cubit.changePassword,
                    ),
                    verticalSpace(16),
                    ProfileActionCard(
                      text: HomeStrings.logOut,
                      icon: TowMyWhipIcons.logout,
                      iconColor: AppColor.richRed,
                      onTap: cubit.logOut,
                    ),
                    verticalSpace(16),
                    ProfileActionCard(
                      text: HomeStrings.deleteAccount,
                      textColor: AppColor.richRed,
                      onTap: cubit.deleteAccount,
                    ),
                    verticalSpace(24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
