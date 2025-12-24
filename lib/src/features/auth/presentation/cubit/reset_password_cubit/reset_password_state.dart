import 'package:equatable/equatable.dart';

class ResetPasswordState extends Equatable {
  final bool isLoading;
  
  // Forgot password fields
  final String? forgotPasswordEmailError;
  final bool isForgotPasswordButtonEnabled;
  
  // Reset link sent (timer state)
  final int resendCountdownSeconds;
  final bool canResendEmail;
  
  // Reset password fields
  final String? resetPasswordError;
  final String? resetConfirmPasswordError;
  final bool isResetPasswordButtonEnabled;
  final int resetPasswordFieldTrigger;

  const ResetPasswordState({
    this.isLoading = false,
    this.forgotPasswordEmailError,
    this.isForgotPasswordButtonEnabled = false,
    this.resendCountdownSeconds = 60,
    this.canResendEmail = false,
    this.resetPasswordError,
    this.resetConfirmPasswordError,
    this.isResetPasswordButtonEnabled = false,
    this.resetPasswordFieldTrigger = 0,
  });

  ResetPasswordState copyWith({
    bool? isLoading,
    String? forgotPasswordEmailError,
    bool? isForgotPasswordButtonEnabled,
    int? resendCountdownSeconds,
    bool? canResendEmail,
    String? resetPasswordError,
    String? resetConfirmPasswordError,
    bool? isResetPasswordButtonEnabled,
    int? resetPasswordFieldTrigger,
  }) {
    return ResetPasswordState(
      isLoading: isLoading ?? this.isLoading,
      forgotPasswordEmailError: forgotPasswordEmailError,
      isForgotPasswordButtonEnabled: isForgotPasswordButtonEnabled ?? this.isForgotPasswordButtonEnabled,
      resendCountdownSeconds: resendCountdownSeconds ?? this.resendCountdownSeconds,
      canResendEmail: canResendEmail ?? this.canResendEmail,
      resetPasswordError: resetPasswordError,
      resetConfirmPasswordError: resetConfirmPasswordError,
      isResetPasswordButtonEnabled: isResetPasswordButtonEnabled ?? this.isResetPasswordButtonEnabled,
      resetPasswordFieldTrigger: resetPasswordFieldTrigger ?? this.resetPasswordFieldTrigger,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    forgotPasswordEmailError,
    isForgotPasswordButtonEnabled,
    resendCountdownSeconds,
    canResendEmail,
    resetPasswordError,
    resetConfirmPasswordError,
    isResetPasswordButtonEnabled,
    resetPasswordFieldTrigger,
  ];
}
