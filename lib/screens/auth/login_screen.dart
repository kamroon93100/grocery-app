import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../constants/app_constants.dart';
import '../../widgets/smooth_text_field.dart';
import '../../main.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';
import 'otp_login_screen.dart';

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
      backgroundColor: AppColors.jetBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),

                ScaleTransition(
                  scale: _logoScale,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5),
                      ],
                    ),
                    child: const Icon(Icons.store_rounded,
                      size: 70, color: AppColors.jetBlack),
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
                          color:      AppColors.primary),
                      ),
                      Text(
                        AppConstants.storeTagline,
                        style: TextStyle(
                          color: AppColors.primary.withOpacity(0.7),
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

                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width:    double.infinity,
                  height:   55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.jetBlack,
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
                                color: AppColors.jetBlack, strokeWidth: 2.5),
                            )
                          : const Text('Login',
                              key: ValueKey('text'),
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.jetBlack,
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

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3)),
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
                      style: TextStyle(
                        color: AppColors.primary.withOpacity(0.7))),
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
