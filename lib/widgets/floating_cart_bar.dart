import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../constants/app_constants.dart';
import '../app/theme/theme.dart';
import '../screens/cart/cart_screen.dart';

class FloatingCartBar extends StatelessWidget {
  const FloatingCartBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    if (cart.itemCount == 0) return const SizedBox.shrink();

    return Positioned(
      bottom: 80, left: 12, right: 12,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: AppColors.primary,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CartScreen())),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Stack(
                  children: [
                    const Icon(Icons.shopping_basket,
                      color: Colors.white, size: 28),
                    Positioned(
                      right: -4, top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle),
                        child: Text('${cart.itemCount}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${cart.itemCount} items in cart',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                      Text('${AppConstants.currency}${cart.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12)),
                    ],
                  ),
                ),
                const Row(
                  children: [
                    Text('VIEW CART',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

