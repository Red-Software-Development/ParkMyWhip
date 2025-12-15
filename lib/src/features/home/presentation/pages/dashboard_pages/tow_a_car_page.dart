import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/widgets/common_app_bar_no_scaffold.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/tow_cubit/tow_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/tow_cubit/tow_state.dart';
import 'package:park_my_whip/src/features/home/presentation/helpers/phase_widget_builder.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/tow_this_car_widgets/phase_6_success.dart';

class TowACarPage extends StatelessWidget {
  const TowACarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TowCubit, TowState>(
      builder: (context, state) {
        if (state.currentPhase == 6) {
          return const Phase6Success();
        }

        final cubit = context.read<TowCubit>();

        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (!didPop) {
              cubit.handleBackPress();
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonAppBarNoScaffold(
                  onBackPress: cubit.handleBackPress,
                ),
                Expanded(child: PhaseWidgetBuilder.build(state)),
              ],
            ),
          ),
        );
      },
    );
  }
}
