import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../address/address_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../refer/refer_screen.dart';
import '../orders/orders_screen.dart';
import 'profile_edit_screen.dart';
import '../../constants/app_constants.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/color_scheme_ext.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme/app_radius.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

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
              controller: _oldPassCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPassCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
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
                        ? 'Password changed!' : result['message'] ?? 'Failed'),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Premium Header with light tint
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 24),
              decoration: BoxDecoration(
                color: colorScheme.softSurface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.bottomSheet),
                  bottomRight: Radius.circular(AppRadius.bottomSheet),
                ),
              ),
              child: Column(
                children: [
                  // Back, Help, More row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40),
                      Icon(Icons.help_outline_rounded,
                        color: colorScheme.textMuted, size: 22),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Avatar
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: colorScheme.primary,
                        child: Text(
                          auth.userName.isNotEmpty
                              ? auth.userName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 40, color: Colors.white,
                            fontWeight: FontWeight.bold)),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: GestureDetector(
                          onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: colorScheme.surface, width: 3),
                            ),
                            child: const Icon(Icons.edit,
                              color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(auth.userName,
                    style: AppTextStyles.h2(color: colorScheme.textPrimary)),
                  Text(auth.userEmail,
                    style: AppTextStyles.caption(color: colorScheme.textMuted)),
                  const SizedBox(height: 12),
                  // Member card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.primaryButton),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_rounded,
                          color: colorScheme.primary, size: 18),
                        const SizedBox(width: 8),
                        Text('Wallet: ${AppConstants.currency}${auth.wallet.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Quick action tiles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _actionTile(context, Icons.location_on_outlined,
                    'Saved\nAddress', Colors.blue, () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AddressScreen())))),
                  const SizedBox(width: 10),
                  Expanded(child: _actionTile(context, Icons.credit_card_outlined,
                    'Payment\nModes', Colors.green, null)),
                  const SizedBox(width: 10),
                  Expanded(child: _actionTile(context, Icons.replay_outlined,
                    'Refunds', Colors.orange, null)),
                  const SizedBox(width: 10),
                  Expanded(child: _actionTile(context, Icons.account_balance_wallet_outlined,
                    'Wallet', Colors.purple, null)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Menu list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _menuCard(context, Icons.receipt_long_outlined, Colors.green, 'My Orders', 'Track & manage your orders', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()))),
                    const SizedBox(height: 8),
                    _menuCard(context, Icons.card_giftcard_outlined, Colors.purple,
                    'Refer & Earn', 'Get rewards for each friend',
                    () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ReferScreen()))),
                  const SizedBox(height: 8),
                  _menuCard(context, Icons.favorite_outlined, Colors.red,
                    'My Wishlist', 'Your saved products',
                    () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const WishlistScreen()))),
                  const SizedBox(height: 8),
                  _menuCard(context, Icons.description_outlined, Colors.teal,
                    'Statements', 'Order history & invoices', null),
                  const SizedBox(height: 8),
                  _menuCard(context, Icons.star_outline, Colors.amber,
                    'Rewards', 'Your loyalty points', null),
                  const SizedBox(height: 8),
                  _menuCard(context, Icons.edit_outlined, Colors.blue,
                    'Edit Profile', 'Update your information',
                    () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ProfileEditScreen()))),
                  const SizedBox(height: 8),
                  _menuCard(context, Icons.lock_outlined, Colors.orange,
                    'Change Password', 'Update your password',
                    () => _changePassword(context, auth)),
                  const SizedBox(height: 8),
                  _menuCard(context, Icons.description_outlined, Colors.indigo,
                    'Privacy Policy', 'How we handle your data',
                    () => _openUrl('https://kohlistore.com/privacy')),
                  const SizedBox(height: 8),
                  _menuCard(context, Icons.article_outlined, Colors.indigo,
                    'Terms of Service', 'Terms & conditions',
                    () => _openUrl('https://kohlistore.com/terms')),
                  const SizedBox(height: 16),
                  // App version
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('App Version: v2.0.0',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption(color: colorScheme.textMuted)),
                  ),
                  const SizedBox(height: 12),
                  // Logout
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.danger,
                        side: BorderSide(color: colorScheme.danger),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.primaryButton)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Logout',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

  Widget _actionTile(BuildContext context, IconData icon, String title,
      Color color, VoidCallback? onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: colorScheme.card,
          borderRadius: BorderRadius.circular(AppRadius.primaryButton),
          border: Border.all(color: colorScheme.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: colorScheme.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(BuildContext context, IconData icon, Color color,
      String title, String subtitle, VoidCallback? onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.card,
        borderRadius: BorderRadius.circular(AppRadius.primaryButton),
        border: Border.all(color: colorScheme.border),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title,
          style: TextStyle(
            fontWeight: FontWeight.w600, fontSize: 14,
            color: colorScheme.textPrimary)),
        subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: colorScheme.textMuted)),
        trailing: onTap != null
            ? Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: colorScheme.textMuted)
            : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}

