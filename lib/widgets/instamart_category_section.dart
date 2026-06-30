import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/product_provider.dart';
import '../app/theme/theme.dart';
import '../constants/app_constants.dart';

/// Instamart-style grouped category sections
class InstamartCategorySection extends StatelessWidget {
  final List<CategoryModel> categories;
  const InstamartCategorySection({super.key, required this.categories});

  // Group categories into sections
  Map<String, List<CategoryModel>> get _sections {
    final fresh = <CategoryModel>[];
    final grocery = <CategoryModel>[];
    final snacks = <CategoryModel>[];

    for (final cat in categories) {
      final name = cat.name.toLowerCase();
      if (name.contains('vegetable') || name.contains('fruit') ||
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

  // Background colors for category cards (like Instamart)
  static const List<Color> _bgColors = [
    Color(0xFFE8F5E9), // Light green
    Color(0xFFFFF3E0), // Light orange
    Color(0xFFE3F2FD), // Light blue
    Color(0xFFFCE4EC), // Light pink
    Color(0xFFF3E5F5), // Light purple
    Color(0xFFE0F7FA), // Light cyan
    Color(0xFFFFF9C4), // Light yellow
    Color(0xFFFFEBEE), // Light red
  ];

  @override
  Widget build(BuildContext context) {
    final sections = _sections;

    return Column(
      children: sections.entries.map((entry) {
        return _SectionWidget(
          title: entry.key,
          categories: entry.value,
          bgColors: _bgColors,
        );
      }).toList(),
    );
  }
}

class _SectionWidget extends StatelessWidget {
  final String              title;
  final List<CategoryModel> categories;
  final List<Color>         bgColors;

  const _SectionWidget({
    required this.title,
    required this.categories,
    required this.bgColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:   4,
              childAspectRatio: 0.75,
              crossAxisSpacing: 10,
              mainAxisSpacing:  10,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat   = categories[index];
              final color = bgColors[index % bgColors.length];
              return _CategoryCard(
                category: cat,
                bgColor:  color,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final Color          bgColor;

  const _CategoryCard({
    required this.category,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<ProductProvider>().selectCategory(category.name),
      child: Column(
        children: [
          // Image container (Instamart style - rounded with bg)
          Container(
            width:  72,
            height: 72,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: category.image != null && category.image!.startsWith('http')
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      category.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                        Center(child: Text(category.icon,
                          style: const TextStyle(fontSize: 36))),
                    ),
                  )
                : Center(
                    child: Text(category.icon,
                      style: const TextStyle(fontSize: 36)),
                  ),
          ),
          const SizedBox(height: 6),
          // Category name
          Text(
            category.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize:   11,
              fontWeight: FontWeight.w600,
              color:      AppColors.textDark,
              height:     1.2),
          ),
        ],
      ),
    );
  }
}


