import 'package:equatable/equatable.dart';

class SignUpState extends Equatable {
  // Loading state
  final bool isLoading;
  
  // Sign up form fields
  final String? signUpNameError;
  final String? signUpEmailError;
  final bool isSignUpButtonEnabled;
  final String? errorMessage;
  final String? redirectEmail;
  
  // Create password fields
  final bool isCreatePasswordButtonEnabled;
  final String? createPasswordError;
  final String? confirmPasswordError;
  final int createPasswordFieldTrigger;
  
  // OTP fields
  final String? otpError;
  final bool isOtpButtonEnabled;
  final int otpResendCountdownSeconds;
  final bool canResendOtp;

  const SignUpState({
    this.isLoading = false,
    this.signUpNameError,
    this.signUpEmailError,
    this.isSignUpButtonEnabled = false,
    this.errorMessage,
    this.redirectEmail,
    this.isCreatePasswordButtonEnabled = false,
    this.createPasswordError,
    this.confirmPasswordError,
    this.createPasswordFieldTrigger = 0,
    this.otpError,
    this.isOtpButtonEnabled = false,
    this.otpResendCountdownSeconds = 60,
    this.canResendOtp = false,
  });

  SignUpState copyWith({
    bool? isLoading,
    String? signUpNameError,
    String? signUpEmailError,
    bool? isSignUpButtonEnabled,
    String? errorMessage,
    String? redirectEmail,
    bool clearRedirectEmail = false,
    bool? isCreatePasswordButtonEnabled,
    String? createPasswordError,
    String? confirmPasswordError,
    int? createPasswordFieldTrigger,
    String? otpError,
    bool? isOtpButtonEnabled,
    int? otpResendCountdownSeconds,
    bool? canResendOtp,
  }) {
    return SignUpState(
      isLoading: isLoading ?? this.isLoading,
      signUpNameError: signUpNameError,
      signUpEmailError: signUpEmailError,
      isSignUpButtonEnabled: isSignUpButtonEnabled ?? this.isSignUpButtonEnabled,
      errorMessage: errorMessage,
      redirectEmail: clearRedirectEmail ? null : (redirectEmail ?? this.redirectEmail),
      isCreatePasswordButtonEnabled: isCreatePasswordButtonEnabled ?? this.isCreatePasswordButtonEnabled,
      createPasswordError: createPasswordError,
      confirmPasswordError: confirmPasswordError,
      createPasswordFieldTrigger: createPasswordFieldTrigger ?? this.createPasswordFieldTrigger,
      otpError: otpError,
      isOtpButtonEnabled: isOtpButtonEnabled ?? this.isOtpButtonEnabled,
      otpResendCountdownSeconds: otpResendCountdownSeconds ?? this.otpResendCountdownSeconds,
      canResendOtp: canResendOtp ?? this.canResendOtp,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    signUpNameError,
    signUpEmailError,
    isSignUpButtonEnabled,
    errorMessage,
    redirectEmail,
    isCreatePasswordButtonEnabled,
    createPasswordError,
    confirmPasswordError,
    createPasswordFieldTrigger,
    otpError,
    isOtpButtonEnabled,
    otpResendCountdownSeconds,
    canResendOtp,
  ];
}
