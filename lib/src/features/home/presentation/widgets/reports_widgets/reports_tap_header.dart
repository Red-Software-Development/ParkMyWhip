import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';

class ReportsTapHeader extends StatelessWidget {
  const ReportsTapHeader({super.key, required this.controller});
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColor.veryLightRed,
        borderRadius: BorderRadius.circular(99.r),
      ),
      child: TabBar(
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        controller: controller,
        indicator: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(99.r),
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowColor.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColor.black,
        unselectedLabelColor: AppColor.black,
        labelStyle: AppTextStyles.urbanistFont16BlackSemiBold1_2,
        unselectedLabelStyle: AppTextStyles.urbanistFont16BlackSemiBold1_2,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(HomeStrings.activeTab),
                horizontalSpace(8),
                Visibility(
                  visible: false,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Tab(text: HomeStrings.historyTab),
        ],
      ),
    );
  }
}
