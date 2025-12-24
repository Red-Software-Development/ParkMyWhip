import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_my_whip/src/core/config/config.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/data/result.dart';
import 'package:park_my_whip/src/core/helpers/app_logger.dart';
import 'package:park_my_whip/src/core/models/email_check_result.dart';
import 'package:park_my_whip/src/core/routes/names.dart';
import 'package:park_my_whip/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:park_my_whip/src/features/auth/domain/validators.dart';
import 'auth_state.dart' as app_auth;

/// AuthCubit handles authentication UI logic and state management.
/// It delegates all data operations to AuthRepository (Single Responsibility).
class AuthCubit extends Cubit<app_auth.AuthState> {
  AuthCubit({
    required AuthRepository authRepository,
    required Validators validators,
  })  : _authRepository = authRepository,
        _validators = validators,
        super(const app_auth.AuthState());

  final AuthRepository _authRepository;
  final Validators _validators;
  
  // Timers for resend countdowns
  Timer? _resendTimer;
  Timer? _otpResendTimer;

  // Text controllers for signup form
  final TextEditingController signUpNameController = TextEditingController();
  final TextEditingController signUpEmailController = TextEditingController();
  final TextEditingController signUpPasswordController = TextEditingController();
  final TextEditingController signUpConfirmPasswordController = TextEditingController();
  
  // Text controllers for create password form
  final TextEditingController createPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  // Text controllers for otp form
  final TextEditingController otpController = TextEditingController();
  
  // Text controllers for login form
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  
  // Text controllers for forgot password form
  final TextEditingController forgotPasswordEmailController = TextEditingController();
  
  // Text controllers for reset password form
  final TextEditingController resetPasswordController = TextEditingController();
  final TextEditingController resetConfirmPasswordController = TextEditingController();

  // ==================== Sign Up ====================

  void onSignUpFieldChanged() {
    final hasName = signUpNameController.text.trim().isNotEmpty;
    final hasEmail = signUpEmailController.text.trim().isNotEmpty;
    final shouldEnable = hasName && hasEmail;
    if (state.isSignUpButtonEnabled != shouldEnable) {
      emit(state.copyWith(isSignUpButtonEnabled: shouldEnable));
    }
  }

  Future<void> validateSignupForm({required BuildContext context}) async {
    final nameError = _validators.nameValidator(signUpNameController.text.trim());
    final emailError = _validators.emailValidator(signUpEmailController.text.trim());

    if (nameError != null || emailError != null) {
      emit(state.copyWith(
        signUpNameError: nameError,
        signUpEmailError: emailError,
      ));
      return;
    }

    emit(state.copyWith(
      isLoading: true,
      signUpNameError: null,
      signUpEmailError: null,
      errorMessage: null,
    ));

    // Check signup eligibility (calls RPC that grants app access if user exists)
    final email = signUpEmailController.text.trim();
    final result = await _authRepository.checkSignupEligibility(
      email: email,
      appId: AppConfig.appId,
    );

    switch (result) {
      case Success(:final data):
        if (data.canSignup) {
          // New user - can proceed with signup
          AppLogger.auth('New user - proceeding with signup');
          emit(state.copyWith(isLoading: false));
          if (context.mounted) {
            Navigator.pushNamed(context, RoutesName.createPassword);
          }
        } else {
          // Existing user - app access was granted by RPC, redirect to login
          AppLogger.auth('Existing user - app access granted, redirecting to login');
          // Pre-fill login email
          loginEmailController.text = email;
          // Navigate to login with message
          emit(state.copyWith(
            isLoading: false,
            redirectEmail: email,
            loginGeneralError: 'This account now exists. Please sign in to access this app.',
          ));
          if (context.mounted) {
            Navigator.pushNamed(context, RoutesName.login);
          }
        }
      case Failure(:final message):
        AppLogger.auth('Signup eligibility check failed: $message');
        emit(state.copyWith(isLoading: false, errorMessage: message));
    }
  }

  void clearErrors() {
    emit(state.copyWith(signUpNameError: null, signUpEmailError: null));
  }

  void navigateToLoginPage({required BuildContext context}) {
    Navigator.pushNamed(context, RoutesName.login);
  }

  // ==================== OTP ====================

  void onOtpFieldChanged({required String text}) {
    final shouldEnable = text.length == 6;
    if (state.isOtpButtonEnabled != shouldEnable) {
      emit(state.copyWith(isOtpButtonEnabled: shouldEnable));
    }
  }

  Future<void> continueFromOTPPage({required BuildContext context}) async {
    final otp = otpController.text.trim();
    
    if (otp.length != 6) {
      emit(state.copyWith(otpError: 'Please enter a valid 6-digit OTP'));
      return;
    }

    emit(state.copyWith(isLoading: true, otpError: null));

    final email = signUpEmailController.text.trim();
    final result = await _authRepository.verifyOtpAndCompleteSignup(
      email: email,
      otp: otp,
    );

    switch (result) {
      case Success(:final data):
        AppLogger.auth('Signup completed successfully. User: ${data.id}');
        emit(state.copyWith(isLoading: false));
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, RoutesName.dashboard);
        }
      case Failure(:final message):
        AppLogger.auth('OTP verification failed: $message');
        emit(state.copyWith(isLoading: false, otpError: message));
    }
  }

  // ==================== Create Password ====================

  void onCreatePasswordFieldChanged() {
    final hasPassword = createPasswordController.text.trim().isNotEmpty;
    final hasConfirmPassword = confirmPasswordController.text.trim().isNotEmpty;
    final shouldEnable = hasPassword && hasConfirmPassword;
    
    emit(state.copyWith(
      isCreatePasswordButtonEnabled: shouldEnable,
      createPasswordFieldTrigger: state.createPasswordFieldTrigger + 1,
    ));
  }

  Future<void> validateCreatePasswordForm({required BuildContext context}) async {
    final createPasswordError = _validators.passwordValidator(
      createPasswordController.text.trim(),
    );
    final confirmPasswordError = _validators.conformPasswordValidator(
      createPasswordController.text.trim(),
      confirmPasswordController.text.trim(),
    );

    if (createPasswordError != null || confirmPasswordError != null) {
      emit(state.copyWith(
        createPasswordError: createPasswordError,
        confirmPasswordError: confirmPasswordError,
      ));
      return;
    }

    await _createAccount(context: context);
  }

  Future<void> _createAccount({required BuildContext context}) async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      createPasswordError: null,
      confirmPasswordError: null,
    ));

    final email = signUpEmailController.text.trim();
    final password = createPasswordController.text.trim();
    final fullName = signUpNameController.text.trim();

    final result = await _authRepository.createAccount(
      email: email,
      password: password,
      fullName: fullName,
    );

    switch (result) {
      case Success():
        AppLogger.auth('Account created successfully');
        emit(state.copyWith(isLoading: false));
        if (context.mounted) {
          Navigator.pushNamed(context, RoutesName.enterOtpCode);
        }
      case Failure(message: final message):
        AppLogger.auth('Create account failed: $message');
        emit(state.copyWith(isLoading: false, errorMessage: message));
    }
  }

  void startOtpResendCountdown() {
    _otpResendTimer?.cancel();
    emit(state.copyWith(otpResendCountdownSeconds: 60, canResendOtp: false));
    
    _otpResendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.otpResendCountdownSeconds > 0) {
        emit(state.copyWith(otpResendCountdownSeconds: state.otpResendCountdownSeconds - 1));
      } else {
        emit(state.copyWith(canResendOtp: true));
        timer.cancel();
      }
    });
  }

  Future<void> sendOtpOnPageLoad({required BuildContext context}) async {
    emit(state.copyWith(isLoading: true, otpError: null));

    final email = signUpEmailController.text.trim();
    final result = await _authRepository.sendOtpForEmailVerification(email: email);

    switch (result) {
      case Success():
        AppLogger.auth('OTP sent to $email');
        startOtpResendCountdown();
        emit(state.copyWith(isLoading: false));
      case Failure(message: final message):
        AppLogger.auth('Send OTP failed: $message');
        emit(state.copyWith(isLoading: false, otpError: message));
    }
  }

  Future<void> resendOtp({required BuildContext context}) async {
    emit(state.copyWith(isLoading: true, otpError: null));

    final email = signUpEmailController.text.trim();
    final result = await _authRepository.sendOtpForEmailVerification(email: email);

    switch (result) {
      case Success():
        AppLogger.auth('OTP resent to $email');
        startOtpResendCountdown();
        emit(state.copyWith(isLoading: false));
      case Failure(message: final message):
        AppLogger.auth('Resend OTP failed: $message');
        emit(state.copyWith(isLoading: false, otpError: message));
    }
  }

  // ==================== Login ====================

  void navigateToSignUpPage({required BuildContext context}) {
    Navigator.pushNamed(context, RoutesName.signup);
  }

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

  // ==================== Forgot Password ====================

  void navigateToForgotPasswordPage({required BuildContext context}) {
    Navigator.pushNamed(context, RoutesName.forgotPassword);
  }

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

  void navigateFromResetSuccessToLogin({required BuildContext context}) {
    Navigator.pushNamedAndRemoveUntil(context, RoutesName.login, (route) => false);
  }

  static String formatCountdownTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    _otpResendTimer?.cancel();
    signUpNameController.dispose();
    signUpEmailController.dispose();
    signUpPasswordController.dispose();
    signUpConfirmPasswordController.dispose();
    createPasswordController.dispose();
    confirmPasswordController.dispose();
    loginEmailController.dispose();
    loginPasswordController.dispose();
    forgotPasswordEmailController.dispose();
    resetPasswordController.dispose();
    resetConfirmPasswordController.dispose();
    return super.close();
  }
}
