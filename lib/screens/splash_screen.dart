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
    with TickerProviderStateMixin {

  late AnimationController _logoController;
  late AnimationController _pulseController;
  late Animation<double>   _logoScale;
  late Animation<double>   _fade;
  late Animation<double>   _pulseScale;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _fade = CurvedAnimation(
      parent: _logoController, curve: Curves.easeIn);

    _pulseController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _logoController.forward();
    _init();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 3));
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
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo with pulse + glow
            ScaleTransition(
              scale: _logoScale,
              child: ScaleTransition(
                scale: _pulseScale,
                child: Container(
                  width:  170,
                  height: 170,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 50,
                        spreadRadius: 8,
                        offset: const Offset(0, 10)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            FadeTransition(
              opacity: _fade,
              child: Column(
                children: [
                  Text(AppConstants.storeName,
                    style: AppText.display.copyWith(
                      fontSize: 32, color: AppColors.textStrong)),
                  const SizedBox(height: 6),
                  Text(AppConstants.storeTagline,
                    style: AppText.body.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),

            const SizedBox(height: 60),

            FadeTransition(
              opacity: _fade,
              child: _LoadingDots(),
            ),

            const SizedBox(height: 24),
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

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {

  late List<AnimationController> _controllers;
  late List<Animation<double>>   _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync:    this,
        duration: const Duration(milliseconds: 600),
      );
    });
    _animations = _controllers.map((c) =>
      Tween<double>(begin: 0, end: -12).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut))).toList();

    _startAnimation();
  }

  void _startAnimation() async {
    while (mounted) {
      for (int i = 0; i < _controllers.length; i++) {
        if (!mounted) return;
        _controllers[i].forward().then((_) {
          if (mounted) _controllers[i].reverse();
        });
        await Future.delayed(const Duration(milliseconds: 200));
      }
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (context, _) {
            return Transform.translate(
              offset: Offset(0, _animations[i].value),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width:  10, height: 10,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
