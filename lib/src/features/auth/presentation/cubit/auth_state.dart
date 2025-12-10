import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  // sign up fields
  final bool isLoading;
  final String? errorMessage;
  final String? signUpNameError;
  final String? signUpEmailError;
  final bool isSignUpButtonEnabled;
  //otp fields
  final String? otpError;
  final bool isOtpButtonEnabled;
  // create password
  final bool isCreatePasswordButtonEnabled;
  final String? createPasswordError;
  final String? confirmPasswordError;
  // login fields
  final String? loginEmailError;
  final String? loginPasswordError;
  final String? loginGeneralError;
  final bool isLoginButtonEnabled;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.signUpNameError,
    this.signUpEmailError,
    this.isSignUpButtonEnabled = false,
    this.otpError,
    this.isOtpButtonEnabled = false,
    this.isCreatePasswordButtonEnabled = false,
    this.createPasswordError,
    this.confirmPasswordError,
    this.loginEmailError,
    this.loginPasswordError,
    this.loginGeneralError,
    this.isLoginButtonEnabled = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? signUpNameError,
    String? signUpEmailError,
    bool? isSignUpButtonEnabled,
    String? otpError,
    bool? isOtpButtonEnabled,
    String? confirmPasswordError,
    bool? isCreatePasswordButtonEnabled,
    String? createPasswordError,
    String? loginEmailError,
    String? loginPasswordError,
    String? loginGeneralError,
    bool? isLoginButtonEnabled,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      signUpNameError: signUpNameError,
      signUpEmailError: signUpEmailError,
      isSignUpButtonEnabled:
          isSignUpButtonEnabled ?? this.isSignUpButtonEnabled,
      otpError: otpError,
      isOtpButtonEnabled: isOtpButtonEnabled ?? this.isOtpButtonEnabled,
      isCreatePasswordButtonEnabled:
          isCreatePasswordButtonEnabled ?? this.isCreatePasswordButtonEnabled,
      createPasswordError: createPasswordError,
      confirmPasswordError: confirmPasswordError,
      loginEmailError: loginEmailError,
      loginPasswordError: loginPasswordError,
      isLoginButtonEnabled: isLoginButtonEnabled ?? this.isLoginButtonEnabled,
      loginGeneralError: loginGeneralError,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    signUpNameError,
    signUpEmailError,
    isSignUpButtonEnabled,
    otpError,
    isOtpButtonEnabled,
    isCreatePasswordButtonEnabled,
    createPasswordError,
    confirmPasswordError,
    loginEmailError,
    loginPasswordError,
    loginGeneralError,
    isLoginButtonEnabled,
  ];
}
