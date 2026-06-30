import 'package:flutter/material.dart';

class KohliDiscountBadge extends StatelessWidget {
  final double discount;

  const KohliDiscountBadge({
    super.key,
    required this.discount,
  });

  @override
  Widget build(BuildContext context) {
    if (discount <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xffffefe6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${discount.toStringAsFixed(0)}% OFF',
        style: const TextStyle(
          color: Color(0xffd9480f),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}


