import 'package:flutter/material.dart';

// Extension to create MaterialColor from a single Color
MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

class AppColors {
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSoftSurface = Color(0xFFF5F8FB);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF151923);
  static const Color lightTextSecondary = Color(0xFF5F6673);
  static const Color lightTextMuted = Color(0xFF8E95A3);
  static const Color lightBorder = Color(0xFFE7EAF0);
  static const Color lightDivider = Color(0xFFEEF0F3);
  static const Color _lightBrand = Color(0xFF0B63F6); // Private to create MaterialColor
  static const Color lightBrandDark = Color(0xFF084DC1);
  static const Color lightSuccess = Color(0xFF18B77A);
  static const Color lightSuccessSoft = Color(0xFFEAF8F2);
  static const Color lightWarning = Color(0xFFFFB020);
  static const Color lightDanger = Color(0xFFEF4444);
  static const Color lightPromoBlue = Color(0xFF075BFF);
  static const Color lightPromoGreen = Color(0xFF21B573);
  static const Color lightCategoryBg = Color(0xFFEEF7FF);

  static MaterialColor get lightBrand => createMaterialColor(_lightBrand);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F1115);
  static const Color darkSurface = Color(0xFF171A21);
  static const Color darkSoftSurface = Color(0xFF20242D);
  static const Color darkCard = Color(0xFF171A21);
  static const Color darkTextPrimary = Color(0xFFF4F6FA);
  static const Color darkTextSecondary = Color(0xFFB6BCC8);
  static const Color darkTextMuted = Color(0xFF7E8797);
  static const Color darkBorder = Color(0xFF2B303B);
  static const Color darkDivider = Color(0xFF272C35);
  static const Color _darkBrand = Color(0xFF4D8DFF); // Private to create MaterialColor
  static const Color darkSuccess = Color(0xFF2ED391);

  static MaterialColor get darkBrand => createMaterialColor(_darkBrand);

  // General use colors (if any are truly universal)

  // Simplified aliases (from constants/app_colors.dart)
  static const Color primary       = Color(0xFF12B76A);
  static const Color primaryDark   = Color(0xFF0E8A52);
  static const Color primaryLight  = Color(0xFFE7F8EF);
  static const Color accent        = Color(0xFFFF7A45);
  static const Color accentLight   = Color(0xFFFFEEE6);
  static const Color background    = Color(0xFFF7F8FA);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color surfaceAlt    = Color(0xFFFAFBFC);
  static const Color textStrong    = Color(0xFF101828);
  static const Color textMuted     = Color(0xFF667085);
  static const Color textSubtle    = Color(0xFF98A2B3);
  static const Color border        = Color(0xFFE4E7EC);
  static const Color borderLight   = Color(0xFFF2F4F7);
  static const Color cream         = surface;
  static const Color creamDark     = surfaceAlt;
  static const Color softWhite     = surface;
  static const Color jetBlack      = textStrong;
  static const Color charcoal      = textStrong;
  static const Color slate         = textMuted;
  static const Color graySoft      = textMuted;
  static const Color grayLight     = textSubtle;
  static const Color grayBg        = background;
  static const Color cardBg        = surface;
  static const Color textDark      = textStrong;
  static const Color textGrey      = textMuted;
  static const Color textLight     = textSubtle;
  static const Color coral         = accent;
  static const Color coralLight    = accentLight;
  static const Color tangerine     = Color(0xFFFF8C42);
  static const Color softBlack     = Color(0xFF2A2A2A);
  static const Color cardBlack     = Color(0xFF333333);
  static const Color white         = Colors.white;
  static const Color primaryAccent = Color(0xFF14A37A);
  static const Color success       = Color(0xFF12B76A);
  static const Color warning       = Color(0xFFF79009);
  static const Color error         = Color(0xFFF04438);
  static const Color info          = Color(0xFF0BA5EC);
}

