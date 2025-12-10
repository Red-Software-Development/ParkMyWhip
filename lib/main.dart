import 'package:flutter/material.dart';
import 'src/core/config/injection.dart';
import 'park_my_whip_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupDependencyInjection();

  runApp(const ParkMyWhipApp());
}
