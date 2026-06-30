import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppText {
  static TextStyle _heading(double size, FontWeight w, double height) =>
      GoogleFonts.plusJakartaSans(
        fontSize:   size,
        fontWeight: w,
        height:     height / size,
        color:      AppColors.textStrong,
        letterSpacing: -0.2,
      );

  static TextStyle _body(double size, FontWeight w, double height,
      {Color? color}) =>
      GoogleFonts.inter(
        fontSize:   size,
        fontWeight: w,
        height:     height / size,
        color:      color ?? AppColors.textStrong,
      );

  // Display
  static TextStyle get display    => _heading(40, FontWeight.w800, 48);
  // H1
  static TextStyle get h1         => _heading(28, FontWeight.w700, 36);
  // H2
  static TextStyle get h2         => _heading(22, FontWeight.w700, 30);
  // H3
  static TextStyle get h3         => _heading(18, FontWeight.w600, 26);

  // Body
  static TextStyle get body       => _body(16, FontWeight.w400, 24);
  static TextStyle get bodyStrong => _body(16, FontWeight.w600, 24);
  static TextStyle get small      => _body(14, FontWeight.w400, 20);
  static TextStyle get smallStrong=> _body(14, FontWeight.w600, 20);
  static TextStyle get caption    => _body(12, FontWeight.w400, 16,
      color: AppColors.textMuted);
  static TextStyle get label      => _body(12, FontWeight.w600, 16,
      color: AppColors.textMuted);

  // Price
  static TextStyle get price      => GoogleFonts.inter(
        fontSize:   20,
        fontWeight: FontWeight.w700,
        height:     28 / 20,
        color:      AppColors.textStrong,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle get priceSmall => GoogleFonts.inter(
        fontSize:   15,
        fontWeight: FontWeight.w700,
        height:     20 / 15,
        color:      AppColors.textStrong,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle get priceStrike => GoogleFonts.inter(
        fontSize:   13,
        fontWeight: FontWeight.w400,
        color:      AppColors.textSubtle,
        decoration: TextDecoration.lineThrough,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // Button
  static TextStyle get button     => GoogleFonts.plusJakartaSans(
        fontSize:   15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );
}


