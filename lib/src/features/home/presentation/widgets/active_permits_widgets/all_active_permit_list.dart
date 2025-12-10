import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/constants/tow_my_whip_icons_icons.dart';
import 'package:park_my_whip/src/core/widgets/common_secondary_button.dart';
import 'package:park_my_whip/src/features/home/data/models/permit_data_model.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/patrol_cubit/patrol_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/active_permits_widgets/no_permits_found.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/active_permits_widgets/single_permit.dart';

class AllActivePermitList extends StatelessWidget {
  const AllActivePermitList({
    super.key,
    required this.permits,
    required this.isPermitSearchActive,
  });
  final List<PermitModel> permits;
  final bool isPermitSearchActive;

  @override
  Widget build(BuildContext context) {
    return permits.isEmpty
        ? isPermitSearchActive
              ? NoPermitsFound()
              : Center(
                  child: Text(
                    HomeStrings.noPermitFound,
                    style: AppTextStyles.urbanistFont14Gray800Regular1_4,
                  ),
                )
        : Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: permits.length,
                    itemBuilder: (context, index) {
                      return SinglePermit(
                        permit: permits[index],
                        showPermissionFound:
                            (isPermitSearchActive &&
                            (index == permits.length - 1)),
                      );
                    },
                  ),
                ),
                Visibility(
                  visible: isPermitSearchActive,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: CommonSecondaryButton(
                      text: HomeStrings.backToSite,
                      onPressed: () => getIt<PatrolCubit>().clearPermitSearch(),
                      leadingIcon: TowMyWhipIcons.backIcon,
                      iconSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
