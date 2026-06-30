import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class ProductVariantSelector extends StatelessWidget {
  final ProductModel product;

  const ProductVariantSelector({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final variants = [
      product.unit,
      '500 g',
      '1 kg',
      '2 kg',
    ].toSet().toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose variant',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: variants.map((v) {
              final selected = v == product.unit;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xffe8fff1) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? const Color(0xff0c8f43) : Colors.grey.shade300,
                    width: selected ? 1.4 : 1,
                  ),
                ),
                child: Text(
                  v,
                  style: TextStyle(
                    color: selected ? const Color(0xff0c8f43) : Colors.black87,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

