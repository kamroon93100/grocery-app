import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../constants/app_constants.dart';
import '../home/home_screen.dart';

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

  bool   _otpSent      = false;
  bool   _isLoading    = false;
  String _displayOtp   = '';
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
        _otpSent    = true;
        _displayOtp = result['data']['otp']?.toString() ?? '';
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
        _displayOtp    = result['data']['otp']?.toString() ?? '';
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
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green),
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
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color:        Colors.green,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.green.shade200, blurRadius: 20),
                  ],
                ),
                child: Icon(
                  _otpSent ? Icons.lock_outlined : Icons.phone_outlined,
                  size: 70, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(AppConstants.storeName,
                style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold,
                  color: Colors.green)),
              Text(_otpSent ? 'Verify OTP' : 'Login with Phone',
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 40),

              if (!_otpSent) ...[
                // Phone input
                TextField(
                  controller:   _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength:    10,
                  decoration: InputDecoration(
                    labelText:  'Phone Number',
                    hintText:   '10 digits',
                    prefixIcon: const Icon(Icons.phone_outlined, color: Colors.green),
                    prefixText: '+91 ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true, fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendOTP,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Send OTP',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else ...[
                // OTP Verification
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    children: [
                      Text('OTP sent to +91 ${_phoneCtrl.text}',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      if (_displayOtp.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Demo OTP: $_displayOtp',
                          style: const TextStyle(
                            color: Colors.orange, fontSize: 14,
                            fontWeight: FontWeight.bold)),
                        const Text('(Only for testing - SMS in production)',
                          style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller:   _otpCtrl,
                  keyboardType: TextInputType.number,
                  maxLength:    6,
                  textAlign:    TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Enter 6-digit OTP',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true, fillColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),
                const Text('First time? Add details (optional):',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 10),

                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Your Name',
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.green),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true, fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller:   _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Your Email',
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.green),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true, fillColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOTP,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Verify & Login',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                          color: _resendSeconds > 0 ? Colors.grey : Colors.green,
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
