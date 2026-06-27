import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/category_model.dart';
import '../providers/product_provider.dart';

class PremiumCategorySection extends StatelessWidget {
  final List<CategoryModel> categories;
  const PremiumCategorySection({super.key, required this.categories});

  Map<String, List<CategoryModel>> get _sections {
    final fresh   = <CategoryModel>[];
    final grocery = <CategoryModel>[];
    final snacks  = <CategoryModel>[];

    for (final cat in categories) {
      final name = cat.name.toLowerCase();
      if (name.contains('veg') || name.contains('fruit') ||
          name.contains('dairy') || name.contains('meat')) {
        fresh.add(cat);
      } else if (name.contains('grain') || name.contains('bakery')) {
        grocery.add(cat);
      } else {
        snacks.add(cat);
      }
    }

    return {
      if (fresh.isNotEmpty)   'Fresh Items':       fresh,
      if (grocery.isNotEmpty) 'Grocery & Kitchen':  grocery,
      if (snacks.isNotEmpty)  'Snacks & Drinks':    snacks,
    };
  }

  static const List<Color> tileColors = [
    Color(0xFFE7F8EF),
    Color(0xFFFFF4E6),
    Color(0xFFE3F2FD),
    Color(0xFFFCE4EC),
    Color(0xFFF3E5F5),
    Color(0xFFFFF9C4),
    Color(0xFFE0F7FA),
    Color(0xFFFFE0E0),
  ];

  @override
  Widget build(BuildContext context) {
    final sections = _sections;
    int colorIdx = 0;

    return Column(
      children: sections.entries.map((entry) {
        final w = _Section(
          title:      entry.key,
          categories: entry.value,
          startColor: colorIdx,
        );
        colorIdx += entry.value.length;
        return w;
      }).toList(),
    );
  }
}

class _Section extends StatelessWidget {
  final String              title;
  final List<CategoryModel> categories;
  final int                 startColor;

  const _Section({
    required this.title,
    required this.categories,
    required this.startColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF101828))),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: List.generate(categories.length, (i) {
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 80) / 4,
                  child: _Tile(
                    category: categories[i],
                    bgColor: PremiumCategorySection.tileColors[
                      (startColor + i) % PremiumCategorySection.tileColors.length],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final CategoryModel category;
  final Color          bgColor;

  const _Tile({required this.category, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<ProductProvider>().selectCategory(category.name),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: category.image != null && category.image!.startsWith('http')
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: category.image!,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) =>
                        Center(child: Text(category.icon,
                          style: const TextStyle(fontSize: 32))),
                    ),
                  )
                : Center(
                    child: Text(category.icon,
                      style: const TextStyle(fontSize: 32))),
          ),
          const SizedBox(height: 6),
          Text(category.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF101828),
              height: 1.2)),
        ],
      ),
    );
  }
}
