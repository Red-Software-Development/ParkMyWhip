import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_my_whip/src/core/data/result.dart';
import 'package:park_my_whip/src/core/helpers/app_logger.dart';
import 'package:park_my_whip/src/core/routes/names.dart';
import 'package:park_my_whip/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:park_my_whip/src/features/auth/domain/validators.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/login_cubit/login_state.dart';

/// LoginCubit handles login UI logic and state management.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required AuthRepository authRepository,
    required Validators validators,
  })  : _authRepository = authRepository,
        _validators = validators,
        super(const LoginState());

  final AuthRepository _authRepository;
  final Validators _validators;

  // Text controllers
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  // ==================== Login ====================

  void onLoginFieldChanged() {
    final hasEmail = loginEmailController.text.trim().isNotEmpty;
    final hasPassword = loginPasswordController.text.trim().isNotEmpty;
    final shouldEnable = hasEmail && hasPassword;
    
    // Clear old errors when user starts typing
    if (state.loginGeneralError != null || 
        state.loginEmailError != null || 
        state.loginPasswordError != null) {
      emit(state.copyWith(
        clearLoginGeneralError: true,
        loginEmailError: null,
        loginPasswordError: null,
      ));
    }
    
    if (state.isLoginButtonEnabled != shouldEnable) {
      emit(state.copyWith(isLoginButtonEnabled: shouldEnable));
    }
  }

  Future<void> validateLoginForm({required BuildContext context}) async {
    final emailError = _validators.emailValidator(loginEmailController.text.trim());
    final passwordError = _validators.loginPasswordValidator(loginPasswordController.text.trim());

    if (emailError != null || passwordError != null) {
      emit(state.copyWith(
        loginEmailError: emailError,
        loginPasswordError: passwordError,
      ));
      return;
    }

    await _loginWithSupabase(context: context);
  }

  Future<void> _loginWithSupabase({required BuildContext context}) async {
    emit(state.copyWith(
      isLoading: true,
      clearLoginGeneralError: true,
      loginEmailError: null,
      loginPasswordError: null,
    ));

    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text.trim();

    final result = await _authRepository.login(email: email, password: password);

    switch (result) {
      case Success(:final data):
        AppLogger.auth('User logged in successfully: ${data.id}');
        emit(state.copyWith(isLoading: false));
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, RoutesName.dashboard);
        }
      case Failure(:final message):
        AppLogger.auth('Login failed: $message');
        emit(state.copyWith(isLoading: false, loginGeneralError: message));
    }
  }

  // ==================== Navigation ====================

  void navigateToSignUpPage({required BuildContext context}) {
    Navigator.pushNamed(context, RoutesName.signup);
  }

  void navigateToForgotPasswordPage({required BuildContext context}) {
    Navigator.pushNamed(context, RoutesName.forgotPassword);
  }

  /// Pre-fills email field (used when redirected from sign up)
  void prefillEmail(String email) {
    loginEmailController.text = email;
    emit(state.copyWith(
      loginGeneralError: 'This account now exists. Please sign in to access this app.',
    ));
  }

  @override
  Future<void> close() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    return super.close();
  }
}
