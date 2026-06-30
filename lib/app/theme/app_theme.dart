import 'package:flutter/material.dart';
import 'package:grocery_local/app/theme/app_colors.dart';
import 'package:grocery_local/app/theme/app_text_styles.dart';
import 'package:grocery_local/app/theme/app_radius.dart';
import 'package:grocery_local/app/theme/app_spacing.dart';

class AppTheme {
  static ThemeData lightTheme = _buildTheme(Brightness.light);
  static ThemeData darkTheme = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;
    final ColorScheme colorScheme = ColorScheme(
      brightness: brightness,
      primary: isLight ? AppColors.lightBrand : AppColors.darkBrand,
      onPrimary: Colors.white,
      secondary: isLight ? AppColors.lightSuccess : AppColors.darkSuccess,
      onSecondary: Colors.white,
      error: AppColors.lightDanger,
      onError: Colors.white,
      surface: isLight ? AppColors.lightBackground : AppColors.darkBackground,
      onSurface: isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary,
    );

    return ThemeData(
      brightness: brightness,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primaryColor: colorScheme.primary,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: _buildTextTheme(colorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h2(color: colorScheme.onSurface),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.primaryButton),
        ),
        textTheme: ButtonTextTheme.primary,
        colorScheme: colorScheme,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.productCardImage),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        hintStyle: AppTextStyles.body(color: colorScheme.onSurface.withValues(alpha: 0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.searchBar),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.searchBar),
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.searchBar),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorScheme.primary,
        selectionColor: colorScheme.primary.withValues(alpha: 0.4),
        selectionHandleColor: colorScheme.primary,
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: AppTextStyles.small(),
        unselectedLabelStyle: AppTextStyles.small(),
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.bottomSheet)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.bottomSheet)),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: AppTextStyles.display(color: colorScheme.onSurface),
      headlineLarge: AppTextStyles.h1(color: colorScheme.onSurface),
      headlineMedium: AppTextStyles.h2(color: colorScheme.onSurface),
      headlineSmall: AppTextStyles.h3(color: colorScheme.onSurface),
      titleLarge: AppTextStyles.sectionTitle(color: colorScheme.onSurface),
      bodyLarge: AppTextStyles.body(color: colorScheme.onSurface),
      bodyMedium: AppTextStyles.body(color: colorScheme.onSurface),
      bodySmall: AppTextStyles.caption(color: colorScheme.onSurface.withValues(alpha: 0.6)),
      labelLarge: AppTextStyles.bodyStrong(color: colorScheme.onPrimary),
      labelMedium: AppTextStyles.small(color: colorScheme.onSurface),
    );
  }
}


