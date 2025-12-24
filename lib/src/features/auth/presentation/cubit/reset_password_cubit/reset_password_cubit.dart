import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_my_whip/src/core/data/result.dart';
import 'package:park_my_whip/src/core/helpers/app_logger.dart';
import 'package:park_my_whip/src/core/routes/names.dart';
import 'package:park_my_whip/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:park_my_whip/src/features/auth/domain/validators.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/reset_password_cubit/reset_password_state.dart';

/// ResetPasswordCubit handles password reset flow UI logic and state management.
/// Flow: Forgot password → Reset link sent → Reset password
class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit({
    required AuthRepository authRepository,
    required Validators validators,
  })  : _authRepository = authRepository,
        _validators = validators,
        super(const ResetPasswordState());

  final AuthRepository _authRepository;
  final Validators _validators;
  
  Timer? _resendTimer;

  // Text controllers
  final TextEditingController forgotPasswordEmailController = TextEditingController();
  final TextEditingController resetPasswordController = TextEditingController();
  final TextEditingController resetConfirmPasswordController = TextEditingController();

  // ==================== Forgot Password ====================

  void onForgotPasswordFieldChanged() {
    final hasEmail = forgotPasswordEmailController.text.trim().isNotEmpty;
    if (state.isForgotPasswordButtonEnabled != hasEmail) {
      emit(state.copyWith(isForgotPasswordButtonEnabled: hasEmail));
    }
  }

  Future<void> validateForgotPasswordForm({required BuildContext context}) async {
    final emailError = _validators.emailValidator(forgotPasswordEmailController.text.trim());

    if (emailError != null) {
      emit(state.copyWith(forgotPasswordEmailError: emailError));
      return;
    }

    await _sendPasswordResetEmail(context: context);
  }

  Future<void> _sendPasswordResetEmail({required BuildContext context}) async {
    emit(state.copyWith(isLoading: true, forgotPasswordEmailError: null));

    final email = forgotPasswordEmailController.text.trim();
    final result = await _authRepository.sendPasswordResetEmail(email: email);

    switch (result) {
      case Success():
        AppLogger.auth('Password reset email sent to $email');
        emit(state.copyWith(isLoading: false));
        if (context.mounted) {
          startResendCountdown();
          Navigator.pushNamed(context, RoutesName.resetLinkSent);
        }
      case Failure(message: final message):
        AppLogger.auth('Password reset email failed: $message');
        emit(state.copyWith(isLoading: false, forgotPasswordEmailError: message));
    }
  }

  // ==================== Reset Link Sent ====================

  void startResendCountdown() {
    _resendTimer?.cancel();
    emit(state.copyWith(resendCountdownSeconds: 60, canResendEmail: false));
    
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendCountdownSeconds > 0) {
        emit(state.copyWith(resendCountdownSeconds: state.resendCountdownSeconds - 1));
      } else {
        emit(state.copyWith(canResendEmail: true));
        timer.cancel();
      }
    });
  }

  Future<void> resendPasswordResetEmail({required BuildContext context}) async {
    await _sendPasswordResetEmail(context: context);
  }

  void navigateFromResetLinkToLogin({required BuildContext context}) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  // ==================== Reset Password ====================

  void onResetPasswordFieldChanged() {
    final hasPassword = resetPasswordController.text.trim().isNotEmpty;
    final hasConfirmPassword = resetConfirmPasswordController.text.trim().isNotEmpty;
    final shouldEnable = hasPassword && hasConfirmPassword;
    
    emit(state.copyWith(
      isResetPasswordButtonEnabled: shouldEnable,
      resetPasswordFieldTrigger: state.resetPasswordFieldTrigger + 1,
    ));
  }

  Future<void> validateResetPasswordForm({required BuildContext context}) async {
    final passwordError = _validators.passwordValidator(resetPasswordController.text.trim());
    final confirmPasswordError = _validators.conformPasswordValidator(
      resetPasswordController.text.trim(),
      resetConfirmPasswordController.text.trim(),
    );

    if (passwordError != null || confirmPasswordError != null) {
      emit(state.copyWith(
        resetPasswordError: passwordError,
        resetConfirmPasswordError: confirmPasswordError,
      ));
      return;
    }

    await _submitPasswordReset(context: context);
  }

  Future<void> _submitPasswordReset({required BuildContext context}) async {
    emit(state.copyWith(
      isLoading: true,
      resetPasswordError: null,
      resetConfirmPasswordError: null,
    ));

    final newPassword = resetPasswordController.text.trim();
    final result = await _authRepository.updatePassword(newPassword: newPassword);

    switch (result) {
      case Success():
        AppLogger.auth('Password reset successful');
        emit(state.copyWith(isLoading: false));
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RoutesName.passwordResetSuccess,
            (route) => false,
          );
        }
      case Failure(message: final message):
        AppLogger.auth('Password update failed: $message');
        emit(state.copyWith(isLoading: false, resetPasswordError: message));
    }
  }

  void navigateFromResetSuccessToLogin({required BuildContext context}) {
    Navigator.pushNamedAndRemoveUntil(context, RoutesName.login, (route) => false);
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    forgotPasswordEmailController.dispose();
    resetPasswordController.dispose();
    resetConfirmPasswordController.dispose();
    return super.close();
  }
}
