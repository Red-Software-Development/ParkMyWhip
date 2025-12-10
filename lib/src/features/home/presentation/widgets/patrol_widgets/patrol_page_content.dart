import 'package:flutter/material.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/features/home/data/models/location_model.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/patrol_cubit/patrol_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/patrol_widgets/all_patrol_locations.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/patrol_widgets/logo_and_app_name.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/search_text_filed.dart';

class PatrolPageContent extends StatelessWidget {
  const PatrolPageContent({super.key, required this.locations});

  final List<LocationModel> locations;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpace(16),
        LogoAndAppName(),
        verticalSpace(8),
        Text(
          '${HomeStrings.greeting} Mohammed!',
          style: AppTextStyles.urbanistFont18Grey800SemiBold1_25,
        ),
        verticalSpace(35),
        Text(
          HomeStrings.checkSiteTitle,
          style: AppTextStyles.urbanistFont24Grey800SemiBold1,
        ),
        verticalSpace(16),
        SearchTextField(
          hintText: HomeStrings.searchSiteHint,
          controller: getIt<PatrolCubit>().searchPatrolController,
          onChanged: (value) => getIt<PatrolCubit>().searchLocations(value),
          searchActiveHint: HomeStrings.searchSiteHint,
        ),
        verticalSpace(20),
        AllPatrolLocations(locations: locations),
      ],
    );
  }
}
