import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  static const coupons = [
    ['SAVE50', 'Flat ₹50 OFF', 'On orders above ₹499'],
    ['FREESHIP', 'Free Delivery', 'Free delivery above ₹299'],
    ['FIRST100', '₹100 Welcome Offer', 'For first order above ₹799'],
    ['GROCERY10', '10% OFF Groceries', 'Max discount ₹75'],
  ];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xfff6f7f9),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
          children: [
            const Text('Offers', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Save more on every grocery order', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xffff7a1a), Color(0xffffb703)]),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                children: [
                  Expanded(child: Text('Today’s Super Savings\nApply coupons and unlock deals', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900))),
                  Text('🎁', style: TextStyle(fontSize: 48)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ...coupons.map((c) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xffeeeeee)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(backgroundColor: Color(0xffe8f7ef), child: Icon(Icons.local_offer_rounded, color: Color(0xff0c8f43))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c[1], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(c[2], style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(c[0], style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: .6)),
                    ]),
                  ),
                  TextButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: c[0]));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${c[0]} copied')));
                    },
                    child: const Text('COPY', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xff0c8f43))),
                  ),
                ],
              ),
            )),
            if (cart.itemCount > 0)
              Text('Cart value: ₹${cart.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
