import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'src/core/app_style/app_theme.dart';
import 'src/core/routes/router.dart';
import 'src/core/routes/names.dart';

class ParkMyWhipApp extends StatelessWidget {
  const ParkMyWhipApp({super.key});

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
