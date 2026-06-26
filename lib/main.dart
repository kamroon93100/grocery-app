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
  static const Color primary      = Color(0xFF1BA672);
  static const Color primaryDark  = Color(0xFF0F8559);
  static const Color primaryLight = Color(0xFFE8F5E9);
  static const Color textDark     = Color(0xFF1C1C1C);
  static const Color textGrey     = Color(0xFF6B6B6B);
  static const Color background   = Color(0xFFFAFAFA);
  static const Color cardBg       = Colors.white;
  static const Color border       = Color(0xFFE5E5E5);
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
            surface:    Colors.white,
          ),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.textDark,
            elevation:       0,
            iconTheme: IconThemeData(color: AppColors.textDark),
            titleTextStyle: TextStyle(
              color:      AppColors.textDark,
              fontSize:   18,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:   BorderSide(color: Colors.grey.shade300),
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
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
