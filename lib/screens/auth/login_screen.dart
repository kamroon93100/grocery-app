import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_colors.dart';
import '../../widgets/smooth_text_field.dart';
import 'package:grocery_local/screens/home/home_screen.dart';
import 'register_screen.dart';
import 'otp_login_screen.dart';
import '../../services/google_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {

  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool  _obscure      = true;

  late AnimationController _logoController;
  late Animation<double>   _logoScale;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _fadeAnim = CurvedAnimation(
      parent: _logoController, curve: Curves.easeIn);
    _logoController.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _logoController.dispose();
    super.dispose();
  }

  String _friendlyError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('socketexception') ||
        lower.contains('no route to host') ||
        lower.contains('connection refused') ||
        lower.contains('network is unreachable') ||
        lower.contains('timed out') ||
        lower.contains('host lookup')) {
      return 'Cannot connect to server. Please check your internet connection and try again.';
    }
    return raw;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth   = context.read<AuthProvider>();
    final result = await auth.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );
    if (!mounted) return;
    if (result['success'] == true) {
      context.read<ProductProvider>().loadCategories();
      context.read<ProductProvider>().loadProducts();
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         Text(result['message'] ?? 'Login failed'),
          backgroundColor: AppColors.error,
          behavior:        SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),

                // LOGO
                ScaleTransition(
                  scale: _logoScale,
                  child: Container(
                    width:  120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.25),
                          blurRadius: 30,
                          spreadRadius: 3,
                          offset: const Offset(0, 8)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      Text(
                        AppConstants.storeName,
                        style: const TextStyle(
                          fontSize:   28,
                          fontWeight: FontWeight.bold,
                          color:      AppColors.textStrong),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppConstants.storeTagline,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14)),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                SmoothTextField(
                  controller:   _emailCtrl,
                  label:        'Email Address',
                  prefixIcon:   Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  primaryColor: AppColors.primary,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter email';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                SmoothTextField(
                  controller:  _passwordCtrl,
                  label:       'Password',
                  prefixIcon:  Icons.lock_outline,
                  obscureText: _obscure,
                  primaryColor: AppColors.primary,
                  suffixIcon: IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        key: ValueKey(_obscure),
                        color: Colors.grey.shade600,
                      ),
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter password';
                    if (v.length < 6) return 'Min 6 characters';
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width:  double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                      elevation: auth.isLoading ? 0 : 4,
                      shadowColor: AppColors.primary.withOpacity(0.5),
                    ),
                    onPressed: auth.isLoading ? null : _login,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: auth.isLoading
                          ? const SizedBox(
                              key: ValueKey('loading'),
                              width: 24, height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text('Login',
                              key: ValueKey('text'),
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width:  double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    icon:  const Icon(Icons.phone_outlined,
                      color: AppColors.primary),
                    label: const Text('Login with Phone (OTP)',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                    onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const OtpLoginScreen())),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.g_mobiledata, color: Colors.black87, size: 28),
                    label: const Text('Continue with Google',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                    onPressed: () async {
                      final result = await GoogleAuthService().signIn();
                      if (!context.mounted) return;
                      if (result['success'] == true) {
                        context.read<ProductProvider>().loadCategories();
                        context.read<ProductProvider>().loadProducts();
                        Navigator.pushReplacement(
                          context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message'] ?? 'Google sign in failed'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 16),

                if (kDebugMode)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: const Column(children: [
                      Text('Demo Admin Login',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                      SizedBox(height: 4),
                      Text('Email: admin@grocery.com',
                        style: TextStyle(color: AppColors.primary, fontSize: 13)),
                      Text('Password: Admin@123',
                        style: TextStyle(color: AppColors.primary, fontSize: 13)),
                    ]),
                  ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?",
                      style: TextStyle(color: AppColors.textMuted)),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen())),
                      child: const Text('Register Now',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


