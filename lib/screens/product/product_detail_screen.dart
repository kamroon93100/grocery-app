import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../cart/cart_screen.dart';
import '../../widgets/reviews_section.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final p     = widget.product;
    final cart  = context.watch<CartProvider>();
    final inCart = cart.isInCart(p.id);
    final qty    = cart.getQuantity(p.id);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 280,
            pinned:         true,
            backgroundColor: Colors.green,
            actions: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined,
                      color: Colors.white),
                    onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CartScreen())),
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 4, top: 4,
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: Colors.red,
                        child: Text('${cart.itemCount}',
                          style: const TextStyle(fontSize: 10,
                            color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end:   Alignment.bottomCenter,
                    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Hero(
                        tag: 'product_${p.id}',
                        child: Text(p.displayImage,
                          style: const TextStyle(fontSize: 130)),
                      ),
                    ),
                    if (p.hasDiscount)
                      Positioned(
                        top: 90, right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color:        Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('${p.discount.toInt()}% OFF',
                            style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft:  Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Stock
                  Row(
                    children: [
                      Expanded(
                        child: Text(p.name,
                          style: const TextStyle(fontSize: 26,
                            fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: p.inStock
                              ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: p.inStock ? Colors.green : Colors.red),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              p.inStock
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              size:  14,
                              color: p.inStock ? Colors.green : Colors.red),
                            const SizedBox(width: 4),
                            Text(
                              p.inStock ? 'In Stock' : 'Out of Stock',
                              style: TextStyle(
                                color:      p.inStock ? Colors.green : Colors.red,
                                fontSize:   11,
                                fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Category + Stock count
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color:        Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${p.categoryIcon ?? ""} ${p.categoryName ?? ""}',
                          style: const TextStyle(
                            color: Colors.green, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      if (p.inStock)
                        Text('${p.stock} available',
                          style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Rating
                  Row(
                    children: [
                      ...List.generate(5, (i) =>
                        Icon(Icons.star,
                          size:  20,
                          color: i < p.rating.round()
                              ? Colors.amber : Colors.grey.shade300)),
                      const SizedBox(width: 8),
                      Text('${p.rating.toStringAsFixed(1)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Text('(${p.reviewCount} reviews)',
                        style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),

                  const Divider(height: 32),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('\$${p.finalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 32,
                          fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(width: 8),
                      if (p.hasDiscount)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text('\$${p.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                              decoration: TextDecoration.lineThrough)),
                        ),
                      const SizedBox(width: 8),
                      if (p.hasDiscount)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text('per ${p.unit}',
                            style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 12)),
                        ),
                    ],
                  ),

                  if (p.hasDiscount) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color:        Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'You save \$${(p.price - p.finalPrice).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                  ],

                  const Divider(height: 32),

                  // Description
                  const Text('Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    p.description.isNotEmpty
                        ? p.description
                        : 'Fresh ${p.name} - Quality guaranteed. '
                          'Sourced from local farms and delivered fresh '
                          'to your doorstep.',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize:   14,
                      height:     1.6)),

                  const Divider(height: 32),

                  // Reviews Section
                  ReviewsSection(
                    productId:     p.id,
                    averageRating: p.rating,
                    totalReviews:  p.reviewCount,
                  ),
                  const Divider(height: 32),

                  // Features
                  const Text('Why Choose Us',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _feature(Icons.local_shipping_outlined,
                    'Fast Delivery', 'Within 30-45 minutes'),
                  _feature(Icons.verified_outlined,
                    'Quality Assured', '100% Fresh Products'),
                  _feature(Icons.money_outlined,
                    'Cash on Delivery', 'Pay when you receive'),
                  _feature(Icons.replay_outlined,
                    'Easy Returns', 'Not happy? Return it'),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Add to Cart
      bottomNavigationBar: !p.inStock
          ? Container(
              padding: const EdgeInsets.all(16),
              color:   Colors.white,
              child: const SizedBox(
                height: 55,
                child: Center(
                  child: Text('Out of Stock',
                    style: TextStyle(
                      color:      Colors.red,
                      fontSize:   18,
                      fontWeight: FontWeight.bold)),
                ),
              ),
            )
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, blurRadius: 10)],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Quantity selector
                    Container(
                      decoration: BoxDecoration(
                        color:        Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border:       Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: Colors.green),
                            onPressed: () => setState(() {
                              if (_quantity > 1) _quantity--;
                            }),
                          ),
                          SizedBox(
                            width: 30,
                            child: Text('$_quantity',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.green),
                            onPressed: () => setState(() {
                              if (_quantity < p.stock) _quantity++;
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Add to cart button
                    Expanded(
                      child: SizedBox(
                        height: 55,
                        child: ElevatedButton.icon(
                          icon: Icon(inCart
                              ? Icons.check_circle
                              : Icons.shopping_cart_outlined),
                          label: Text(
                            inCart
                                ? 'In Cart ($qty)  •  \$${(p.finalPrice * _quantity).toStringAsFixed(2)}'
                                : 'Add to Cart  •  \$${(p.finalPrice * _quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            for (int i = 0; i < _quantity; i++) {
                              context.read<CartProvider>().addItem(p);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '$_quantity x ${p.name} added to cart'),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _feature(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:        Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

