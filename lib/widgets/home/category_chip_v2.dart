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

  String _emoji(String name) {
    final n = name.toLowerCase();
    if (n.contains('baby')) return '🍼';
    if (n.contains('personal')) return '🧴';
    if (n.contains('clean')) return '🧽';
    if (n.contains('laundry')) return '🧺';
    if (n.contains('breakfast')) return '🥣';
    if (n.contains('frozen')) return '❄️';
    if (n.contains('instant')) return '🍜';
    if (n.contains('drink') || n.contains('juice')) return '🥤';
    if (n.contains('tea') || n.contains('coffee')) return '☕';
    if (n.contains('biscuit') || n.contains('chocolate')) return '🍫';
    if (n.contains('snack') || n.contains('munch')) return '🍿';
    if (n.contains('masala') || n.contains('spice')) return '🌶️';
    if (n.contains('oil') || n.contains('ghee')) return '🛢️';
    if (n.contains('atta') || n.contains('rice') || n.contains('dal')) return '🌾';
    if (n.contains('dairy') || n.contains('bread') || n.contains('egg')) return '🥛';
    if (n.contains('fruit') || n.contains('vegetable')) return '🥦';
    return '🛍️';
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = image.trim().startsWith('http');
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: SizedBox(
        width: 92,
        child: Column(
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 12, offset: Offset(0, 6))],
              ),
              child: Center(
                child: hasImage
                    ? Image.network(image, width: 42, height: 42, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Text(_emoji(title), style: const TextStyle(fontSize: 32)))
                    : Text(_emoji(title), style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(height: 7),
            Text(title, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, height: 1.05, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
