import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grocery_local/app/theme/app_radius.dart';
import 'package:grocery_local/providers/cart_provider.dart';
import 'package:grocery_local/constants/app_constants.dart';
import 'package:grocery_local/screens/cart/cart_screen.dart';

class KohliFloatingCart extends StatelessWidget {
  const KohliFloatingCart({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cart = context.watch<CartProvider>();
    if (cart.itemCount == 0) return const SizedBox.shrink();

    return Positioned(
      bottom: 88,
      left: 16,
      right: 16,
      child: Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(AppRadius.bottomSheet),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.bottomSheet),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(AppRadius.bottomSheet),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Cart icon with badge
                Stack(
                  children: [
                    const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 28),
                    Positioned(
                      right: -6, top: -4,
                      child: Container(
                        width: 20, height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('${cart.itemCount}',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 11, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Product thumbnails (show first 3)
                SizedBox(
                  width: 60,
                  child: Row(
                    children: cart.items.take(3).map((item) {
                      return Container(
                        width: 24, height: 24,
                        margin: const EdgeInsets.only(right: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(item.product.displayImage.isNotEmpty
                              ? item.product.displayImage.substring(0, 1) : 'ðŸ›’',
                            style: const TextStyle(fontSize: 12)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8),
                // Cart info
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${cart.itemCount} item${cart.itemCount > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      Text('${AppConstants.currency}${cart.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                // Arrow
                const Row(
                  children: [
                    Text('View Cart',
                      style: TextStyle(
                        color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
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

