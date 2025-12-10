import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/colors.dart';
import '../constants/text_style.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // -----------------------------------------------------------------------
      // Color Scheme
      // -----------------------------------------------------------------------
      useMaterial3: true,
      scaffoldBackgroundColor: AppColor.white,
      primaryColor: AppColor.richRed,
      colorScheme: ColorScheme.light(
        primary: AppColor.richRed,
        onPrimary: AppColor.white,
        secondary: AppColor.redBG,
        onSecondary: AppColor.richRed,
        surface: AppColor.white,
        onSurface: AppColor.grey800,
        error: AppColor.redAlerts,
        onError: AppColor.white,
      ),

      // -----------------------------------------------------------------------
      // Typography
      // -----------------------------------------------------------------------
      fontFamily: 'Urbanist', // Default font family
      textTheme: TextTheme(
        // Big Titles
        displayLarge: AppTextStyles.urbanistFont34Grey800SemiBold1_2,
        displayMedium: AppTextStyles.urbanistFont28Grey800SemiBold1,

        // Headlines
        headlineMedium: AppTextStyles.urbanistFont24Grey800SemiBold1,
        headlineSmall: AppTextStyles.urbanistFont22RichRedBold1_2,

        // Titles
        titleLarge: AppTextStyles.urbanistFont18Grey800SemiBold1_2,
        titleSmall: AppTextStyles.urbanistFont16Grey800Regular1_3,

        // Body
        bodyLarge: AppTextStyles.urbanistFont16Grey800Regular1_3,
        bodyMedium: AppTextStyles.urbanistFont14Grey700Regular1_28,
        bodySmall: AppTextStyles.urbanistFont12Grey800Regular1_64,

        // Labels / Buttons
        labelLarge: AppTextStyles.urbanistFont16WhiteRegular1_375,
      ),

      // -----------------------------------------------------------------------
      // Component Themes
      // -----------------------------------------------------------------------

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColor.white,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColor.black),
        titleTextStyle: AppTextStyles.urbanistFont18Grey800SemiBold1_2,
      ),

      // Buttons (Elevated) -> Primary Action
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.richRed,
          foregroundColor: AppColor.white,
          elevation: 0,
          textStyle: AppTextStyles.urbanistFont16WhiteRegular1_375,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColor.richRed,
        foregroundColor: AppColor.white,
      ),

      // Inputs (TextFields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColor.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        hintStyle: AppTextStyles.urbanistFont15LightGrayRegular1_33,

        // Borders
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColor.lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColor.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColor.richRed, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColor.redAlerts),
        ),
      ),

      // Dividers
      dividerTheme: DividerThemeData(
        color: AppColor.lightGray,
        thickness: 0.5,
        space: 1,
      ),
    );
  }
}
