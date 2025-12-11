import 'package:flutter/material.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/common_button.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/tow_cubit/tow_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/tow_cubit/tow_state.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/tow_this_car_widgets/image_picker_button.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/tow_this_car_widgets/image_preview_widget.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/tow_this_car_widgets/image_loading_widget.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/tow_this_car_widgets/phase_progress_indicator.dart';

class Phase3AttachImage extends StatelessWidget {
  const Phase3AttachImage({super.key, required this.state});

  final TowState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpace(24),
        Text(
          HomeStrings.newTowingEntry,
          style: AppTextStyles.urbanistFont14Grey700Regular1_28,
        ),
        verticalSpace(16),
        Text(
          HomeStrings.attachAnImage,
          style: AppTextStyles.urbanistFont24Grey800SemiBold1,
        ),
        verticalSpace(20),
        Text(
          HomeStrings.image,
          style: AppTextStyles.urbanistFont14Grey700Regular1_28,
        ),
        verticalSpace(8),
        _buildImageWidget(context, state),
        const Spacer(),
        PhaseProgressIndicator(currentPhase: 3),
        verticalSpace(16),
        CommonButton(
          text: HomeStrings.next,
          onPressed: () => getIt<TowCubit>().validateAndProceedPhase3(),
          isEnabled: state.isImageButtonEnabled,
        ),
        verticalSpace(24),
      ],
    );
  }

  /// Builds the appropriate widget based on current image state
  /// - Shows loading widget when image is being processed
  /// - Shows picker button when no image is selected
  /// - Shows preview widget when image is selected
  Widget _buildImageWidget(BuildContext context, TowState state) {
    if (state.isImageLoading) {
      return const ImageLoadingWidget();
    }

    if (state.selectedImagePath == null) {
      return ImagePickerButton(
        onTap: () => getIt<TowCubit>().showImageSourcePicker(context),
      );
    }

    return ImagePreviewWidget(
      imagePath: state.selectedImagePath!,
      onChangeTap: () => getIt<TowCubit>().showImageSourcePicker(context),
    );
  }
}
