import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';
import '../constants/app_constants.dart';
import '../screens/product/product_detail_screen.dart';

class RecommendedProducts extends StatefulWidget {
  final String? excludeProductId;
  final String  title;
  const RecommendedProducts({
    super.key,
    this.excludeProductId,
    this.title = '🔥 Recommended for You',
  });

  @override
  State<RecommendedProducts> createState() => _RecommendedProductsState();
}

class _RecommendedProductsState extends State<RecommendedProducts> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadFeaturedProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductProvider>();
    final cart    = context.watch<CartProvider>();

    final recommended = product.featuredProducts
        .where((p) => p.id != widget.excludeProductId)
        .take(10)
        .toList();

    if (recommended.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title,
                style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: const Text('See All',
                  style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: recommended.length,
            itemBuilder: (context, index) {
              final p      = recommended[index];
              final inCart = cart.isInCart(p.id);
              final qty    = cart.getQuantity(p.id);

              return GestureDetector(
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: p))),
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 4,
                        offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Stack(
                          children: [
                            Center(
                              child: Text(p.displayImage,
                                style: const TextStyle(fontSize: 44)),
                            ),
                            if (p.hasDiscount)
                              Positioned(
                                top: 0, right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(6)),
                                  child: Text('${p.discount.toInt()}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold)),
                                ),
                              ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(p.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center),
                            Text(p.categoryName ?? '',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 10)),
                            const SizedBox(height: 2),
                            Text(
                              '${AppConstants.currency}${p.finalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                          ],
                        ),
                        inCart
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () => context
                                          .read<CartProvider>()
                                          .decreaseQuantity(p.id),
                                      child: const Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Icon(Icons.remove,
                                          color: Colors.green, size: 14)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                      child: Text('$qty',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12)),
                                    ),
                                    InkWell(
                                      onTap: () => context
                                          .read<CartProvider>()
                                          .increaseQuantity(p.id),
                                      child: const Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Icon(Icons.add,
                                          color: Colors.green, size: 14)),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    backgroundColor: Colors.green,
                                  ),
                                  onPressed: () =>
                                      context.read<CartProvider>().addItem(p),
                                  child: const Text('Add',
                                    style: TextStyle(fontSize: 12)),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
