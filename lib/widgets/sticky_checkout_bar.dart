import 'package:flutter/material.dart';

class StickyCheckoutBar extends StatelessWidget {
  final double total;
  final VoidCallback onCheckout;

  const StickyCheckoutBar({
    super.key,
    required this.total,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xffeeeeee)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1a000000),
              blurRadius: 28,
              spreadRadius: -8,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'To Pay',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '₹${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: Color(0xff111827),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 176,
              height: 52,
              child: ElevatedButton(
                onPressed: onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0c8f43),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text(
                  'Checkout',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

