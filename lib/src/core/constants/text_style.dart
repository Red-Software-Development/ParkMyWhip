import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class FontWeightHelper {
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

class AppTextStyles {
  static TextStyle urbanistFont34Grey800SemiBold1_2 = GoogleFonts.urbanist(
    fontSize: 34.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColor.grey800,
    height: 41 / 34, // 1.2
    letterSpacing: 0.37,
  );

  static TextStyle urbanistFont14Gray800Regular1_4 = GoogleFonts.urbanist(
    fontSize: 14.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColor.grey800, // #48484A
    height: 20 / 14, // ~1.42
    letterSpacing: -0.24,
  );

  static TextStyle urbanistFont16Grey800Opacity40Regular1_3 =
      GoogleFonts.urbanist(
        fontSize: 16.sp,
        fontWeight: FontWeightHelper.regular,
        color: AppColor.grey800.withValues(alpha: 0.4),
        height: 22 / 16, // 1.375
        letterSpacing: 0,
      );

  static TextStyle urbanistFont16Grey800Regular1_3 = GoogleFonts.urbanist(
    fontSize: 16.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColor.grey800,
    height: 22 / 16, // 1.375
    letterSpacing: 0,
  );

  static TextStyle urbanistFont22RichRedBold1_2 = GoogleFonts.urbanist(
    fontSize: 22.sp,
    fontWeight: FontWeightHelper.bold,
    color: AppColor.richRed, // #C8102E
    height: 1.2, // 120%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont18Grey800SemiBold1_2 = GoogleFonts.urbanist(
    fontSize: 18.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColor.grey800,
    height: 1.2, // 120%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont24Grey800SemiBold1 = GoogleFonts.urbanist(
    fontSize: 24.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColor.grey800,
    height: 1.0, // 100%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont11Gray30Regular1_24 = GoogleFonts.urbanist(
    fontSize: 11.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColor.gray30, // #6B7271
    height: 1.24, // 124%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont16BlackSemiBold1_3 = GoogleFonts.urbanist(
    fontSize: 16.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColor.black,
    height: 1.2, // 120%
    letterSpacing: 0,
  );

  static TextStyle plusJakartaSansFont12Neutral800Regular1 =
      GoogleFonts.plusJakartaSans(
        fontSize: 12.sp,
        fontWeight: FontWeightHelper.regular,
        color: AppColor.neutral800, // #1E1E1ECC
        height: 1.0, // 100%
        letterSpacing: 0,
      );

  static TextStyle figtreeFont12Primary70SemiBold1_33 = GoogleFonts.figtree(
    fontSize: 12.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColor.primary70, // #D42F4D
    height: 16 / 12, // ~1.33
    letterSpacing: 0.48, // 4% of 12px
  );

  static TextStyle figtreeFont12LightGrayMedium1_33 = GoogleFonts.figtree(
    fontSize: 12.sp,
    fontWeight: FontWeightHelper.medium,
    color: AppColor.lightGray, // #7C7C82
    height: 16 / 12, // ~1.33
    letterSpacing: 0.48, // 4% of 12px
  );

  static TextStyle urbanistFont16LightGraySemiBold1_2 = GoogleFonts.urbanist(
    fontSize: 16.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColor.lightGray, // #7C7C82
    height: 1.2, // 120%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont10Grey800SemiBold1_54 = GoogleFonts.urbanist(
    fontSize: 10.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColor.grey800,
    height: 1.54, // 154%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont10Grey700Medium1_54 = GoogleFonts.urbanist(
    fontSize: 10.sp,
    fontWeight: FontWeightHelper.medium,
    color: AppColor.grey700, // #364753
    height: 1.54, // 154%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont16Grey800Bold1 = GoogleFonts.urbanist(
    fontSize: 16.sp,
    fontWeight: FontWeightHelper.bold,
    color: AppColor.grey800,
    height: 1.0, // 100%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont12Grey800Regular1_64 = GoogleFonts.urbanist(
    fontSize: 12.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColor.grey800,
    height: 1.64, // 164%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont10Grey700Regular1_4 = GoogleFonts.urbanist(
    fontSize: 10.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColor.grey700, // #364753
    height: 1.4, // 140%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont18RedMedium1_25 = GoogleFonts.urbanist(
    fontSize: 18.sp,
    fontWeight: FontWeightHelper.medium,
    color: AppColor.red, // #F73541
    height: 1.25, // 125%
    letterSpacing: 0,
  );
  static TextStyle urbanistFont18Grey800SemiBold1_25 = GoogleFonts.urbanist(
    fontSize: 18.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColor.grey800, // #F73541
    height: 1.25, // 125%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont16WhiteRegular1_375 = GoogleFonts.urbanist(
    fontSize: 16.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColor.white,
    height: 22 / 16, // ~1.375
    letterSpacing: 0,
  );
  static TextStyle urbanistFont18WhiteRegular1_375 = GoogleFonts.urbanist(
    fontSize: 18.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColor.white,
    height: 22 / 16, // ~1.375
    letterSpacing: 0,
  );

  static TextStyle urbanistFont14RedDarkMedium1 = GoogleFonts.urbanist(
    fontSize: 14.sp,
    fontWeight: FontWeightHelper.medium,
    color: AppColor.redDark, // #481E1E
    height: 1.0, // 100%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont18GreenMedium1_25 = GoogleFonts.urbanist(
    fontSize: 18.sp,
    fontWeight: FontWeightHelper.medium,
    color: AppColor.green, // #008923
    height: 1.25, // 125%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont16Grey700SemiBold1_3 = GoogleFonts.urbanist(
    fontSize: 16.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColor.grey700, // #364753
    height: 1.3, // 130%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont12RedDarkLight1_25 = GoogleFonts.urbanist(
    fontSize: 12.sp,
    fontWeight: FontWeightHelper.light,
    color: AppColor.redDark, // #481E1E
    height: 1.25, // 125%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont12Grey700SemiBold1_2 = GoogleFonts.urbanist(
    fontSize: 12.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColor.grey700, // #364753
    height: 1.2, // 120%
    letterSpacing: 0,
  );
  static TextStyle urbanistFont12BlackBold1_2 = GoogleFonts.urbanist(
    fontSize: 12.sp,
    fontWeight: FontWeightHelper.bold,
    color: AppColor.black, // #364753
    height: 1.2, // 120%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont10WhiteMedium1 = GoogleFonts.urbanist(
    fontSize: 10.sp,
    fontWeight: FontWeightHelper.medium,
    color: AppColor.white, // #FFFFFF
    height: 1.0, // 100%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont10RedAlertsMedium1 = GoogleFonts.urbanist(
    fontSize: 10.sp,
    fontWeight: FontWeightHelper.medium,
    color: AppColor.redAlerts, // #8F2E21
    height: 1.0, // 100%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont10Grey700Regular1_3 = GoogleFonts.urbanist(
    fontSize: 10.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColor.grey700, // #364753
    height: 1.3, // 130%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont14Grey700Regular1_28 = GoogleFonts.urbanist(
    fontSize: 14.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColor.grey700, // #364753
    height: 18 / 14, // ~1.28
    letterSpacing: 0,
  );

  static TextStyle urbanistFont14Grey700Medium1_28 = GoogleFonts.urbanist(
    fontSize: 14.sp,
    fontWeight: FontWeightHelper.medium,
    color: AppColor.grey700, // #364753
    height: 18 / 14, // ~1.28
    letterSpacing: 0,
  );

  static TextStyle urbanistFont14Grey800Bold1 = GoogleFonts.urbanist(
    fontSize: 14.sp,
    fontWeight: FontWeightHelper.bold,
    color: AppColor.grey800, // #364753
    height: 1.0, // 100%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont28Grey800SemiBold1 = GoogleFonts.urbanist(
    fontSize: 28.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColor.grey800,
    height: 1.0, // 100%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont16BlackSemiBold1_2 = GoogleFonts.urbanist(
    fontSize: 16.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColor.black,
    height: 1.2, // 120%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont16BlackRegular1_2 = GoogleFonts.urbanist(
    fontSize: 16.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColor.black,
    height: 1.2, // 120%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont12RedDarkSemiBold1 = GoogleFonts.urbanist(
    fontSize: 12.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColor.redDark,
    height: 1.0, // 100%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont14BlackRegular1_25 = GoogleFonts.urbanist(
    fontSize: 14.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColor.black,
    height: 1.25, // 125%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont14Gray30Regular1_25 = GoogleFonts.urbanist(
    fontSize: 14.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColor.gray30, // #6B7271
    height: 1.25, // 125%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont15Grey700Regular1_33 = GoogleFonts.urbanist(
    fontSize: 15.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColor.grey700, // #364753
    height: 20 / 15, // ~1.33
    letterSpacing: -0.24,
  );
  static TextStyle urbanistFont15LightGrayRegular1_33 = GoogleFonts.urbanist(
    fontSize: 15.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColor.lightGray, // #364753
    height: 20 / 15, // ~1.33
    letterSpacing: -0.24,
  );
  static TextStyle urbanistFont15Grey700Medium1_33 = GoogleFonts.urbanist(
    fontSize: 15.sp,
    fontWeight: FontWeightHelper.medium,
    color: AppColor.grey700, // #364753
    height: 20 / 15, // 20 px
    letterSpacing: -0.5,
  );
  static TextStyle urbanistFont15Grey700SemiBold1_33 = GoogleFonts.urbanist(
    fontSize: 15.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColor.grey700, // #364753
    height: 20 / 15, // 20 px
    letterSpacing: -0.5,
  );

  static TextStyle urbanistFont12RichRedSemiBold1 = GoogleFonts.urbanist(
    fontSize: 12.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColor.richRed, // #C8102E
    height: 1.0, // 100%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont12RedLightMedium1_3 = GoogleFonts.urbanist(
    fontSize: 12.sp,
    fontWeight: FontWeightHelper.medium,
    color: AppColor.redLight, // #FF9C9E
    height: 1.3, // 130%
    letterSpacing: 0,
  );
  static TextStyle urbanistFont12Neutral800Regular1 = GoogleFonts.urbanist(
    fontSize: 12.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColor.neutral800,
    height: 1,
    letterSpacing: 0,
  );
  static TextStyle urbanistFont12Red500Regular1_5 = GoogleFonts.urbanist(
    fontSize: 12.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColor.red500, // #FF9C9E
    height: 18 / 12, // ~1.5
    letterSpacing: 0,
  );

  static TextStyle urbanistFont14Grey700Medium1_25 = GoogleFonts.urbanist(
    fontSize: 14.sp,
    fontWeight: FontWeightHelper.medium,
    color: AppColor.grey700, // #364753
    height: 1.25, // 125%
    letterSpacing: -0.14, // -1% of 14px
  );

  static TextStyle urbanistFont16RichRedSemiBold1_2 = GoogleFonts.urbanist(
    fontSize: 16.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: AppColor.richRed, // #C8102E
    height: 1.2, // 120%
    letterSpacing: 0,
  );

  static TextStyle urbanistFont14Grey600Regular1_5 = GoogleFonts.urbanist(
    fontSize: 14.sp,
    fontWeight: FontWeightHelper.regular,
    color: AppColor.grey700, // Using grey700 as grey600 is not defined
    height: 1.5, // 150%
    letterSpacing: 0,
  );
}
