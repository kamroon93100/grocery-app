import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class ProductNutritionCard extends StatelessWidget {
  final ProductModel product;

  const ProductNutritionCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['Type', product.categoryName ?? 'Grocery'],
      ['Unit', product.unit],
      ['Origin', 'India'],
      ['Storage', 'Keep in a cool, dry place'],
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Product details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            ...rows.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(child: Text(r[0], style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w700))),
                  Expanded(child: Text(r[1], textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w800))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}


