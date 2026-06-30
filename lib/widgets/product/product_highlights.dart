import 'package:flutter/material.dart';

class ProductHighlights extends StatelessWidget {
  const ProductHighlights({super.key});

  @override
  Widget build(BuildContext context) {
    final highlights = const [
      ['🌱', 'Farm Fresh'],
      ['✅', 'Premium Quality'],
      ['🛡️', 'Quality Checked'],
      ['🚚', 'Fast Delivery'],
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Highlights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...highlights.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text(item[0], style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item[1],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
