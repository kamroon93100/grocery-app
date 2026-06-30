import 'dart:ui' as ui;
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
import 'services/connectivity_service.dart';
import 'widgets/offline_banner.dart';
import 'screens/splash_screen.dart';
import 'app/theme/app_colors.dart';
import 'app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
  };

  _runApp();
}

void _runApp() {
  ui.PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Unhandled error: $error\n$stack');
    return true;
  };

  try {
    NotificationService().init();
  } catch (_) {}

  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
    // Don't crash — just log
  };

  runApp(const GroceryApp());
}

/// TYPOGRAPHY SCALE - Inter + Plus Jakarta Sans
class AppText {
  static TextStyle _heading(double size, FontWeight w, double height) {
    try {
      return GoogleFonts.plusJakartaSans(
        fontSize:   size,
        fontWeight: w,
        height:     height / size,
        color:      AppColors.textStrong,
        letterSpacing: -0.2,
      );
    } catch (_) {
      return TextStyle(fontSize: size, fontWeight: w, height: height / size, color: AppColors.textStrong);
    }
  }

  static TextStyle _body(double size, FontWeight w, double height,
      {Color? color}) {
    try {
      return GoogleFonts.inter(
        fontSize:   size,
        fontWeight: w,
        height:     height / size,
        color:      color ?? AppColors.textStrong,
      );
    } catch (_) {
      return TextStyle(fontSize: size, fontWeight: w, height: height / size, color: color ?? AppColors.textStrong);
    }
  }

  static TextStyle _inter(double size, FontWeight w, double height, Color color, {TextDecoration? decoration}) {
    try {
      return GoogleFonts.inter(
        fontSize: size,
        fontWeight: w,
        height: height / size,
        color: color,
        decoration: decoration,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
    } catch (_) {
      return TextStyle(fontSize: size, fontWeight: w, height: height / size, color: color, decoration: decoration);
    }
  }

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
  static TextStyle get price      => _inter(20, FontWeight.w700, 28, AppColors.textStrong);
  static TextStyle get priceSmall => _inter(15, FontWeight.w700, 20, AppColors.textStrong);
  static TextStyle get priceStrike => _inter(13, FontWeight.w400, 18, AppColors.textSubtle, decoration: TextDecoration.lineThrough);

  // Button
  static TextStyle get button => _button();
  static TextStyle _button() {
    try {
      return GoogleFonts.plusJakartaSans(
        fontSize:   15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );
    } catch (_) {
      return TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.1);
    }
  }
}

/// SPACING (8-point grid)
class AppSpacing {
  // ─── ALIASES ───
  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double xl   = 20;
  static const double xxl  = 24;
  static const double xxxl = 32;

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
  // ─── ALIASES ───
  static const double md   = 10;
  static const double lg   = 14;
  static const double xl   = 20;

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
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuth()),
        ChangeNotifierProvider(create: (_) => CartProvider()..loadCart()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
      ],
      child: MaterialApp(
        title:                     'Kohli Store',
        debugShowCheckedModeBanner: false,
        theme:                     AppTheme.lightTheme,
        darkTheme:                 AppTheme.darkTheme,
        themeMode:                 ThemeMode.light,
        home: const SplashScreen(),
        builder: (context, child) => OfflineBanner(child: child!),
      ),
    );
  }
}




