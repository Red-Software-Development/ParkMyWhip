import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/app_style/app_theme.dart';
import 'package:park_my_whip/src/core/routes/router.dart';
import 'package:park_my_whip/src/core/routes/names.dart';
import 'package:park_my_whip/src/core/services/deep_link_service.dart';

class ParkMyWhipApp extends StatefulWidget {
  const ParkMyWhipApp({super.key});

  @override
  State<ParkMyWhipApp> createState() => _ParkMyWhipAppState();
}

class _ParkMyWhipAppState extends State<ParkMyWhipApp> {
  @override
  void initState() {
    super.initState();
    // Process pending deep link after app is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkService.processPendingDeepLink();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          title: 'ParkMyWhip',
          debugShowCheckedModeBanner: false,
          navigatorKey: AppRouter.navigatorKey,
          onGenerateRoute: AppRouter.generate,
          initialRoute: RoutesName.initial,
          theme: AppTheme.lightTheme,
        );
      },
    );
  }
}
