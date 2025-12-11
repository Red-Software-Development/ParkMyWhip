import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/widgets/common_app_bar_no_scaffold.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/dashboard_cubit/dashboard_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/tow_cubit/tow_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/tow_cubit/tow_state.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/tow_this_car_widgets/phase_1_enter_plate_number.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/tow_this_car_widgets/phase_2_select_violation.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/tow_this_car_widgets/phase_3_attach_image.dart';

class TowACarPage extends StatelessWidget {
  const TowACarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TowCubit, TowState>(
      builder: (context, state) {
        Widget phaseWidget;
        switch (state.currentPhase) {
          case 1:
            phaseWidget = Phase1EnterPlateNumber(state: state);
            break;
          case 2:
            phaseWidget = Phase2SelectViolation(state: state);
            break;
          case 3:
            phaseWidget = Phase3AttachImage(state: state);
            break;
          default:
            phaseWidget = const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonAppBarNoScaffold(
                onBackPress: () {
                  if (state.currentPhase == 1) {
                    getIt<DashboardCubit>().changePage(0);
                  } else {
                    getIt<TowCubit>().previousPhase();
                  }
                },
              ),
              Expanded(child: phaseWidget),
            ],
          ),
        );
      },
    );
  }
}
