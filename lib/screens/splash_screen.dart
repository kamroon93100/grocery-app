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
      duration: const Duration(milliseconds: 900));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
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
      backgroundColor: AppColors.cream,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Container(
                width:  100, height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: const Icon(Icons.eco_rounded,
                  size: 56, color: Colors.white),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            FadeTransition(
              opacity: _fade,
              child: Column(
                children: [
                  Text(AppConstants.storeName, style: AppText.display),
                  const SizedBox(height: AppSpacing.xs),
                  Text(AppConstants.storeTagline,
                    style: AppText.body.copyWith(color: AppColors.graySoft)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl * 2),
            const SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 2.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            FadeTransition(
              opacity: _fade,
              child: Text('v' + AppConstants.version,
                style: AppText.caption),
            ),
          ],
        ),
      ),
    );
  }
}
