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

  Widget row(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0,4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Bill Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          row('Items Total', '₹${subtotal.toStringAsFixed(0)}'),
          row('Delivery Fee', delivery == 0 ? 'FREE' : '₹${delivery.toStringAsFixed(0)}'),
          row('Taxes', '₹${tax.toStringAsFixed(0)}'),
          const Divider(height: 28),
          row('Grand Total', '₹${total.toStringAsFixed(0)}', bold: true),
        ],
      ),
    );
  }
}
