import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
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
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
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
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Container(
                padding:     const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color:        Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.green.shade800, blurRadius: 25),
                  ],
                ),
                child: const Icon(Icons.store_rounded, size: 80, color: Colors.green),
              ),
            ),
            const SizedBox(height: 30),
            FadeTransition(
              opacity: _fade,
              child: const Column(
                children: [
                  Text('Local Grocery Store',
                    style: TextStyle(
                      fontSize:   28,
                      fontWeight: FontWeight.bold,
                      color:      Colors.white,
                    )),
                  SizedBox(height: 8),
                  Text('Fresh products at your doorstep',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 60),
            const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          ],
        ),
      ),
    );
  }
}
