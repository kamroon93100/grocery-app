import 'package:flutter/material.dart';

class AppNotification {
  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final String time;
  final bool unread;

  const AppNotification({
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
    required this.time,
    this.unread = false,
  });
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const items = [
    AppNotification(
      title: 'Order confirmed',
      body: 'Your grocery order has been confirmed and is being prepared.',
      icon: Icons.check_circle_outline_rounded,
      color: Color(0xff0c8f43),
      time: '2 min ago',
      unread: true,
    ),
    AppNotification(
      title: 'Fresh deals today',
      body: 'Save up to 20% on dairy, snacks and daily essentials.',
      icon: Icons.local_offer_outlined,
      color: Color(0xffff7a1a),
      time: '15 min ago',
      unread: true,
    ),
    AppNotification(
      title: 'Delivery update',
      body: 'Your order will arrive in 10–15 minutes after dispatch.',
      icon: Icons.delivery_dining_rounded,
      color: Color(0xff2563eb),
      time: '1 hr ago',
    ),
    AppNotification(
      title: 'Wallet cashback',
      body: 'You earned cashback on your last order.',
      icon: Icons.account_balance_wallet_outlined,
      color: Color(0xff7c3aed),
      time: 'Yesterday',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7f9),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Notifications', style: TextStyle(fontSize: 32, height: 1, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text('Order updates, offers and account alerts', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xff0c8f43), Color(0xff19b46b)]),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Never miss delivery updates or fresh offers',
                              style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900),
                            ),
                          ),
                          Icon(Icons.notifications_active_rounded, color: Colors.white, size: 42),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              sliver: SliverList.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _NotificationCard(item: items[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification item;
  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.unread ? const Color(0xffffffff) : const Color(0xfffbfbfb),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: item.unread ? const Color(0xffd1f2df) : const Color(0xffeeeeee)),
        boxShadow: const [BoxShadow(color: Color(0x0d000000), blurRadius: 24, spreadRadius: -6, offset: Offset(0, 10))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: item.color.withOpacity(.12),
                child: Icon(item.icon, color: item.color),
              ),
              if (item.unread)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xff111827))),
                const SizedBox(height: 5),
                Text(item.body, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600, height: 1.35)),
                const SizedBox(height: 8),
                Text(item.time, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

