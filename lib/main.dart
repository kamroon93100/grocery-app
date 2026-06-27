import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

/// PREMIUM BRAND DESIGN SYSTEM
/// Brand: Calm, Premium, Trustworthy
/// Rule: 70% neutral, 20% primary, 10% accent
class AppColors {
  // PRIMARY - Deep Emerald (freshness + appetite + premium)
  static const Color primary       = Color(0xFF0F7C5C);
  static const Color primaryDark   = Color(0xFF0A5C44);
  static const Color primaryLight  = Color(0xFFE8F5EF);
  static const Color primaryAccent = Color(0xFF14A37A);

  // SECONDARY - Warm Cream (spaciousness)
  static const Color cream         = Color(0xFFFAF8F3);
  static const Color creamDark     = Color(0xFFF0EBE0);
  static const Color softWhite     = Color(0xFFFCFCFA);

  // ACCENT - Coral (urgency, sparingly used)
  static const Color coral         = Color(0xFFFF6B5B);
  static const Color coralLight    = Color(0xFFFFE5E1);
  static const Color tangerine     = Color(0xFFFF8C42);

  // NEUTRAL - Charcoal, Slate, Gray
  static const Color charcoal      = Color(0xFF1A1A1A);
  static const Color slate         = Color(0xFF3D3D3D);
  static const Color graySoft      = Color(0xFF6B6B6B);
  static const Color grayLight     = Color(0xFFB8B8B8);
  static const Color grayBg        = Color(0xFFF5F5F5);
  static const Color border        = Color(0xFFE8E8E8);

  // UTILITY
  static const Color success       = Color(0xFF0F7C5C);
  static const Color warning       = Color(0xFFFFB020);
  static const Color error         = Color(0xFFE53935);
  static const Color lowStock      = Color(0xFFFF8C42);

  // BACKGROUND
  static const Color background    = Color(0xFFFAFAF8);
  static const Color cardBg        = Colors.white;
  static const Color textDark      = charcoal;
  static const Color textGrey      = graySoft;
}

/// TYPOGRAPHY SCALE
class AppText {
  static const String fontFamily = 'Roboto';

  // Display - Hero text
  static const TextStyle display = TextStyle(
    fontSize:    32,
    fontWeight:  FontWeight.w800,
    letterSpacing: -0.5,
    color:       AppColors.charcoal,
    height:      1.2,
  );

  // H1 - Page titles
  static const TextStyle h1 = TextStyle(
    fontSize:    24,
    fontWeight:  FontWeight.w700,
    letterSpacing: -0.3,
    color:       AppColors.charcoal,
    height:      1.3,
  );

  // H2 - Section titles
  static const TextStyle h2 = TextStyle(
    fontSize:    18,
    fontWeight:  FontWeight.w700,
    letterSpacing: -0.2,
    color:       AppColors.charcoal,
    height:      1.3,
  );

  // H3 - Card titles
  static const TextStyle h3 = TextStyle(
    fontSize:    15,
    fontWeight:  FontWeight.w600,
    color:       AppColors.charcoal,
    height:      1.3,
  );

  // Body - Regular text
  static const TextStyle body = TextStyle(
    fontSize:    14,
    fontWeight:  FontWeight.w400,
    color:       AppColors.charcoal,
    height:      1.5,
  );

  // Body Small
  static const TextStyle bodySmall = TextStyle(
    fontSize:    12,
    fontWeight:  FontWeight.w400,
    color:       AppColors.graySoft,
    height:      1.4,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontSize:    11,
    fontWeight:  FontWeight.w500,
    color:       AppColors.graySoft,
    letterSpacing: 0.2,
  );

  // Label - Small uppercase
  static const TextStyle label = TextStyle(
    fontSize:    10,
    fontWeight:  FontWeight.w700,
    color:       AppColors.graySoft,
    letterSpacing: 1.2,
  );

  // Price - Tabular numerals
  static const TextStyle price = TextStyle(
    fontSize:    16,
    fontWeight:  FontWeight.w700,
    color:       AppColors.charcoal,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // Price Strike - Original price
  static const TextStyle priceStrike = TextStyle(
    fontSize:    12,
    fontWeight:  FontWeight.w400,
    color:       AppColors.grayLight,
    decoration:  TextDecoration.lineThrough,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // Button text
  static const TextStyle button = TextStyle(
    fontSize:    14,
    fontWeight:  FontWeight.w600,
    letterSpacing: 0.3,
  );
}

/// SPACING SYSTEM
class AppSpacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

/// RADIUS SYSTEM
class AppRadius {
  static const double sm   = 6;
  static const double md   = 10;
  static const double lg   = 14;
  static const double xl   = 20;
  static const double full = 999;
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
          primaryColor:    AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3:    true,
          colorScheme: ColorScheme.fromSeed(
            seedColor:  AppColors.primary,
            primary:    AppColors.primary,
            secondary:  AppColors.coral,
            surface:    AppColors.cardBg,
          ),
          fontFamily: AppText.fontFamily,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.charcoal,
            elevation:       0,
            scrolledUnderElevation: 0,
            iconTheme: IconThemeData(color: AppColors.charcoal),
            titleTextStyle: TextStyle(
              color:      AppColors.charcoal,
              fontSize:   17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
            centerTitle: false,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl, vertical: AppSpacing.md),
              textStyle: AppText.button,
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl, vertical: AppSpacing.md),
              textStyle: AppText.button,
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
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide:   const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide:   const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide:   const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            filled:    true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          ),
          cardTheme: CardThemeData(
            color: AppColors.cardBg,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor:        AppColors.cream,
            selectedColor:          AppColors.primary,
            secondarySelectedColor: AppColors.primaryDark,
            labelStyle: AppText.caption.copyWith(color: AppColors.charcoal),
            secondaryLabelStyle: AppText.caption.copyWith(color: Colors.white),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          dividerTheme: const DividerThemeData(
            color: AppColors.border,
            thickness: 1,
            space:     1,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
