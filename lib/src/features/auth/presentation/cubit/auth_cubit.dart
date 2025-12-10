import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_my_whip/src/core/routes/names.dart';
import 'package:park_my_whip/src/features/auth/domain/validators.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.validators}) : super(const AuthState());

  final Validators validators;

  // Text controllers for signup form
  final TextEditingController signUpNameController = TextEditingController();
  final TextEditingController signUpEmailController = TextEditingController();
  final TextEditingController signUpPasswordController =
      TextEditingController();
  final TextEditingController signUpConfirmPasswordController =
      TextEditingController();
  // Text controllers for create password form
  final TextEditingController createPasswordController =
      TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  // Text controllers for otp form
  final TextEditingController otpController = TextEditingController();
  // Text controllers for login form
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  // Update button state when field changes
  void onSignUpFieldChanged() {
    final hasName = signUpNameController.text.trim().isNotEmpty;
    final hasEmail = signUpEmailController.text.trim().isNotEmpty;
    final shouldEnable = hasName && hasEmail;
    if (state.isSignUpButtonEnabled != shouldEnable) {
      emit(state.copyWith(isSignUpButtonEnabled: shouldEnable));
    }
  }

  // Validate signup form on continue button press
  void validateSignupForm({required BuildContext context}) {
    final nameError = validators.nameValidator(
      signUpNameController.text.trim(),
    );
    final emailError = validators.emailValidator(
      signUpEmailController.text.trim(),
    );

    emit(
      state.copyWith(signUpNameError: nameError, signUpEmailError: emailError),
    );

    // If no errors, proceed with signup logic
    if (nameError == null && emailError == null) {
      Navigator.pushNamed(context, RoutesName.enterOtpCode);
    } else {
      emit(
        state.copyWith(
          signUpNameError: nameError,
          signUpEmailError: emailError,
        ),
      );
    }
  }

  // Clear form errors
  void clearErrors() {
    emit(state.copyWith(signUpNameError: null, signUpEmailError: null));
  }

  // navigate to login page
  void navigateToLoginPage({required BuildContext context}) {
    Navigator.pushNamed(context, RoutesName.login);
  }
  //********************************************** otp ************************** */

  void onOtpFieldChanged({required String text}) {
    final hasOtp = text.length == 5;
    final shouldEnable = hasOtp;
    if (state.isOtpButtonEnabled != shouldEnable) {
      emit(state.copyWith(isOtpButtonEnabled: shouldEnable));
    }
  }

  // Validate otp form on continue button press
  void continueFromOTPPage({required BuildContext context}) {
    if (otpController.text == '12345') {
      Navigator.pushNamed(context, RoutesName.createPassword);
    } else {
      emit(state.copyWith(otpError: 'Invalid OTP'));
    }
  }
  //********************************************** create password ************************** */

  void onCreatePasswordFieldChanged() {
    final hasPassword = createPasswordController.text.trim().isNotEmpty;
    final hasConfirmPassword = confirmPasswordController.text.trim().isNotEmpty;
    final shouldEnable = hasPassword && hasConfirmPassword;
    if (state.isCreatePasswordButtonEnabled != shouldEnable) {
      emit(state.copyWith(isCreatePasswordButtonEnabled: shouldEnable));
    }
  }

  void validateCreatePasswordForm({required BuildContext context}) {
    final createPasswordError = validators.passwordValidator(
      createPasswordController.text.trim(),
    );
    final confirmPasswordError = validators.conformPasswordValidator(
      createPasswordController.text.trim(),
      confirmPasswordController.text.trim(),
    );

    // If no errors, proceed with create password logic
    if (createPasswordError == null && confirmPasswordError == null) {
      Navigator.pushNamed(context, RoutesName.login);
    } else {
      emit(
        state.copyWith(
          createPasswordError: createPasswordError,
          confirmPasswordError: confirmPasswordError,
        ),
      );
    }
  }

  //************************************ login ************************** */
  navigateToSignUpPage({required BuildContext context}) {
    Navigator.pushNamed(context, RoutesName.signup);
  }

  void onLoginFieldChanged() {
    final hasEmail = loginEmailController.text.trim().isNotEmpty;
    final hasPassword = loginPasswordController.text.trim().isNotEmpty;
    final shouldEnable = hasEmail && hasPassword;
    if (state.isLoginButtonEnabled != shouldEnable) {
      emit(state.copyWith(isLoginButtonEnabled: shouldEnable));
    }
  }

  void validateLoginForm({required BuildContext context}) {
    final emailError = validators.emailValidator(
      loginEmailController.text.trim(),
    );
    final passwordError = validators.loginPasswordValidator(
      loginPasswordController.text.trim(),
    );

    emit(
      state.copyWith(
        loginEmailError: emailError,
        loginPasswordError: passwordError,
      ),
    );

    // If no errors, proceed with login logic
    if (emailError == null && passwordError == null) {
      Navigator.pushNamed(context, RoutesName.dashboard);
    } else {
      emit(
        state.copyWith(
          loginEmailError: emailError,
          loginPasswordError: passwordError,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    signUpNameController.dispose();
    signUpEmailController.dispose();
    signUpPasswordController.dispose();
    signUpConfirmPasswordController.dispose();
    createPasswordController.dispose();
    confirmPasswordController.dispose();
    return super.close();
  }
}
