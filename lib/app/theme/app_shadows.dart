import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  static const BoxShadow level1 = BoxShadow(
    color: Colors.black,
    blurRadius: 12,
    offset: Offset(0, 3),
    spreadRadius: 0,
  );

  static const BoxShadow level2 = BoxShadow(
    color: Colors.black,
    blurRadius: 20,
    offset: Offset(0, 8),
    spreadRadius: 0,
  );

  static const BoxShadow floatingCart = BoxShadow(
    color: Colors.black,
    blurRadius: 22,
    offset: Offset(0, 8),
    spreadRadius: 0,
  );

  static List<BoxShadow> get subtle => [
    BoxShadow(
      color:     AppColors.textStrong.withOpacity(0.04),
      blurRadius: 8,
      offset:    const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get card => [
    BoxShadow(
      color:     AppColors.textStrong.withOpacity(0.03),
      blurRadius: 6,
      offset:    const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get raised => [
    BoxShadow(
      color:     AppColors.textStrong.withOpacity(0.06),
      blurRadius: 12,
      offset:    const Offset(0, 4),
    ),
  ];

  // Helper method to create dynamic shadows with opacity from a base color
  static List<BoxShadow> createSoftShadow(
    Color baseColor, {
    double blur = 0,
    double yOffset = 0,
    double opacity = 0,
  }) {
    return [
      BoxShadow(
        color: baseColor.withOpacity(opacity),
        blurRadius: blur,
        offset: Offset(0, yOffset),
        spreadRadius: 0,
      ),
    ];
  }
}


