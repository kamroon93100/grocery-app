import 'package:flutter/material.dart';
import 'package:grocery_local/app/theme/app_colors.dart';

extension CustomColorScheme on ColorScheme {
  Color get softSurface => brightness == Brightness.light
      ? AppColors.lightSoftSurface
      : AppColors.darkSoftSurface;

  Color get card => brightness == Brightness.light
      ? AppColors.lightCard
      : AppColors.darkCard;

  Color get textPrimary => brightness == Brightness.light
      ? AppColors.lightTextPrimary
      : AppColors.darkTextPrimary;

  Color get textSecondary => brightness == Brightness.light
      ? AppColors.lightTextSecondary
      : AppColors.darkTextSecondary;

  Color get textMuted => brightness == Brightness.light
      ? AppColors.lightTextMuted
      : AppColors.darkTextMuted;

  Color get border => brightness == Brightness.light
      ? AppColors.lightBorder
      : AppColors.darkBorder;

  Color get divider => brightness == Brightness.light
      ? AppColors.lightDivider
      : AppColors.darkDivider;

  Color get success => brightness == Brightness.light
      ? AppColors.lightSuccess
      : AppColors.darkSuccess;

  Color get successSoft => brightness == Brightness.light
      ? AppColors.lightSuccessSoft
      : AppColors.darkSuccess;

  Color get warning => AppColors.lightWarning;

  Color get danger => AppColors.lightDanger;

  Color get promoBlue => brightness == Brightness.light
      ? AppColors.lightPromoBlue
      : primary;

  Color get promoGreen => brightness == Brightness.light
      ? AppColors.lightPromoGreen
      : success;

  Color get categoryBg => brightness == Brightness.light
      ? AppColors.lightCategoryBg
      : softSurface;
}

