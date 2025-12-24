import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/data/result.dart';
import 'package:park_my_whip/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/sign_up_cubit/sign_up_cubit.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/login_cubit/login_cubit.dart';
import 'package:park_my_whip/src/features/auth/presentation/cubit/reset_password_cubit/reset_password_cubit.dart';
import 'package:park_my_whip/src/features/auth/presentation/pages/reset_password_pages/forgot_password_page.dart';
import 'package:park_my_whip/src/features/auth/presentation/pages/login_page.dart';
import 'package:park_my_whip/src/features/auth/presentation/pages/reset_password_pages/password_reset_success_page.dart';
import 'package:park_my_whip/src/features/auth/presentation/pages/reset_password_pages/reset_link_error_page.dart';
import 'package:park_my_whip/src/features/auth/presentation/pages/reset_password_pages/reset_link_sent_page.dart';
import 'package:park_my_whip/src/features/auth/presentation/pages/reset_password_pages/reset_password_page.dart';
import 'package:park_my_whip/src/features/auth/presentation/pages/sign_up_pages/create_password_page.dart';
import 'package:park_my_whip/src/features/auth/presentation/pages/sign_up_pages/enter_otp_code_page.dart';
import 'package:park_my_whip/src/features/auth/presentation/pages/sign_up_pages/sign_up_page.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/dashboard_cubit/dashboard_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/pages/dashboard_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'names.dart';

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  /// Determines the initial route based on user authentication status
  /// Returns dashboard route if user is signed in, otherwise login route
  static Future<String> getInitialRoute() async {
    try {
      // Check if user has active Supabase session
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        // Verify user data exists in cache via AuthRepository
        final authRepository = getIt<AuthRepository>();
        final result = await authRepository.getCachedUser();
        if (result case Success(:final data)) {
          if (data != null && data.emailVerified) {
            return RoutesName.dashboard;
          }
        }
      }
      return RoutesName.login;
    } catch (e) {
      // On error, default to login page
      return RoutesName.login;
    }
  }

  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.signup:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<SignUpCubit>(),
            child: const SignUpPage(),
          ),
        );

      case RoutesName.enterOtpCode:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<SignUpCubit>(),
            child: const EnterOtpCodePage(),
          ),
        );
      case RoutesName.createPassword:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<SignUpCubit>(),
            child: const CreatePasswordPage(),
          ),
        );
      case RoutesName.initial:
      case RoutesName.login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<LoginCubit>(),
            child: const LoginPage(),
          ),
        );
      case RoutesName.dashboard:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<DashboardCubit>(),
            child: const DashboardPage(),
          ),
        );
      case RoutesName.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<ResetPasswordCubit>(),
            child: const ForgotPasswordPage(),
          ),
        );
      case RoutesName.resetLinkSent:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<ResetPasswordCubit>(),
            child: const ResetLinkSentPage(),
          ),
        );
      case RoutesName.resetPassword:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<ResetPasswordCubit>(),
            child: const ResetPasswordPage(),
          ),
        );
      case RoutesName.resetLinkError:
        return MaterialPageRoute(
          builder: (_) => const ResetLinkErrorPage(),
        );
      case RoutesName.passwordResetSuccess:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<ResetPasswordCubit>(),
            child: const PasswordResetSuccessPage(),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
