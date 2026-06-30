import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class ProductPriceSection extends StatelessWidget {
  final ProductModel product;

  const ProductPriceSection({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final mrp = product.price;
    final selling = product.finalPrice;
    final discount = product.discount.round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              Text(
                "₹${selling.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(width: 10),

              if(product.hasDiscount)
              Text(
                "₹${mrp.toStringAsFixed(0)}",
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                  fontSize: 18,
                ),
              ),

              const Spacer(),

              if(product.hasDiscount)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffe8fff1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$discount% OFF",
                  style: const TextStyle(
                    color: Color(0xff0c8f43),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            product.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            product.unit,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xfff5fff8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [

                Icon(
                  Icons.flash_on,
                  color: Color(0xff0c8f43),
                ),

                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    "Delivery in 10 minutes",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                Icon(Icons.chevron_right),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
