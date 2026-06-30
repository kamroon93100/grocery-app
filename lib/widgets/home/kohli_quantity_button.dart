import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/product_model.dart';

class KohliQuantityButton extends StatelessWidget {
  final ProductModel product;

  const KohliQuantityButton({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final qty = cart.getQuantity(product.id);

        if (qty <= 0) {
          return SizedBox(
            width: double.infinity,
            height: 34,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xff0c8f43),
                side: const BorderSide(color: Color(0xff0c8f43), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => cart.addItem(product),
              child: const Text(
                'ADD',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          );
        }

        return Container(
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xff0c8f43),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => cart.decreaseQuantity(product.id),
                  child: const Center(
                    child: Icon(Icons.remove, color: Colors.white, size: 18),
                  ),
                ),
              ),
              Text(
                '$qty',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => cart.increaseQuantity(product.id),
                  child: const Center(
                    child: Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
