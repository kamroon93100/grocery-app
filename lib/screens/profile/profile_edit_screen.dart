import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});
  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey   = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  bool _isLoading  = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameCtrl  = TextEditingController(text: auth.userName);
    _phoneCtrl = TextEditingController(text: auth.userPhone);
    _emailCtrl = TextEditingController(text: auth.userEmail);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await AuthService().updateProfile(
      _nameCtrl.text.trim(),
      _phoneCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      await context.read<AuthProvider>().checkAuth();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:         Text('✅ Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Update failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius:          55,
                    backgroundColor: Colors.green,
                    child: Text(
                      auth.userName.isNotEmpty
                          ? auth.userName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize:   45,
                        color:      Colors.white,
                        fontWeight: FontWeight.bold)),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color:        Colors.green,
                        shape:        BoxShape.circle,
                        border:       Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(auth.userRole.toUpperCase(),
                style: TextStyle(
                  color:      Colors.grey.shade600,
                  fontSize:   12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5)),
            ),
            const SizedBox(height: 30),

            // Personal Info Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.person_outline, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Personal Information',
                          style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText:  'Full Name',
                        prefixIcon: const Icon(Icons.badge_outlined,
                          color: Colors.green),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller:   _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText:  'Phone Number',
                        prefixIcon: const Icon(Icons.phone_outlined,
                          color: Colors.green),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) =>
                          v!.length < 10 ? 'Invalid phone' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailCtrl,
                      enabled:    false,
                      decoration: InputDecoration(
                        labelText:  'Email (cannot change)',
                        prefixIcon: const Icon(Icons.email_outlined,
                          color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                        fillColor: Colors.grey.shade50,
                        filled:    true,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Save Button
            SizedBox(
              width:  double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon:  _isLoading
                    ? const SizedBox(
                        width:  20, height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Saving...' : 'Save Changes',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: _isLoading ? null : _saveProfile,
              ),
            ),

            const SizedBox(height: 12),

            // Cancel button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                  style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

