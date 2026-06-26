import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../home/home_screen.dart';

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
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _phoneCtrl.dispose(); _passCtrl.dispose(); _confCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passCtrl.text != _confCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'),
          backgroundColor: Colors.red),
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
        SnackBar(content: Text(result['message'] ?? 'Registration failed'),
          backgroundColor: Colors.red),
      );
    }
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
    TextInputType type, String? Function(String?)? validator,
    {bool obscure = false, Widget? suffix}) {
    return TextFormField(
      controller:  ctrl,
      keyboardType: type,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText:  label,
        prefixIcon: Icon(icon, color: Colors.green),
        suffixIcon: suffix,
      ),
      validator: validator,
    );
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
              _field(_nameCtrl, 'Full Name', Icons.person_outline,
                TextInputType.name,
                (v) => v!.isEmpty ? 'Enter name' : null),
              const SizedBox(height: 14),
              _field(_emailCtrl, 'Email', Icons.email_outlined,
                TextInputType.emailAddress,
                (v) => !v!.contains('@') ? 'Invalid email' : null),
              const SizedBox(height: 14),
              _field(_phoneCtrl, 'Phone', Icons.phone_outlined,
                TextInputType.phone,
                (v) => v!.length < 10 ? 'Invalid phone' : null),
              const SizedBox(height: 14),
              _field(_passCtrl, 'Password', Icons.lock_outline,
                TextInputType.text,
                (v) => v!.length < 6 ? 'Min 6 chars' : null,
                obscure: _obscure1,
                suffix: IconButton(
                  icon: Icon(_obscure1
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscure1 = !_obscure1),
                )),
              const SizedBox(height: 14),
              _field(_confCtrl, 'Confirm Password', Icons.lock_outline,
                TextInputType.text,
                (v) => v != _passCtrl.text ? 'Passwords do not match' : null,
                obscure: _obscure2,
                suffix: IconButton(
                  icon: Icon(_obscure2
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscure2 = !_obscure2),
                )),
              const SizedBox(height: 24),
              SizedBox(
                width:  double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _register,
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create Account',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
