import 'package:flutter/material.dart';
import 'src/core/config/injection.dart';
import 'src/core/services/deep_link_service.dart';
import 'supabase/supabase_config.dart';
import 'park_my_whip_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseConfig.initialize();
  setupDependencyInjection();
  await DeepLinkService.initialize();

  runApp(const ParkMyWhipApp());
}
