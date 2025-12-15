import 'package:flutter/material.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/common_app_bar_no_scaffold.dart';
import 'package:park_my_whip/src/features/home/data/models/permit_data_model.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/patrol_cubit/patrol_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/active_permits_widgets/all_active_permit_list.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/common/search_text_filed.dart';

class ActivePermitPageContent extends StatelessWidget {
  const ActivePermitPageContent({
    super.key,
    required this.cubit,
    required this.placeName,
    required this.permits,
    required this.isPermitSearchActive,
    required this.isLoading,
  });

  final PatrolCubit cubit;
  final String placeName;
  final List<PermitModel> permits;
  final bool isPermitSearchActive;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          cubit.closePermit();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonAppBarNoScaffold(
            onBackPress: cubit.closePermit,
          ),
          verticalSpace(12),
          Text(
            placeName,
            style: AppTextStyles.urbanistFont16LightGraySemiBold1_2,
          ),
          verticalSpace(8),
          Text(
            HomeStrings.activePermits,
            style: AppTextStyles.urbanistFont24Grey800SemiBold1,
          ),
          verticalSpace(12),
          SearchTextField(
            hintText: HomeStrings.searchPlateLabel,
            controller: cubit.searchPermitController,
            searchActiveHint: HomeStrings.plateNumberHint,
            onChanged: cubit.searchPermits,
          ),
          verticalSpace(12),
          AllActivePermitList(
            permits: permits,
            isPermitSearchActive: isPermitSearchActive,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
