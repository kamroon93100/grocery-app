import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/home/product_card_v6.dart';
import '../cart/cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _page = PageController();
  int _imageIndex = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final images = p.images.isEmpty ? [p.displayImage] : p.images;
    final selling = p.price;
    final mrp = p.discount > 0 ? selling / (1 - p.discount / 100) : selling;
    final save = mrp - selling;

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
                        _RoundIcon(icon: Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
                        const Spacer(),
                        _RoundIcon(icon: Icons.share_outlined, onTap: () {}),
                        const SizedBox(width: 8),
                        _RoundIcon(icon: Icons.favorite_border_rounded, onTap: () {}),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    height: 330,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(color: const Color(0xffeeeeee)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x10000000), blurRadius: 28, spreadRadius: -8, offset: Offset(0, 14)),
                      ],
                    ),
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _page,
                          itemCount: images.length,
                          onPageChanged: (i) => setState(() => _imageIndex = i),
                          itemBuilder: (_, i) {
                            final img = images[i];
                            return Padding(
                              padding: const EdgeInsets.all(30),
                              child: Hero(
                                tag: 'product_${p.id}',
                                child: img.startsWith('http')
                                    ? Image.network(img, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Text('🛒', style: TextStyle(fontSize: 80)))
                                    : Text(img, textAlign: TextAlign.center, style: const TextStyle(fontSize: 80)),
                              ),
                            );
                          },
                        ),
                        if (p.hasDiscount)
                          Positioned(
                            left: 18,
                            top: 18,
                            child: _Badge(text: '${p.discount.toStringAsFixed(0)}% OFF'),
                          ),
                        if (!p.inStock)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white.withOpacity(.68), borderRadius: BorderRadius.circular(34)),
                              child: const Center(child: _Badge(text: 'OUT OF STOCK')),
                            ),
                          ),
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              images.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: _imageIndex == i ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _imageIndex == i ? const Color(0xff0c8f43) : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(99),
                                ),
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
                          Text(p.categoryName!, style: const TextStyle(color: Color(0xff0c8f43), fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        Text(p.name, style: const TextStyle(fontSize: 30, height: 1.05, fontWeight: FontWeight.w900, color: Color(0xff111827))),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(p.unit, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w800)),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(color: const Color(0xfffff7df), borderRadius: BorderRadius.circular(99)),
                              child: const Row(
                                children: [
                                  Icon(Icons.star_rounded, size: 16, color: Color(0xffffb703)),
                                  SizedBox(width: 3),
                                  Text('4.6', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('120 reviews', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 18),

                        _Card(
                          child: Row(
                            children: [
                              Text('${AppConstants.currency}${selling.toStringAsFixed(0)}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                              const SizedBox(width: 9),
                              if (p.hasDiscount)
                                Text('${AppConstants.currency}${mrp.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey.shade500, decoration: TextDecoration.lineThrough, fontWeight: FontWeight.w800)),
                              const Spacer(),
                              if (save > 0) _Badge(text: 'Save ₹${save.toStringAsFixed(0)}'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),
                        const _InfoTile(icon: Icons.flash_on_rounded, title: 'Delivery in 10-15 mins', subtitle: 'Fast local delivery from Kohli Store'),
                        const SizedBox(height: 10),
                        _InfoTile(icon: Icons.inventory_2_rounded, title: p.inStock ? 'In stock' : 'Out of stock', subtitle: p.inStock ? '${p.stock} units available' : 'Currently unavailable'),
                        const SizedBox(height: 10),
                        const _InfoTile(icon: Icons.verified_rounded, title: 'Freshness guaranteed', subtitle: 'Quality checked before delivery'),

                        const SizedBox(height: 20),
                        _Title('About Product'),
                        const SizedBox(height: 10),
                        _Card(
                          child: Text(
                            p.description.isNotEmpty ? p.description : 'Fresh quality product selected for your daily grocery needs.',
                            style: TextStyle(height: 1.45, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                          ),
                        ),

                        const SizedBox(height: 20),
                        _Title('Highlights'),
                        const SizedBox(height: 10),
                        _Card(
                          child: Column(
                            children: const [
                              _MiniRow('Shelf Life', 'Best before 6 months'),
                              _MiniRow('Country of Origin', 'India'),
                              _MiniRow('Storage', 'Store in a cool, dry place'),
                              _MiniRow('Return Policy', 'Return only if damaged/expired'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                        _Title('Nutrition Facts'),
                        const SizedBox(height: 10),
                        _Card(
                          child: Column(
                            children: const [
                              _MiniRow('Energy', '120 kcal'),
                              _MiniRow('Protein', '3 g'),
                              _MiniRow('Carbs', '18 g'),
                              _MiniRow('Fat', '4 g'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                        _SimilarProducts(currentId: p.id),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(left: 16, right: 16, bottom: 16, child: _BottomBar(product: p)),
          ],
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 46, height: 46, child: Icon(icon, color: const Color(0xff111827))),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(color: const Color(0xffffefe6), borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: const TextStyle(color: Color(0xffd9480f), fontWeight: FontWeight.w900, fontSize: 12)),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffeeeeee)),
        boxShadow: const [BoxShadow(color: Color(0x0d000000), blurRadius: 24, spreadRadius: -6, offset: Offset(0, 10))],
      ),
      child: child,
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _InfoTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          CircleAvatar(backgroundColor: const Color(0xffe8f7ef), child: Icon(icon, color: const Color(0xff0c8f43))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700, fontSize: 12)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xff111827)));
  }
}

class _MiniRow extends StatelessWidget {
  final String k;
  final String v;
  const _MiniRow(this.k, this.v);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(child: Text(k, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700))),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _SimilarProducts extends StatelessWidget {
  final String currentId;
  const _SimilarProducts({required this.currentId});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().products.where((p) => p.id != currentId).take(8).toList();
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Title('Similar Products'),
        const SizedBox(height: 12),
        SizedBox(
          height: 262,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => SizedBox(width: 164, child: ProductCardV6(product: products[i])),
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final ProductModel product;
  const _BottomBar({required this.product});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final qty = cart.getQuantity(product.id);

        return Container(
          height: 72,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xffeeeeee)),
            boxShadow: const [BoxShadow(color: Color(0x1a000000), blurRadius: 28, spreadRadius: -8, offset: Offset(0, 12))],
          ),
          child: qty <= 0
              ? Row(
                  children: [
                    Expanded(
                      child: Text('${AppConstants.currency}${product.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    ),
                    SizedBox(
                      width: 180,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: product.inStock ? () => cart.addItem(product) : null,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff0c8f43), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                        child: const Text('Add to Cart', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: Text('$qty in cart', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
                    SizedBox(
                      width: 180,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff0c8f43), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                        child: const Text('Go to Cart', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

