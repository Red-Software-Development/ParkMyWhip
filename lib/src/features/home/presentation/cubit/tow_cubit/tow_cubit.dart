import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/features/auth/domain/validators.dart';
import 'package:park_my_whip/src/features/home/data/models/towing_entry_model.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/dashboard_cubit/dashboard_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/tow_cubit/tow_state.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/tow_this_car_widgets/image_source_bottom_sheet.dart';

/// Manages the Tow-a-Car multi-step wizard, handling validation, image picking,
/// and progression logic across all phases.
class TowCubit extends Cubit<TowState> {
  static const Duration _imageProcessingDelay = Duration(milliseconds: 500);

  final Validators _validators = Validators();
  final TextEditingController plateNumberController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  TowCubit() : super(const TowState());

  /// Resets the entire tow flow to its initial state and clears user input.
  void resetState() {
    plateNumberController.clear();
    notesController.clear();
    emit(const TowState());
  }

  /// Clears any error or success messages currently shown to the user.
  void clearMessages() {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }

  /// Listens for plate field changes to enable/disable Phase 1 button and
  /// re-run validation if an error was previously displayed.
  void onPlateNumberFieldChanged() {
    final text = plateNumberController.text;
    final shouldEnable = text.trim().isNotEmpty;

    String? updatedError = state.plateNumberError;
    if (state.plateNumberError != null) {
      updatedError = _validators.plateNumberValidator(text);
    }

    final shouldEmit =
        state.isPlateNumberButtonEnabled != shouldEnable || updatedError != state.plateNumberError;
    if (shouldEmit) {
      emit(state.copyWith(isPlateNumberButtonEnabled: shouldEnable, plateNumberError: updatedError));
    }
  }

  /// Validates Phase 1 (plate number) and proceeds when input is valid.
  void validateAndProceedPhase1() {
    final error = _validators.plateNumberValidator(plateNumberController.text);
    if (error == null) {
      final entry = TowingEntryModel(plateNumber: plateNumberController.text.trim().toUpperCase());
      emit(state.copyWith(towingEntry: entry, plateNumberError: null));
      nextPhase();
    } else {
      emit(state.copyWith(plateNumberError: error));
    }
  }

  /// Stores the selected violation reason and enables the Phase 2 button.
  void selectViolation(String violation) {
    final updatedEntry = state.towingEntry?.copyWith(reason: violation);
    emit(state.copyWith(selectedViolation: violation, isViolationButtonEnabled: true, towingEntry: updatedEntry));
  }

  /// Proceeds past Phase 2 once a violation has been selected.
  void validateAndProceedPhase2() {
    if (state.selectedViolation != null && state.selectedViolation!.isNotEmpty) {
      nextPhase();
    }
  }

  /// Displays the modal bottom sheet allowing the user to pick camera or gallery.
  void showImageSourcePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ImageSourceBottomSheet(
        onCameraTap: () => _pickImageFromCamera(),
        onGalleryTap: () => _pickImageFromGallery(),
      ),
    );
  }

  /// Picks an image from the device camera.
  Future<void> _pickImageFromCamera() async {
    await _pickImage(ImageSource.camera);
  }

  /// Picks an image from the gallery/photos library.
  Future<void> _pickImageFromGallery() async {
    await _pickImage(ImageSource.gallery);
  }

  /// Handles the common image-picking logic (loading state + entry updates).
  Future<void> _pickImage(ImageSource source) async {
    try {
      emit(state.copyWith(isImageLoading: true));

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        await Future.delayed(_imageProcessingDelay);

        final imagePath = kIsWeb ? pickedFile.path : pickedFile.path;
        final updatedEntry = state.towingEntry?.copyWith(attachedImage: imagePath);

        emit(state.copyWith(
          selectedImagePath: imagePath,
          isImageButtonEnabled: true,
          isImageLoading: false,
          towingEntry: updatedEntry,
        ));
      } else {
        emit(state.copyWith(isImageLoading: false));
      }
    } catch (e) {
      log('Error picking image: $e', name: 'TowCubit', level: 900, error: e);
      emit(state.copyWith(isImageLoading: false));
    }
  }

  /// Validates Phase 3 (image) and proceeds when an image is selected.
  void validateAndProceedPhase3() {
    final hasSelectedImage = state.selectedImagePath?.isNotEmpty ?? false;

    if (hasSelectedImage) {
      nextPhase();
    }
  }

  /// Listens for notes field changes to enable/disable Phase 4 button.
  void onNotesFieldChanged() {
    final text = notesController.text;
    final shouldEnable = text.trim().isNotEmpty;

    if (state.isNotesButtonEnabled != shouldEnable) {
      final updatedEntry = state.towingEntry?.copyWith(notes: text.trim());
      emit(state.copyWith(
        isNotesButtonEnabled: shouldEnable,
        notes: text.trim(),
        towingEntry: updatedEntry,
      ));
    }
  }

  /// Proceeds past Phase 4 once notes have been entered.
  void validateAndProceedPhase4() {
    if (state.notes != null && state.notes!.isNotEmpty) {
      nextPhase();
    }
  }

  /// Confirms the towing entry and submits it (Phase 5 final action).
  Future<void> confirmTowing() async {
    emit(state.copyWith(isLoading: true, errorMessage: null, successMessage: null));

    try {
      // Simulate API call or database save
      await Future.delayed(const Duration(seconds: 2));

      final plateNumber = state.towingEntry?.plateNumber ?? 'Unknown';
      
      // TODO: Replace with actual repository call to save towing entry
      log('Towing entry confirmed: ${state.towingEntry?.toJson()}', name: 'TowCubit', level: 1000);

      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Towing confirmed for plate $plateNumber',
        isConfirmed: true,
        currentPhase: 6,
      ));
    } catch (e) {
      log('Error confirming towing: $e', name: 'TowCubit', level: 900, error: e);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to confirm towing: ${e.toString()}',
      ));
    }
  }

  /// Navigates back to patrol page from any phase including success screen.
  void backToPatrol() {
    resetState();
  }

  /// Handles back button press - navigates to patrol if needed
  void handleBackPress() {
    if (state.currentPhase == 1 || state.currentPhase == 6) {
      backToPatrol();
      getIt<DashboardCubit>().changePage(0);
    } else {
      previousPhase();
    }
  }

  /// Navigates directly to a specific phase when it falls within 1-5.
  void goToPhase(int phase) {
    if (phase >= 1 && phase <= 5) {
      emit(state.copyWith(currentPhase: phase));
    }
  }

  /// Advances to the next phase (max 5).
  void nextPhase() {
    if (state.currentPhase < 5) {
      final newPhase = state.currentPhase + 1;
      emit(state.copyWith(currentPhase: newPhase));
    }
  }

  /// Moves back one phase while clearing phase-specific selections when needed.
  void previousPhase() {
    if (state.currentPhase > 1) {
      final newPhase = state.currentPhase - 1;
      final shouldClearViolation = state.currentPhase == 2 && newPhase == 1;
      final shouldClearImage = state.currentPhase == 3 && newPhase == 2;
      final shouldClearNotes = state.currentPhase == 4 && newPhase == 3;

      // Clear notes text controller when leaving Phase 4
      if (shouldClearNotes) {
        notesController.clear();
      }

      emit(state.copyWith(
        currentPhase: newPhase,
        clearViolation: shouldClearViolation,
        clearImage: shouldClearImage,
        clearNotes: shouldClearNotes,
      ));
    }
  }

  /// Simulates submitting the tow report. Replace with real repository call later.
  Future<void> submitTowingReport() async {
    emit(state.copyWith(isLoading: true, errorMessage: null, successMessage: null));

    try {
      await Future.delayed(const Duration(seconds: 2));

      final plateNumber = state.towingEntry?.plateNumber ?? 'Unknown';
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Car with plate $plateNumber has been marked for towing',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to process tow request: ${e.toString()}',
      ));
    }
  }

  @override
  Future<void> close() {
    plateNumberController.dispose();
    notesController.dispose();
    return super.close();
  }
}
