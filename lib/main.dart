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

class AppColors {
  // PRIMARY PALETTE
  static const Color primary      = Color(0xFF99E1D9);  // Turquoise
  static const Color primaryDark  = Color(0xFF6FBFB5);  // Darker turquoise
  static const Color primaryLight = Color(0xFFCFF0EB);  // Light turquoise

  // BLACK PALETTE
  static const Color jetBlack     = Color(0xFF1D1D1D);  // Jet Black
  static const Color softBlack    = Color(0xFF2A2A2A);  // Soft black
  static const Color cardBlack    = Color(0xFF333333);  // Card background

  // NEUTRAL
  static const Color white        = Colors.white;
  static const Color textDark     = Color(0xFF1D1D1D);
  static const Color textLight    = Color(0xFFEEEEEE);
  static const Color textGrey     = Color(0xFF8A8A8A);
  static const Color background   = Color(0xFFFAFAFA);
  static const Color cardBg       = Colors.white;
  static const Color border       = Color(0xFFE5E5E5);

  // ACCENT
  static const Color success      = Color(0xFF99E1D9);
  static const Color warning      = Color(0xFFFFA726);
  static const Color error        = Color(0xFFEF5350);
  static const Color info         = Color(0xFF99E1D9);
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
          primaryColor:    AppColors.jetBlack,
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3:    true,
          colorScheme: ColorScheme.fromSeed(
            seedColor:  AppColors.primary,
            primary:    AppColors.jetBlack,
            secondary:  AppColors.primary,
            surface:    Colors.white,
            onPrimary:  AppColors.primary,
            onSecondary:AppColors.jetBlack,
          ),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.jetBlack,
            foregroundColor: AppColors.primary,
            elevation:       0,
            iconTheme: IconThemeData(color: AppColors.primary),
            titleTextStyle: TextStyle(
              color:      AppColors.primary,
              fontSize:   18,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.jetBlack,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.jetBlack,
              side: const BorderSide(color: AppColors.jetBlack, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:   BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:   const BorderSide(
                color: AppColors.jetBlack, width: 2),
            ),
            filled:    true,
            fillColor: Colors.white,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: AppColors.jetBlack,
            foregroundColor: AppColors.primary,
          ),
          chipTheme: ChipThemeData(
            backgroundColor:  AppColors.primaryLight,
            selectedColor:    AppColors.primary,
            secondarySelectedColor: AppColors.jetBlack,
            labelStyle: const TextStyle(color: AppColors.jetBlack),
            secondaryLabelStyle: const TextStyle(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
