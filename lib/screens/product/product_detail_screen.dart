import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import 'package:grocery_local/screens/cart/cart_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final p = product;
    final sellingPrice = p.price;
    final mrp = p.discount > 0 ? sellingPrice / (1 - p.discount / 100) : sellingPrice;

    return Scaffold(
      backgroundColor: const Color(0xfff6f7f9),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                    child: Row(
                      children: [
                        _CircleIcon(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        Consumer<CartProvider>(
                          builder: (context, cart, _) {
                            return Stack(
                              children: [
                                _CircleIcon(
                                  icon: Icons.shopping_bag_outlined,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const CartScreen()),
                                  ),
                                ),
                                if (cart.itemCount > 0)
                                  Positioned(
                                    right: 2,
                                    top: 2,
                                    child: CircleAvatar(
                                      radius: 9,
                                      backgroundColor: const Color(0xffef4444),
                                      child: Text(
                                        '${cart.itemCount}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _CircleIcon(icon: Icons.favorite_border_rounded, onTap: () {}),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    height: 310,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(color: const Color(0xffeeeeee)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x10000000),
                          blurRadius: 28,
                          spreadRadius: -8,
                          offset: Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Hero(
                              tag: 'product_${p.id}',
                              child: p.isNetworkImage
                                  ? Image.network(
                                      p.displayImage,
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.high,
                                      errorBuilder: (_, __, ___) =>
                                          const Text('🛒', style: TextStyle(fontSize: 78)),
                                    )
                                  : Text(
                                      p.displayImage.isNotEmpty ? p.displayImage : '🛒',
                                      style: const TextStyle(fontSize: 78),
                                    ),
                            ),
                          ),
                        ),
                        if (p.hasDiscount)
                          Positioned(
                            left: 18,
                            top: 18,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xffffefe6),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${p.discount.toStringAsFixed(0)}% OFF',
                                style: const TextStyle(
                                  color: Color(0xffd9480f),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 130),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((p.categoryName ?? '').isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color(0xffe8f7ef),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              p.categoryName!,
                              style: const TextStyle(
                                color: Color(0xff0c8f43),
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 30,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                            color: Color(0xff111827),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          p.unit,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Text(
                              '${AppConstants.currency}${sellingPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Color(0xff111827),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (p.hasDiscount)
                              Text(
                                '${AppConstants.currency}${mrp.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            const Spacer(),
                            if (p.rating > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: const Color(0xffeeeeee)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: Color(0xffffb703), size: 18),
                                    const SizedBox(width: 3),
                                    Text(
                                      p.rating.toStringAsFixed(1),
                                      style: const TextStyle(fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _InfoCard(
                          icon: Icons.flash_on_rounded,
                          title: 'Fast local delivery',
                          subtitle: 'Delivered quickly from Kohli Store',
                        ),
                        const SizedBox(height: 12),
                        _InfoCard(
                          icon: Icons.verified_rounded,
                          title: p.inStock ? 'In stock' : 'Out of stock',
                          subtitle: p.inStock ? '${p.stock} units available' : 'Currently unavailable',
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Product details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xff111827),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          p.description.isNotEmpty
                              ? p.description
                              : 'Fresh quality product selected for daily grocery needs.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _BottomAddBar(product: p),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIcon({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x0d000000),
                blurRadius: 18,
                spreadRadius: -5,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xff111827)),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffeeeeee)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xffe8f7ef),
            child: Icon(icon, color: const Color(0xff0c8f43)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomAddBar extends StatelessWidget {
  final ProductModel product;

  const _BottomAddBar({required this.product});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final qty = cart.getQuantity(product.id);

        return Container(
          height: 68,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xffeeeeee)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1a000000),
                blurRadius: 26,
                spreadRadius: -6,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: qty <= 0
              ? ElevatedButton(
                  onPressed: product.inStock ? () => cart.addItem(product) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0c8f43),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Add to Cart',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => cart.decreaseQuantity(product.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff0c8f43),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                        ),
                        child: const Icon(Icons.remove_rounded),
                      ),
                    ),
                    SizedBox(
                      width: 70,
                      child: Center(
                        child: Text(
                          '$qty',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => cart.increaseQuantity(product.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff0c8f43),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                        ),
                        child: const Icon(Icons.add_rounded),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}


