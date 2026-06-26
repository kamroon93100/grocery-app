import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool  _obscure      = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
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
                Container(
                  padding:    const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color:        Colors.green,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.green.shade200, blurRadius: 20),
                    ],
                  ),
                  child: const Icon(Icons.store_rounded, size: 70, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text('Local Grocery Store',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green)),
                const Text('Sign in to continue',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 40),
                TextFormField(
                  controller:  _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText:  'Email Address',
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.green),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter email';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller:  _passwordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText:  'Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.green),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
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
                    onPressed: auth.isLoading ? null : _login,
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Login',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:    const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:        Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border:       Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Column(children: [
                    Text('Demo Admin Login',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    SizedBox(height: 4),
                    Text('Email: admin@grocery.com',
                      style: TextStyle(color: Colors.blue, fontSize: 13)),
                    Text('Password: Admin@123',
                      style: TextStyle(color: Colors.blue, fontSize: 13)),
                  ]),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      ),
                      child: const Text('Register Now',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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
