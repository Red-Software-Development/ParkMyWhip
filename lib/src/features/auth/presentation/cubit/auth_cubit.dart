import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_my_whip/src/core/networking/network_exceptions.dart';
import 'package:park_my_whip/src/core/routes/names.dart';
import 'package:park_my_whip/src/core/services/supabase_user_service.dart';
import 'package:park_my_whip/src/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:park_my_whip/src/features/auth/domain/validators.dart';
import 'auth_state.dart' as app_auth;

class AuthCubit extends Cubit<app_auth.AuthState> {
  AuthCubit({
    required this.validators,
    required this.supabaseUserService,
    required this.authRemoteDataSource,
  }) : super(const app_auth.AuthState());

  final Validators validators;
  final SupabaseUserService supabaseUserService;
  final AuthRemoteDataSource authRemoteDataSource;
  
  // Timer for reset link resend countdown
  Timer? _resendTimer;

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
  // Text controllers for forgot password form
  final TextEditingController forgotPasswordEmailController = TextEditingController();
  // Text controllers for reset password form
  final TextEditingController resetPasswordController = TextEditingController();
  final TextEditingController resetConfirmPasswordController = TextEditingController();

  // Update button state when field changes
  void onSignUpFieldChanged() {
    final hasName = signUpNameController.text.trim().isNotEmpty;
    final hasEmail = signUpEmailController.text.trim().isNotEmpty;
    final shouldEnable = hasName && hasEmail;
    if (state.isSignUpButtonEnabled != shouldEnable) {
      emit(state.copyWith(isSignUpButtonEnabled: shouldEnable));
    }
  }

  // Validate signup form on continue button press (Step 1: Name + Email → Navigate to Create Password)
  Future<void> validateSignupForm({required BuildContext context}) async {
    final nameError = validators.nameValidator(
      signUpNameController.text.trim(),
    );
    final emailError = validators.emailValidator(
      signUpEmailController.text.trim(),
    );

    if (nameError != null || emailError != null) {
      emit(
        state.copyWith(
          signUpNameError: nameError,
          signUpEmailError: emailError,
        ),
      );
      return;
    }

    // If no errors, navigate to create password page
    emit(state.copyWith(
      signUpNameError: null,
      signUpEmailError: null,
      errorMessage: null,
    ));
    
    if (context.mounted) {
      Navigator.pushNamed(context, RoutesName.createPassword);
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
    final hasOtp = text.length == 6;
    final shouldEnable = hasOtp;
    if (state.isOtpButtonEnabled != shouldEnable) {
      emit(state.copyWith(isOtpButtonEnabled: shouldEnable));
    }
  }

  // Validate otp form on continue button press (Step 3: Verify OTP → Navigate to Dashboard)
  Future<void> continueFromOTPPage({required BuildContext context}) async {
    final otp = otpController.text.trim();
    
    if (otp.length != 6) {
      emit(state.copyWith(otpError: 'Please enter a valid 6-digit OTP'));
      return;
    }

    try {
      // Clear previous errors and show loading
      emit(state.copyWith(
        isLoading: true,
        otpError: null,
      ));

      final email = signUpEmailController.text.trim();

      // Call data source to verify OTP and complete signup
      final supabaseUser = await authRemoteDataSource.verifyOtpAndCompleteSignup(
        email: email,
        otp: otp,
      );

      log('Signup completed successfully. User: ${supabaseUser.id}', name: 'AuthCubit', level: 1000);

      // Save user data to local storage
      await supabaseUserService.cacheUser(supabaseUser);

      emit(state.copyWith(isLoading: false));

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, RoutesName.dashboard);
      }
    } catch (e) {
      log('OTP verification error: $e', name: 'AuthCubit', level: 900, error: e);
      final errorMessage = NetworkExceptions.getSupabaseExceptionMessage(e);
      emit(state.copyWith(
        isLoading: false,
        otpError: errorMessage,
      ));
    }
  }
  //********************************************** create password ************************** */

  void onCreatePasswordFieldChanged() {
    final hasPassword = createPasswordController.text.trim().isNotEmpty;
    final hasConfirmPassword = confirmPasswordController.text.trim().isNotEmpty;
    final shouldEnable = hasPassword && hasConfirmPassword;
    
    // Update button state and trigger rebuild for validation rules
    if (state.isCreatePasswordButtonEnabled != shouldEnable) {
      emit(state.copyWith(
        isCreatePasswordButtonEnabled: shouldEnable,
        createPasswordFieldTrigger: state.createPasswordFieldTrigger + 1,
      ));
    } else {
      // Trigger rebuild for validation rules even if button state unchanged
      emit(state.copyWith(
        createPasswordFieldTrigger: state.createPasswordFieldTrigger + 1,
      ));
    }
  }

  Future<void> validateCreatePasswordForm({required BuildContext context}) async {
    final createPasswordError = validators.passwordValidator(
      createPasswordController.text.trim(),
    );
    final confirmPasswordError = validators.conformPasswordValidator(
      createPasswordController.text.trim(),
      confirmPasswordController.text.trim(),
    );

    if (createPasswordError != null || confirmPasswordError != null) {
      emit(
        state.copyWith(
          createPasswordError: createPasswordError,
          confirmPasswordError: confirmPasswordError,
        ),
      );
      return;
    }

    // If no errors, create account in Supabase (without sending OTP yet)
    await createAccount(context: context);
  }

  Future<void> createAccount({required BuildContext context}) async {
    try {
      // Clear previous errors and show loading
      emit(state.copyWith(
        isLoading: true,
        errorMessage: null,
        createPasswordError: null,
        confirmPasswordError: null,
      ));

      final email = signUpEmailController.text.trim();
      final password = createPasswordController.text.trim();
      final fullName = signUpNameController.text.trim();

      // Call data source to create account (without OTP)
      await authRemoteDataSource.createAccount(
        email: email,
        password: password,
        fullName: fullName,
      );

      log('Account created successfully', name: 'AuthCubit', level: 1000);

      // Navigate to OTP page (OTP will be sent when page loads)
      emit(state.copyWith(isLoading: false));
      if (context.mounted) {
        Navigator.pushNamed(context, RoutesName.enterOtpCode);
      }
    } catch (e) {
      log('Create account error: $e', name: 'AuthCubit', level: 900, error: e);
      final errorMessage = NetworkExceptions.getSupabaseExceptionMessage(e);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      ));
    }
  }

  // Send OTP for email verification (called when OTP page loads)
  Future<void> sendOtpForEmailVerification() async {
    try {
      final email = signUpEmailController.text.trim();

      // Call data source to send OTP
      await authRemoteDataSource.sendOtpForEmailVerification(
        email: email,
      );

      log('OTP sent to $email', name: 'AuthCubit', level: 1000);
    } catch (e) {
      log('Send OTP error: $e', name: 'AuthCubit', level: 900, error: e);
      // Don't emit error state here, let user try to verify anyway
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

  Future<void> validateLoginForm({required BuildContext context}) async {
    final emailError = validators.emailValidator(
      loginEmailController.text.trim(),
    );
    final passwordError = validators.loginPasswordValidator(
      loginPasswordController.text.trim(),
    );

    if (emailError != null || passwordError != null) {
      emit(
        state.copyWith(
          loginEmailError: emailError,
          loginPasswordError: passwordError,
        ),
      );
      return;
    }

    // If no validation errors, proceed with Supabase login
    await loginWithSupabase(context: context);
  }

  Future<void> loginWithSupabase({required BuildContext context}) async {
    try {
      // Clear previous errors and show loading
      emit(state.copyWith(
        isLoading: true,
        loginGeneralError: null,
        loginEmailError: null,
        loginPasswordError: null,
      ));

      final email = loginEmailController.text.trim();
      final password = loginPasswordController.text.trim();

      // Call data source to handle all backend logic
      final supabaseUser = await authRemoteDataSource.loginWithEmailAndPassword(
        email: email,
        password: password,
      );

      log('User logged in successfully: ${supabaseUser.id}', name: 'AuthCubit', level: 1000);

      // Save user data to local storage
      await supabaseUserService.cacheUser(supabaseUser);

      // Navigate to dashboard
      emit(state.copyWith(isLoading: false));
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, RoutesName.dashboard);
      }
    } catch (e) {
      log('Login error: $e', name: 'AuthCubit', level: 900, error: e);
      final errorMessage = NetworkExceptions.getSupabaseExceptionMessage(e);
      emit(state.copyWith(
        isLoading: false,
        loginGeneralError: errorMessage,
      ));
    }
  }

  //************************************ forgot password ************************** */
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
    final emailError = validators.emailValidator(
      forgotPasswordEmailController.text.trim(),
    );

    if (emailError != null) {
      emit(state.copyWith(forgotPasswordEmailError: emailError));
      return;
    }

    await sendPasswordResetEmail(context: context);
  }

  Future<void> sendPasswordResetEmail({required BuildContext context}) async {
    try {
      emit(state.copyWith(
        isLoading: true,
        forgotPasswordEmailError: null,
      ));

      final email = forgotPasswordEmailController.text.trim();
      await authRemoteDataSource.sendPasswordResetEmail(email: email);

      log('Password reset email sent to $email', name: 'AuthCubit', level: 800);
      emit(state.copyWith(isLoading: false));

      if (context.mounted) {
        // Start countdown timer when navigating to success page
        startResendCountdown();
        Navigator.pushNamed(context, RoutesName.resetLinkSent);
      }
    } catch (e) {
      log('Password reset email error: $e', name: 'AuthCubit', level: 900, error: e);
      final errorMessage = NetworkExceptions.getSupabaseExceptionMessage(e);
      emit(state.copyWith(
        isLoading: false,
        forgotPasswordEmailError: errorMessage,
      ));
    }
  }

  // Start 60-second countdown for resend button
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

  // Resend password reset email
  Future<void> resendPasswordResetEmail({required BuildContext context}) async {
    await sendPasswordResetEmail(context: context);
  }

  // Navigate from reset link sent page back to login
  void navigateFromResetLinkToLogin({required BuildContext context}) {
    // Pop back to login, removing forgot password and reset link sent pages
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  // Navigate from password reset success page to login
  void navigateFromResetSuccessToLogin({required BuildContext context}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      RoutesName.login,
      (route) => false,
    );
  }

  // Format countdown seconds to MM:SS format
  static String formatCountdownTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  //************************************ reset password ************************** */
  void onResetPasswordFieldChanged() {
    final hasPassword = resetPasswordController.text.trim().isNotEmpty;
    final hasConfirmPassword = resetConfirmPasswordController.text.trim().isNotEmpty;
    final shouldEnable = hasPassword && hasConfirmPassword;
    
    // Only update button state and trigger rebuild for validation rules
    // DON'T clear errors - they should persist until next validation
    if (state.isResetPasswordButtonEnabled != shouldEnable) {
      emit(state.copyWith(
        isResetPasswordButtonEnabled: shouldEnable,
        resetPasswordFieldTrigger: state.resetPasswordFieldTrigger + 1,
      ));
    } else {
      // Trigger rebuild for validation rules even if button state unchanged
      emit(state.copyWith(
        resetPasswordFieldTrigger: state.resetPasswordFieldTrigger + 1,
      ));
    }
  }

  Future<void> validateResetPasswordForm({required BuildContext context}) async {
    final passwordError = validators.passwordValidator(
      resetPasswordController.text.trim(),
    );
    final confirmPasswordError = validators.conformPasswordValidator(
      resetPasswordController.text.trim(),
      resetConfirmPasswordController.text.trim(),
    );

    if (passwordError != null || confirmPasswordError != null) {
      emit(
        state.copyWith(
          resetPasswordError: passwordError,
          resetConfirmPasswordError: confirmPasswordError,
        ),
      );
      return;
    }

    // Submit new password to Supabase
    await submitPasswordReset(context: context);
  }

  Future<void> submitPasswordReset({required BuildContext context}) async {
    try {
      emit(state.copyWith(
        isLoading: true,
        resetPasswordError: null,
        resetConfirmPasswordError: null,
      ));

      final newPassword = resetPasswordController.text.trim();
      
      // Call data source to update password
      await authRemoteDataSource.updatePassword(newPassword: newPassword);

      log('Password reset successful', name: 'AuthCubit', level: 1000);
      emit(state.copyWith(isLoading: false));

      if (context.mounted) {
        // Navigate to success page after successful password reset
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.passwordResetSuccess,
          (route) => false,
        );
      }
    } catch (e) {
      log('Password update error: $e', name: 'AuthCubit', level: 900, error: e);
      final errorMessage = NetworkExceptions.getSupabaseExceptionMessage(e);
      emit(state.copyWith(
        isLoading: false,
        resetPasswordError: errorMessage,
      ));
    }
  }


  @override
  Future<void> close() {
    _resendTimer?.cancel();
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
