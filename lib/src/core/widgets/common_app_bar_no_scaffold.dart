import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/tow_my_whip_icons_icons.dart';

class CommonAppBarNoScaffold extends StatelessWidget {
  const CommonAppBarNoScaffold({super.key, required this.onBackPress});
  final Function() onBackPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColor.grey200,
            child: IconButton(
              onPressed: onBackPress,
              icon: Icon(
                TowMyWhipIcons.backIcon,
                size: 12,
                color: AppColor.grey700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
