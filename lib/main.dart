import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'providers/address_provider.dart';
import 'providers/wishlist_provider.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const GroceryApp());
}

/// ═══════════════════════════════════════════════════════
/// 🎨 BRAND DESIGN SYSTEM
/// Brand Feel: Fast, Fresh, Premium, Dependable
/// ═══════════════════════════════════════════════════════

class AppColors {
  // PRIMARY
  static const Color primary       = Color(0xFF12B76A); // Brand green
  static const Color primaryDark   = Color(0xFF0E8A52); // Pressed CTA
  static const Color primaryLight  = Color(0xFFE7F8EF); // Subtle bg

  // ACCENT
  static const Color accent        = Color(0xFFFF7A45); // Urgency
  static const Color accentLight   = Color(0xFFFFEEE6);

  // SURFACES
  static const Color background    = Color(0xFFF7F8FA); // Main canvas
  static const Color surface       = Color(0xFFFFFFFF); // Cards
  static const Color surfaceAlt    = Color(0xFFFAFBFC); // Subtle surface

  // TEXT
  static const Color textStrong    = Color(0xFF101828); // Headings
  static const Color textMuted     = Color(0xFF667085); // Labels
  static const Color textSubtle    = Color(0xFF98A2B3); // Hints

  // BORDERS
  static const Color border        = Color(0xFFE4E7EC); // Dividers
  static const Color borderLight   = Color(0xFFF2F4F7);

  // STATES
  static const Color success       = Color(0xFF12B76A); // Stock, delivered
  static const Color warning       = Color(0xFFF79009); // Low stock
  static const Color error         = Color(0xFFF04438); // Failed
  static const Color info          = Color(0xFF0BA5EC); // Info
}

/// TYPOGRAPHY SCALE - Inter + Plus Jakarta Sans
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

/// SPACING (8-point grid)
class AppSpacing {
  static const double x4   = 4;
  static const double x8   = 8;
  static const double x12  = 12;
  static const double x16  = 16;
  static const double x24  = 24;
  static const double x32  = 32;
  static const double x40  = 40;
  static const double x48  = 48;
}

/// RADIUS
class AppRadius {
  static const double card     = 12;
  static const double featured = 16;
  static const double pill     = 999;
  static const double sm       = 8;
}

/// MOTION DURATIONS
class AppMotion {
  static const Duration fast   = Duration(milliseconds: 140);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow   = Duration(milliseconds: 300);

  static const Curve smooth    = Curves.easeOutCubic;
  static const Curve bounce    = Curves.easeOutBack;
}

/// SHADOWS - Very subtle, almost flat
class AppShadow {
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
}

class GroceryApp extends StatelessWidget {
  const GroceryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: MaterialApp(
        title:                     'Kohli Store',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor:  AppColors.primary,
            primary:    AppColors.primary,
            secondary:  AppColors.accent,
            surface:    AppColors.surface,
            error:      AppColors.error,
          ),
          textTheme: GoogleFonts.interTextTheme(),
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textStrong,
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: const IconThemeData(color: AppColors.textStrong),
            titleTextStyle: AppText.h3,
            centerTitle: false,
            surfaceTintColor: Colors.transparent,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x24, vertical: AppSpacing.x12),
              textStyle: AppText.button,
              minimumSize: const Size(0, 48),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x24, vertical: AppSpacing.x12),
              textStyle: AppText.button,
              minimumSize: const Size(0, 48),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: AppText.button,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              borderSide:   const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              borderSide:   const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              borderSide:   const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              borderSide:   const BorderSide(color: AppColors.error),
            ),
            filled:    true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x16, vertical: AppSpacing.x12),
            labelStyle: AppText.small.copyWith(color: AppColors.textMuted),
            hintStyle:  AppText.small.copyWith(color: AppColors.textSubtle),
          ),
          cardTheme: CardThemeData(
            color: AppColors.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
              side: const BorderSide(color: AppColors.border, width: 1),
            ),
            margin: EdgeInsets.zero,
          ),
          chipTheme: ChipThemeData(
            backgroundColor: AppColors.primaryLight,
            selectedColor:   AppColors.primary,
            labelStyle: AppText.smallStrong,
            secondaryLabelStyle: AppText.smallStrong.copyWith(color: Colors.white),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            side: BorderSide.none,
          ),
          dividerTheme: const DividerThemeData(
            color:     AppColors.border,
            thickness: 1,
            space:     1,
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: AppColors.textStrong,
            contentTextStyle: AppText.smallStrong.copyWith(color: Colors.white),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
