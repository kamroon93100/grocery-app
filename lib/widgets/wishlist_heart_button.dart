import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../models/product_model.dart';

class WishlistHeartButton extends StatelessWidget {
  final ProductModel product;

  const WishlistHeartButton({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistProvider>(
      builder: (context, wish, _) {
        final active = wish.contains(product.id);
        return InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: () => wish.toggle(product),
          child: Icon(
            active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: active ? Colors.red : Colors.grey,
            size: 22,
          ),
        );
      },
    );
  }
}
