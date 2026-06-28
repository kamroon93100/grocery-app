import 'package:flutter/material.dart';

class AppMotion {
  static const Duration fast   = Duration(milliseconds: 140);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow   = Duration(milliseconds: 300);

  static const Curve smooth    = Curves.easeOutCubic;
  static const Curve bounce    = Curves.easeOutBack;
}
