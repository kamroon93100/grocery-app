import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';

class ProductCardV6 extends StatelessWidget {
  final ProductModel product;

  const ProductCardV6({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final sellingPrice = product.price;
    final mrp = product.discount > 0
        ? sellingPrice / (1 - product.discount / 100)
        : sellingPrice;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffeeeeee)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 24,
            spreadRadius: -4,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Image.network(
                        product.displayImage,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (_, __, ___) =>
                            const Text('🛒', style: TextStyle(fontSize: 42)),
                      ),
                    ),
                  ),
                  if (product.discount > 0)
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xffffefe6),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${product.discount.toStringAsFixed(0)}% OFF',
                          style: const TextStyle(
                            color: Color(0xffd9480f),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  const Positioned(
                    right: 0,
                    top: 0,
                    child: Icon(Icons.favorite_border_rounded, size: 20, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, height: 1.15),
            ),
            const SizedBox(height: 4),
            Text(
              product.unit,
              style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Text(
                  '${AppConstants.currency}${sellingPrice.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(width: 6),
                if (product.discount > 0)
                  Text(
                    '${AppConstants.currency}${mrp.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Consumer<CartProvider>(
              builder: (context, cart, _) {
                final qty = cart.getQuantity(product.id);

                if (qty <= 0) {
                  return SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: OutlinedButton(
                      onPressed: () => cart.addItem(product),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xff0c8f43),
                        side: const BorderSide(color: Color(0xff0c8f43), width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('ADD', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  );
                }

                return Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xff0c8f43),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => cart.decreaseQuantity(product.id),
                          child: const Center(child: Icon(Icons.remove, color: Colors.white, size: 18)),
                        ),
                      ),
                      Text('$qty', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                      Expanded(
                        child: InkWell(
                          onTap: () => cart.increaseQuantity(product.id),
                          child: const Center(child: Icon(Icons.add, color: Colors.white, size: 18)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

