import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static const String _fontFamily = "Plus Jakarta Sans"; // As recommended in design pack

  static TextStyle _baseTextStyle({
    required double fontSize,
    required double lineHeight,
    required FontWeight fontWeight,
    Color? color,
    TextDecoration? decoration,
  }) {
    try {
      return GoogleFonts.getFont(
        _fontFamily,
        fontSize: fontSize,
        height: lineHeight / fontSize,
        fontWeight: fontWeight,
        color: color,
        decoration: decoration,
      );
    } catch (_) {
      return TextStyle(
        fontSize: fontSize,
        height: lineHeight / fontSize,
        fontWeight: fontWeight,
        color: color,
        decoration: decoration,
      );
    }
  }

  // Display: 34 / 40 / 800
  static TextStyle display({Color? color}) => _baseTextStyle(
        fontSize: 34,
        lineHeight: 40,
        fontWeight: FontWeight.w800,
        color: color,
      );

  // H1: 28 / 34 / 800
  static TextStyle h1({Color? color}) => _baseTextStyle(
        fontSize: 28,
        lineHeight: 34,
        fontWeight: FontWeight.w800,
        color: color,
      );

  // H2: 24 / 30 / 800
  static TextStyle h2({Color? color}) => _baseTextStyle(
        fontSize: 24,
        lineHeight: 30,
        fontWeight: FontWeight.w800,
        color: color,
      );

  // H3: 20 / 26 / 750
  static TextStyle h3({Color? color}) => _baseTextStyle(
        fontSize: 20,
        lineHeight: 26,
        fontWeight: FontWeight.w700, // 750 is not a standard FontWeight, using w700 (bold)
        color: color,
      );

  // SectionTitle: 19 / 25 / 800
  static TextStyle sectionTitle({Color? color}) => _baseTextStyle(
        fontSize: 19,
        lineHeight: 25,
        fontWeight: FontWeight.w800,
        color: color,
      );

  // Body: 15 / 22 / 500
  static TextStyle body({Color? color}) => _baseTextStyle(
        fontSize: 15,
        lineHeight: 22,
        fontWeight: FontWeight.w500,
        color: color,
      );

  // BodyStrong: 15 / 22 / 700
  static TextStyle bodyStrong({Color? color}) => _baseTextStyle(
        fontSize: 15,
        lineHeight: 22,
        fontWeight: FontWeight.w700,
        color: color,
      );

  // Caption: 13 / 18 / 500
  static TextStyle caption({Color? color}) => _baseTextStyle(
        fontSize: 13,
        lineHeight: 18,
        fontWeight: FontWeight.w500,
        color: color,
      );

  // Small: 12 / 16 / 600
  static TextStyle small({Color? color}) => _baseTextStyle(
        fontSize: 12,
        lineHeight: 16,
        fontWeight: FontWeight.w600,
        color: color,
      );

  // Price: 20 / 24 / 800
  static TextStyle price({Color? color}) => _baseTextStyle(
        fontSize: 20,
        lineHeight: 24,
        fontWeight: FontWeight.w800,
        color: color,
      );
}


