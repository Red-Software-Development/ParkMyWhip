import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/patrol_cubit/patrol_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/patrol_cubit/patrol_state.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/active_permits_widgets/active_permit_page_content.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/patrol_widgets/patrol_page_content.dart';

class PatrolPage extends StatelessWidget {
  const PatrolPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: BlocBuilder<PatrolCubit, PatrolState>(
          builder: (context, state) {
            final cubit = context.read<PatrolCubit>();
            
            return state.showPermit
                ? ActivePermitPageContent(
                    cubit: cubit,
                    placeName: state.selectedLocation,
                    permits: state.permits,
                    isPermitSearchActive: state.isPermitSearchActive,
                    isLoading: state.isLoadingPermits,
                  )
                : PatrolPageContent(
                    cubit: cubit,
                    username: state.username,
                    locations: state.locations,
                    isLoading: state.isLoadingLocations,
                  );
          },
        ),
      ),
    );
  }
}
