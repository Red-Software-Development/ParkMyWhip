import 'package:flutter/material.dart';
import 'package:park_my_whip/src/core/routes/names.dart';
import 'src/core/config/injection.dart';
import 'src/core/services/deep_link_service.dart';
import 'supabase/supabase_config.dart';
import 'park_my_whip_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseConfig.initialize();
  setupDependencyInjection();
  
  // Initialize Supabase auth state listener for password reset deep links
  DeepLinkService.initialize();

  // Determine initial route based on authentication status
  // final initialRoute = await AppRouter.getInitialRoute();

  runApp(ParkMyWhipApp(initialRoute: RoutesName.initial));
}
