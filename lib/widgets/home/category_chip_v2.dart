import 'package:flutter/material.dart';

class CategoryChipV2 extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const CategoryChipV2({
    super.key,
    required this.title,
    required this.image,
    required this.onTap,
  });

  IconData _iconFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('fruit') || n.contains('vegetable')) return Icons.eco_rounded;
    if (n.contains('dairy') || n.contains('milk') || n.contains('bread') || n.contains('egg')) return Icons.local_drink_rounded;
    if (n.contains('atta') || n.contains('rice') || n.contains('dal') || n.contains('staple')) return Icons.rice_bowl_rounded;
    if (n.contains('oil') || n.contains('ghee')) return Icons.opacity_rounded;
    if (n.contains('masala') || n.contains('spice')) return Icons.grain_rounded;
    if (n.contains('snack') || n.contains('chip')) return Icons.fastfood_rounded;
    if (n.contains('sweet') || n.contains('biscuit') || n.contains('chocolate')) return Icons.cookie_rounded;
    if (n.contains('drink') || n.contains('beverage') || n.contains('juice')) return Icons.local_cafe_rounded;
    if (n.contains('instant') || n.contains('noodle') || n.contains('food')) return Icons.ramen_dining_rounded;
    if (n.contains('frozen')) return Icons.ac_unit_rounded;
    if (n.contains('breakfast')) return Icons.free_breakfast_rounded;
    if (n.contains('clean')) return Icons.cleaning_services_rounded;
    if (n.contains('personal') || n.contains('care')) return Icons.spa_rounded;
    if (n.contains('baby')) return Icons.child_care_rounded;
    if (n.contains('pet')) return Icons.pets_rounded;
    if (n.contains('baby')) return Icons.child_care_rounded;
    if (n.contains('personal')) return Icons.spa_rounded;
    if (n.contains('laundry')) return Icons.local_laundry_service_rounded;
    if (n.contains('breakfast')) return Icons.free_breakfast_rounded;
    if (n.contains('frozen')) return Icons.ac_unit_rounded;
    if (n.contains('instant')) return Icons.ramen_dining_rounded;
    if (n.contains('dry fruit')) return Icons.eco_rounded;
    if (n.contains('pet')) return Icons.pets_rounded;
    if (n.contains('kitchen')) return Icons.kitchen_rounded;
    return Icons.shopping_bag_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = image.trim().isNotEmpty && image.startsWith('http');

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: SizedBox(
        width: 86,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xfff8fff9), Color(0xffeefcf2)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xffe7f5eb)),
                boxShadow: const [
                  BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 4))
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: hasImage
                    ? Image.network(
                        image,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(_iconFor(title), color: const Color(0xff0c8f43), size: 34),
                      )
                    : Icon(_iconFor(title), color: const Color(0xff0c8f43), size: 34),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

