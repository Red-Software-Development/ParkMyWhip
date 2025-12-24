import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_my_whip/src/core/config/config.dart';
import 'package:park_my_whip/src/core/data/result.dart';
import 'package:park_my_whip/src/core/helpers/app_logger.dart';
import 'package:park_my_whip/src/core/routes/names.dart';
import 'package:park_my_whip/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:park_my_whip/src/features/auth/domain/validators.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/sign_up_cubit/sign_up_state.dart';

/// SignUpCubit handles sign up flow UI logic and state management.
/// Flow: Sign up form → Create password → OTP verification
class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit({
    required AuthRepository authRepository,
    required Validators validators,
  })  : _authRepository = authRepository,
        _validators = validators,
        super(const SignUpState());

  final AuthRepository _authRepository;
  final Validators _validators;
  
  Timer? _otpResendTimer;

  // Text controllers
  final TextEditingController signUpNameController = TextEditingController();
  final TextEditingController signUpEmailController = TextEditingController();
  final TextEditingController createPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // ==================== Sign Up Form ====================

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
          emit(state.copyWith(
            isLoading: false,
            redirectEmail: email,
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

  // ==================== OTP Verification ====================

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

  @override
  Future<void> close() {
    _otpResendTimer?.cancel();
    signUpNameController.dispose();
    signUpEmailController.dispose();
    createPasswordController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    return super.close();
  }
}
