import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_constants.dart';

class ReferScreen extends StatelessWidget {
  const ReferScreen({super.key});

  String _getReferralCode(String userId) {
    if (userId.isEmpty) return 'GROCERY100';
    final part = userId.replaceAll('-', '').substring(0, 6).toUpperCase();
    return 'REF$part';
  }

  String _shareText(String code) {
    return '''
ðŸ›’ Get FREE Grocery Delivery!

I'm using ${AppConstants.storeName} for fresh groceries.
Use my code: *$code* to get ${AppConstants.currency}10 off your first order!

âœ… Cash on Delivery
âœ… Fresh products
âœ… Express delivery (30-45 mins)
âœ… Free delivery above ${AppConstants.currency}${AppConstants.freeDeliveryAbove.toInt()}

Download the app now!
    ''';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final code = _getReferralCode(auth.userId);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Refer & Earn'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gradient Header
            Container(
              width:   double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin:  Alignment.topLeft,
                  end:    Alignment.bottomRight,
                  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.card_giftcard,
                      size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text('Refer & Earn',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    'Give ${AppConstants.currency}10, Get ${AppConstants.currency}10',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  const Text(
                    'Invite friends and earn rewards',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Stats Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _statCard(
                    Icons.people_outline, 'Friends Invited', '0', Colors.blue)),
                  const SizedBox(width: 10),
                  Expanded(child: _statCard(
                    Icons.attach_money, 'Earned', '${AppConstants.currency}0', Colors.green)),
                  const SizedBox(width: 10),
                  Expanded(child: _statCard(
                    Icons.account_balance_wallet, 'Pending', '${AppConstants.currency}0', Colors.orange)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Your Code Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade200, blurRadius: 10),
                  ],
                ),
                child: Column(
                  children: [
                    Text('YOUR REFERRAL CODE',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green,
                          width: 2,
                          style: BorderStyle.solid),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(code,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              letterSpacing: 3)),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: code));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Code copied!'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 1)));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.copy,
                                color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width:  double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.share),
                        label: Text('Share & Earn ${AppConstants.currency}10',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Share.share(_shareText(code),
                            subject: 'Get FREE Grocery Delivery!');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Share Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quick Share',
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _shareButton(
                          icon: Icons.message,
                          label: 'WhatsApp',
                          color: const Color(0xFF25D366),
                          onTap: () => Share.share(_shareText(code)),
                        ),
                        _shareButton(
                          icon: Icons.email,
                          label: 'Email',
                          color: Colors.red,
                          onTap: () => Share.share(_shareText(code)),
                        ),
                        _shareButton(
                          icon: Icons.message_outlined,
                          label: 'SMS',
                          color: Colors.blue,
                          onTap: () => Share.share(_shareText(code)),
                        ),
                        _shareButton(
                          icon: Icons.more_horiz,
                          label: 'More',
                          color: Colors.purple,
                          onTap: () => Share.share(_shareText(code)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // How It Works
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('How It Works',
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _step('1', 'ðŸ“¤', 'Share your code',
                      'Send your referral code to friends'),
                    _step('2', 'ðŸ›ï¸', 'Friend uses your code',
                      'They get ${AppConstants.currency}10 off on first order'),
                    _step('3', 'ðŸ’°', 'You earn ${AppConstants.currency}10',
                      'Credit added to your wallet'),
                    _step('4', 'ðŸŽ‰', 'Both win!',
                      'Use credits on your next order'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Terms
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                          color: Colors.amber.shade800, size: 18),
                        const SizedBox(width: 6),
                        Text('Terms & Conditions',
                          style: TextStyle(
                            color: Colors.amber.shade800,
                            fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'â€¢ Friend must place first order to earn reward\n'
                      'â€¢ Reward credited after order delivery\n'
                      'â€¢ Max 20 referrals per month\n'
                      'â€¢ Rewards cannot be transferred to cash',
                      style: TextStyle(fontSize: 11, height: 1.5)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(
            fontSize: 10, color: Colors.grey.shade600),
            textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _shareButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _step(String num, String emoji, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(num,
                style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
                Text(desc, style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

