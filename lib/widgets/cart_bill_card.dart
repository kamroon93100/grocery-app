import 'package:flutter/material.dart';

class CartBillCard extends StatelessWidget {
  final double subtotal;
  final double delivery;
  final double tax;
  final double total;

  const CartBillCard({
    super.key,
    required this.subtotal,
    required this.delivery,
    required this.tax,
    required this.total,
  });

  Widget row(String title, String value, {bool bold = false, bool green = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: bold ? const Color(0xff111827) : Colors.grey.shade700,
              fontSize: bold ? 16 : 14,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: green ? const Color(0xff0c8f43) : const Color(0xff111827),
              fontSize: bold ? 17 : 14,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffeeeeee)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0d000000),
            blurRadius: 24,
            spreadRadius: -6,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: Color(0xff0c8f43)),
              SizedBox(width: 8),
              Text(
                'Bill Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xff111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          row('Items Total', '₹${subtotal.toStringAsFixed(0)}'),
          row('Delivery Fee', delivery == 0 ? 'FREE' : '₹${delivery.toStringAsFixed(0)}', green: delivery == 0),
          row('Taxes', '₹${tax.toStringAsFixed(0)}'),
          const Divider(height: 28),
          row('Grand Total', '₹${total.toStringAsFixed(0)}', bold: true),
        ],
      ),
    );
  }
}

