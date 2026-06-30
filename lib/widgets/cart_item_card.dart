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
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0,4),
          )
        ],
      ),
      child: Row(
        children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: item.product.displayImage,
              width: 70,
              height: 70,
              fit: BoxFit.contain,
              errorWidget: (_,__,___)=>const Icon(Icons.image,size:50),
            ),
          ),

          const SizedBox(width:14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  item.product.name,
                  maxLines:2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize:16,
                  ),
                ),

                const SizedBox(height:4),

                Text(
                  item.product.unit,
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height:8),

                Text(
                  "₹${item.product.finalPrice.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize:20,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width:100,
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

