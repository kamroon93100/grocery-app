import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/smooth_text_field.dart';
import 'package:grocery_local/screens/home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _confCtrl   = TextEditingController();
  bool  _obscure1   = true;
  bool  _obscure2   = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passCtrl.text != _confCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:         Text('Passwords do not match'),
          backgroundColor: Colors.red,
          behavior:        SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final auth   = context.read<AuthProvider>();
    final result = await auth.register(
      name:     _nameCtrl.text.trim(),
      email:    _emailCtrl.text.trim(),
      phone:    _phoneCtrl.text.trim(),
      password: _passCtrl.text.trim(),
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
          content:         Text(result['message'] ?? 'Registration failed'),
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
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),

              SmoothTextField(
                controller:   _nameCtrl,
                label:        'Full Name',
                prefixIcon:   Icons.person_outline,
                keyboardType: TextInputType.name,
                validator: (v) => v!.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 14),

              SmoothTextField(
                controller:   _emailCtrl,
                label:        'Email',
                prefixIcon:   Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => !v!.contains('@') ? 'Invalid email' : null,
              ),
              const SizedBox(height: 14),

              SmoothTextField(
                controller:   _phoneCtrl,
                label:        'Phone',
                prefixIcon:   Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.length < 10 ? 'Invalid phone' : null,
              ),
              const SizedBox(height: 14),

              SmoothTextField(
                controller:  _passCtrl,
                label:       'Password',
                prefixIcon:  Icons.lock_outline,
                obscureText: _obscure1,
                suffixIcon: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _obscure1
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      key: ValueKey(_obscure1),
                      color: Colors.grey.shade600,
                    ),
                  ),
                  onPressed: () => setState(() => _obscure1 = !_obscure1),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter password';
                  if (v.length < 6) return 'Min 6 characters';
                  if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Need uppercase letter';
                  if (!RegExp(r'[a-z]').hasMatch(v)) return 'Need lowercase letter';
                  if (!RegExp(r'[0-9]').hasMatch(v)) return 'Need a number';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              SmoothTextField(
                controller:  _confCtrl,
                label:       'Confirm Password',
                prefixIcon:  Icons.lock_outline,
                obscureText: _obscure2,
                suffixIcon: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _obscure2
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      key: ValueKey(_obscure2),
                      color: Colors.grey.shade600,
                    ),
                  ),
                  onPressed: () => setState(() => _obscure2 = !_obscure2),
                ),
                validator: (v) =>
                  v != _passCtrl.text ? 'Passwords do not match' : null,
              ),

              const SizedBox(height: 12),

              // Password requirements hint
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                          color: Colors.amber.shade800, size: 16),
                        const SizedBox(width: 6),
                        Text('Password must contain:',
                          style: TextStyle(
                            color: Colors.amber.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '• At least 6 characters\n• 1 uppercase (A-Z)\n• 1 lowercase (a-z)\n• 1 number (0-9)',
                      style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

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
                  onPressed: auth.isLoading ? null : _register,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: auth.isLoading
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 24, height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                        : const Text('Create Account',
                            key: ValueKey('text'),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

