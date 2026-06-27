import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../constants/app_constants.dart';
import '../../widgets/smooth_text_field.dart';
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
          backgroundColor: Colors.red,
          behavior:        SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Animated logo
                ScaleTransition(
                  scale: _logoScale,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1BA672), Color(0xFF0F8559)],
                        begin: Alignment.topLeft,
                        end:   Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade300,
                          blurRadius: 24,
                          offset: const Offset(0, 8)),
                      ],
                    ),
                    child: const Icon(Icons.store_rounded,
                      size: 70, color: Colors.white),
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
                          fontSize:   26,
                          fontWeight: FontWeight.bold,
                          color:      Color(0xFF1BA672)),
                      ),
                      Text(
                        AppConstants.storeTagline,
                        style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 14)),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Smooth Email Field
                SmoothTextField(
                  controller:   _emailCtrl,
                  label:        'Email Address',
                  prefixIcon:   Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter email';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Smooth Password Field
                SmoothTextField(
                  controller:  _passwordCtrl,
                  label:       'Password',
                  prefixIcon:  Icons.lock_outline,
                  obscureText: _obscure,
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

                // Animated Login Button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width:    double.infinity,
                  height:   55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1BA672),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                      elevation:       auth.isLoading ? 0 : 4,
                      shadowColor: Colors.green.shade300,
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

                // OTP Login Button
                SizedBox(
                  width:  double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    icon:  const Icon(Icons.phone_outlined,
                      color: Color(0xFF1BA672)),
                    label: const Text('Login with Phone (OTP)',
                      style: TextStyle(
                        color: Color(0xFF1BA672),
                        fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1BA672)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                    onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const OtpLoginScreen())),
                  ),
                ),

                const SizedBox(height: 16),

                // Demo admin box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:        Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border:       Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Column(children: [
                    Text('Demo Admin Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue)),
                    SizedBox(height: 4),
                    Text('Email: admin@grocery.com',
                      style: TextStyle(color: Colors.blue, fontSize: 13)),
                    Text('Password: Admin@123',
                      style: TextStyle(color: Colors.blue, fontSize: 13)),
                  ]),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen())),
                      child: const Text('Register Now',
                        style: TextStyle(
                          color:      Color(0xFF1BA672),
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
