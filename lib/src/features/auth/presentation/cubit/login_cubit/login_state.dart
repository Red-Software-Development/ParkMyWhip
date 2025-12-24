import 'package:equatable/equatable.dart';

class LoginState extends Equatable {
  final bool isLoading;
  final String? loginEmailError;
  final String? loginPasswordError;
  final String? loginGeneralError;
  final bool isLoginButtonEnabled;

  const LoginState({
    this.isLoading = false,
    this.loginEmailError,
    this.loginPasswordError,
    this.loginGeneralError,
    this.isLoginButtonEnabled = false,
  });

  LoginState copyWith({
    bool? isLoading,
    String? loginEmailError,
    String? loginPasswordError,
    String? loginGeneralError,
    bool clearLoginGeneralError = false,
    bool? isLoginButtonEnabled,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      loginEmailError: loginEmailError,
      loginPasswordError: loginPasswordError,
      loginGeneralError: clearLoginGeneralError ? null : (loginGeneralError ?? this.loginGeneralError),
      isLoginButtonEnabled: isLoginButtonEnabled ?? this.isLoginButtonEnabled,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    loginEmailError,
    loginPasswordError,
    loginGeneralError,
    isLoginButtonEnabled,
  ];
}
