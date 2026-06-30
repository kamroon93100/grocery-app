import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/cart_model.dart';
import 'common/kohli_quantity_stepper.dart';

class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffeeeeee)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0d000000),
            blurRadius: 22,
            spreadRadius: -6,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xfff8fafc),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CachedNetworkImage(
              imageUrl: item.product.displayImage,
              fit: BoxFit.contain,
              errorWidget: (_, __, ___) => const Icon(Icons.image, size: 42),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    height: 1.12,
                    color: Color(0xff111827),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.product.unit,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "₹${item.product.finalPrice.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                    color: Color(0xff111827),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 98,
            child: KohliQuantityStepper(
              quantity: item.quantity,
              onAdd: onAdd,
              onRemove: onRemove,
            ),
          ),
        ],
      ),
    );
  }
}

