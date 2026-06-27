import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../services/notification_service.dart';
import '../constants/app_constants.dart';
import '../main.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scale;
  late Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 1000));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    _init();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    await auth.checkAuth();
    if (!mounted) return;
    if (auth.isLoggedIn) {
      context.read<ProductProvider>().loadCategories();
      context.read<ProductProvider>().loadProducts();
      NotificationService().showWelcomeNotification(auth.userName);
      NotificationService().startPolling();
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jetBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color:        AppColors.primary,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5),
                  ],
                ),
                child: const Icon(Icons.store_rounded,
                  size: 80, color: AppColors.jetBlack),
              ),
            ),
            const SizedBox(height: 30),
            FadeTransition(
              opacity: _fade,
              child: Column(
                children: [
                  Text(AppConstants.storeName,
                    style: const TextStyle(
                      fontSize:   28,
                      fontWeight: FontWeight.bold,
                      color:      AppColors.primary)),
                  const SizedBox(height: 8),
                  Text(AppConstants.storeTagline,
                    style: TextStyle(
                      color: AppColors.primary.withOpacity(0.7),
                      fontSize: 14)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3))),
                    child: const Text('🌿 Fresh • Fast • Trusted',
                      style: TextStyle(color: AppColors.primary, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            const CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 3),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _fade,
              child: Text(
                'v' + AppConstants.version,
                style: TextStyle(
                  color: AppColors.primary.withOpacity(0.5),
                  fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
