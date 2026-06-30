import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../constants/app_constants.dart';
import '../../widgets/smooth_text_field.dart';
import 'package:grocery_local/screens/home/home_screen.dart';

class OtpLoginScreen extends StatefulWidget {
  const OtpLoginScreen({super.key});
  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl   = TextEditingController();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool   _otpSent       = false;
  bool   _isLoading     = false;
  int    _resendSeconds = 0;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (_phoneCtrl.text.length < 10) {
      _showError('Enter valid 10-digit phone number');
      return;
    }
    setState(() => _isLoading = true);
    final result = await context.read<AuthProvider>().sendOTP(_phoneCtrl.text.trim());
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      setState(() {
        _otpSent       = true;
        _resendSeconds = 30;
      });
      _startResendTimer();
      _showSuccess('OTP sent successfully');
    } else {
      _showError(result['message'] ?? 'Failed to send OTP');
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpCtrl.text.length != 6) {
      _showError('Enter 6-digit OTP');
      return;
    }
    setState(() => _isLoading = true);
    final result = await context.read<AuthProvider>().verifyOTP(
      phone: _phoneCtrl.text.trim(),
      otp:   _otpCtrl.text.trim(),
      name:  _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : null,
      email: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      context.read<ProductProvider>().loadCategories();
      context.read<ProductProvider>().loadProducts();
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      _showError(result['message'] ?? 'Invalid OTP');
    }
  }

  Future<void> _resendOTP() async {
    if (_resendSeconds > 0) return;
    setState(() => _isLoading = true);
    final result = await context.read<AuthProvider>().resendOTP(_phoneCtrl.text.trim());
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      setState(() {
        _resendSeconds = 30;
      });
      _startResendTimer();
      _showSuccess('OTP resent successfully');
    }
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || _resendSeconds == 0) return;
      setState(() => _resendSeconds--);
      _startResendTimer();
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        behavior:        SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green,
        behavior:        SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    _otpSent ? Icons.lock_outlined : Icons.phone_outlined,
                    key: ValueKey(_otpSent),
                    size: 70,
                    color: Colors.white),
                ),
              ),

              const SizedBox(height: 24),

              Text(AppConstants.storeName,
                style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold,
                  color: Color(0xFF1BA672))),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(_otpSent ? 'Verify OTP' : 'Login with Phone',
                  key: ValueKey(_otpSent),
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ),

              const SizedBox(height: 40),

              if (!_otpSent) ...[
                SmoothTextField(
                  controller:   _phoneCtrl,
                  label:        'Phone Number',
                  prefixIcon:   Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1BA672),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                    onPressed: _isLoading ? null : _sendOTP,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5)
                        : const Text('Send OTP',
                            style: TextStyle(fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade200)),
                  child: Column(
                    children: [
                      Text('OTP sent to +91 ${_phoneCtrl.text}',
                        style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                SmoothTextField(
                  controller:   _otpCtrl,
                  label:        'Enter 6-digit OTP',
                  prefixIcon:   Icons.lock_outline,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 10),
                const Text('First time? Add details (optional):',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 10),

                SmoothTextField(
                  controller: _nameCtrl,
                  label:      'Your Name',
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 10),
                SmoothTextField(
                  controller:   _emailCtrl,
                  label:        'Your Email',
                  prefixIcon:   Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1BA672),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                    onPressed: _isLoading ? null : _verifyOTP,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5)
                        : const Text('Verify & Login',
                            style: TextStyle(fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Didn't receive OTP?"),
                    TextButton(
                      onPressed: _resendSeconds > 0 ? null : _resendOTP,
                      child: Text(
                        _resendSeconds > 0
                            ? 'Resend in ${_resendSeconds}s'
                            : 'Resend OTP',
                        style: TextStyle(
                          color: _resendSeconds > 0
                              ? Colors.grey : const Color(0xFF1BA672),
                          fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                TextButton.icon(
                  icon:  const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Change phone number'),
                  onPressed: () => setState(() {
                    _otpSent = false;
                    _otpCtrl.clear();
                  }),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


