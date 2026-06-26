import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/cart_provider.dart';
import '../../constants/app_constants.dart';
import '../product/product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});
  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishlistProvider>().loadWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final cart     = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('My Wishlist (${wishlist.count})'),
        actions: [
          if (wishlist.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear all',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Clear Wishlist?'),
                    content: const Text('Remove all items from wishlist?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Clear')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await context.read<WishlistProvider>().clearWishlist();
                }
              },
            ),
        ],
      ),
      body: wishlist.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Your wishlist is empty',
                    style: TextStyle(fontSize: 20, color: Colors.grey.shade500)),
                  const SizedBox(height: 8),
                  Text('Tap ❤️ on products to save them',
                    style: TextStyle(color: Colors.grey.shade400)),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: wishlist.items.length,
              itemBuilder: (context, index) {
                final p      = wishlist.items[index];
                final inCart = cart.isInCart(p.id);

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p))),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Stack(
                            children: [
                              Center(child: Text(p.displayImage,
                                style: const TextStyle(fontSize: 52))),
                              Positioned(
                                top: 0, right: 0,
                                child: GestureDetector(
                                  onTap: () => context.read<WishlistProvider>()
                                      .removeFromWishlist(p.id),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white, shape: BoxShape.circle),
                                    child: const Icon(Icons.favorite,
                                      color: Colors.red, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(p.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                                textAlign: TextAlign.center,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(p.categoryName ?? '',
                                style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 11)),
                              const SizedBox(height: 4),
                              Text('${AppConstants.currency}${p.finalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.green, fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: Icon(inCart
                                  ? Icons.check_circle : Icons.shopping_cart_outlined,
                                size: 16),
                              label: Text(inCart ? 'In Cart' : 'Add',
                                style: const TextStyle(fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: inCart ? Colors.grey : Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                              ),
                              onPressed: inCart
                                  ? null
                                  : () => context.read<CartProvider>().addItem(p),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
