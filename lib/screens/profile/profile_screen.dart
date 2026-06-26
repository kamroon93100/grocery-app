import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../address/address_screen.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  void _changePassword(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.green),
            SizedBox(width: 10),
            Text('Change Password'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller:  _oldPassCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText:  'Current Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller:  _newPassCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText:  'New Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _oldPassCtrl.clear();
              _newPassCtrl.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_newPassCtrl.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Min 6 characters'),
                    backgroundColor: Colors.red),
                );
                return;
              }
              final result = await auth.changePassword(
                _oldPassCtrl.text.trim(),
                _newPassCtrl.text.trim(),
              );
              Navigator.pop(context);
              _oldPassCtrl.clear();
              _newPassCtrl.clear();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['success'] == true
                        ? '✅ Password changed!' : result['message'] ?? 'Failed'),
                    backgroundColor: result['success'] == true
                        ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Edit Button
            Container(
              width:   double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end:   Alignment.bottomRight,
                  colors: [Colors.green, Color(0xFF66BB6A)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius:          50,
                        backgroundColor: Colors.white,
                        child: Text(
                          auth.userName.isNotEmpty
                              ? auth.userName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize:   45,
                            color:      Colors.green,
                            fontWeight: FontWeight.bold)),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: GestureDetector(
                          onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color:  Colors.white,
                              shape:  BoxShape.circle,
                              border: Border.all(color: Colors.green, width: 2),
                            ),
                            child: const Icon(Icons.edit,
                              color: Colors.green, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(auth.userName,
                    style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold,
                      color: Colors.white)),
                  Text(auth.userEmail,
                    style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color:        Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(auth.userRole.toUpperCase(),
                          style: const TextStyle(
                            color:      Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize:   11)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color:        Colors.green.shade700,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Wallet: \$${auth.wallet.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color:      Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize:   11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    icon:  const Icon(Icons.edit, color: Colors.white, size: 16),
                    label: const Text('Edit Profile',
                      style: TextStyle(color: Colors.white)),
                    onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _statCard(Icons.receipt_long_outlined,
                    'Orders', '12', Colors.blue)),
                  const SizedBox(width: 10),
                  Expanded(child: _statCard(Icons.favorite_outline,
                    'Favorites', '8', Colors.red)),
                  const SizedBox(width: 10),
                  Expanded(child: _statCard(Icons.discount_outlined,
                    'Coupons', '5', Colors.orange)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _section('Account'),
                  _tile(Icons.edit_outlined, Colors.blue,
                    'Edit Profile', 'Update your information',
                    () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ProfileEditScreen()))),
                  _tile(Icons.location_on_outlined, Colors.red,
                    'My Addresses', 'Manage delivery addresses',
                    () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AddressScreen()))),
                  _tile(Icons.lock_outline, Colors.orange,
                    'Change Password', 'Update your password',
                    () => _changePassword(context, auth)),

                  const SizedBox(height: 16),
                  _section('Information'),
                  _tile(Icons.phone_outlined, Colors.teal,
                    'Phone',
                    auth.userPhone.isNotEmpty ? auth.userPhone : 'Not set',
                    null),
                  _tile(Icons.security_outlined, Colors.purple,
                    'Security', 'JWT + SHA256 Encrypted', null),
                  _tile(Icons.storage_outlined, Colors.indigo,
                    'Database', 'PostgreSQL + Redis', null),
                  _tile(Icons.info_outline, Colors.grey,
                    'App Version', 'v2.0.0 - Full Stack', null),

                  const SizedBox(height: 20),
                  SizedBox(
                    width:  double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      ),
                      icon:  const Icon(Icons.logout),
                      label: const Text('Logout',
                        style: TextStyle(fontSize: 18)),
                      onPressed: () async {
                        await auth.logout();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title,
          style: TextStyle(
            color:      Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize:   13,
            letterSpacing: 1.2)),
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, Color color, String title,
    String subtitle, VoidCallback? onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title:    Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: onTap != null
            ? const Icon(Icons.arrow_forward_ios, size: 16)
            : null,
        onTap: onTap,
      ),
    );
  }
}
