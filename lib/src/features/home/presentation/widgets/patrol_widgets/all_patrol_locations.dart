import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/features/home/data/models/location_model.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/patrol_widgets/patrol_header_widget.dart';

class AllPatrolLocations extends StatelessWidget {
  const AllPatrolLocations({super.key, required this.locations});
  final List<LocationModel> locations;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: locations.isEmpty
          ? Center(
              child: Text(
                HomeStrings.noLocationsFound,
                style: AppTextStyles.urbanistFont14Gray800Regular1_4,
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: locations.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: PatrolHeaderWidget(location: locations[index]),
                );
              },
            ),
    );
  }
}
