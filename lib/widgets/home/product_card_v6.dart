import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../screens/product/product_detail_screen.dart';

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

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xffeeeeee)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0f000000),
                blurRadius: 20,
                spreadRadius: -4,
                offset: Offset(0, 8),
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
                          padding: const EdgeInsets.only(top: 12, left: 4, right: 4),
                          child: Image.network(
  product.displayImage,
  width: double.infinity,
  height: double.infinity,
  fit: BoxFit.contain,
  filterQuality: FilterQuality.high,
  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
    if (wasSynchronouslyLoaded) return child;
    return AnimatedOpacity(
      opacity: frame == null ? 0 : 1,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      child: child,
    );
  },
  loadingBuilder: (context, child, progress) {
    if (progress == null) return child;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfff1f3f5),
        borderRadius: BorderRadius.circular(18),
      ),
    );
  },
  errorBuilder: (_, __, ___) =>
      const Text('🛒', style: TextStyle(fontSize: 42)),
),                        ),
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
                        child: Icon(Icons.favorite_border_rounded, size: 21, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                    color: Color(0xff151922),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.unit,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (product.rating > 0)
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Color(0xffffb703)),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Text(
                      '${AppConstants.currency}${sellingPrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(width: 6),
                    if (product.discount > 0)
                      Text(
                        '${AppConstants.currency}${mrp.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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
                          onPressed: () {
  cart.addItem(product);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${product.name} added to cart'),
      duration: const Duration(milliseconds: 700),
      backgroundColor: const Color(0xff0c8f43),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
},                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xff0c8f43),
                            side: const BorderSide(color: Color(0xff0c8f43), width: 1.3),
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
        ),
      ),
    );
  }
}




