import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/category_model.dart';
import '../../app/theme/color_scheme_ext.dart';
import '../../constants/app_constants.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/app_radius.dart';

class CategoriesScreen extends StatefulWidget {
  final VoidCallback? onCategorySelected;
  const CategoriesScreen({super.key, this.onCategorySelected});
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProductProvider>();
      if (p.categories.isEmpty) p.loadCategories();
    });
  }

  Map<String, List<CategoryModel>> _group(List<CategoryModel> cats) {
    final fresh = <CategoryModel>[];
    final grocery = <CategoryModel>[];
    final snacks = <CategoryModel>[];
    final personal = <CategoryModel>[];
    final household = <CategoryModel>[];

    for (final c in cats) {
      final n = c.name.toLowerCase();
      if (n.contains('veg') || n.contains('fruit') ||
          n.contains('dairy') || n.contains('meat') ||
          n.contains('fresh')) {
        fresh.add(c);
      } else if (n.contains('grain') || n.contains('bakery') ||
                 n.contains('kitchen')) {
        grocery.add(c);
      } else if (n.contains('snack') || n.contains('drink') ||
                 n.contains('beverage')) {
        snacks.add(c);
      } else if (n.contains('personal') || n.contains('care') ||
                 n.contains('beauty')) {
        personal.add(c);
      } else {
        household.add(c);
      }
    }
    return {
      if (fresh.isNotEmpty) 'Fresh Items': fresh,
      if (grocery.isNotEmpty) 'Grocery & Kitchen': grocery,
      if (snacks.isNotEmpty) 'Snacks & Drinks': snacks,
      if (personal.isNotEmpty) 'Personal Care': personal,
      if (household.isNotEmpty) 'Household': household,
    };
  }

  static const List<Color> _colors = [
    Color(0xFFEEF7FF),
    Color(0xFFF0FFF4),
    Color(0xFFFFF8ED),
    Color(0xFFFCE4EC),
    Color(0xFFF3E5F5),
    Color(0xFFE0F7FA),
    Color(0xFFFFF9C4),
    Color(0xFFFFEBEE),
  ];

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductProvider>();
    final sections = _group(product.categories);
    final colorScheme = Theme.of(context).colorScheme;
    int colorIdx = 0;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Categories',
                    style: AppTextStyles.h1(color: colorScheme.textPrimary)),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.softSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.search_rounded, size: 22,
                        color: colorScheme.textPrimary),
                      onPressed: () {}),
                  ),
                ],
              ),
            ),
            // Sections
            ...sections.entries.map((entry) {
              final section = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(entry.key,
                      style: AppTextStyles.sectionTitle(color: colorScheme.textPrimary))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.78,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: entry.value.length,
                      itemBuilder: (context, i) {
                        final cat = entry.value[i];
                        final bg = _colors[(colorIdx + i) % _colors.length];
                        return _CategoryGridTile(
                          category: cat,
                          bgColor: bg,
                          onTap: () {
                            context.read<ProductProvider>().selectCategory(cat.name);
                            if (widget.onCategorySelected != null) {
                              widget.onCategorySelected!();
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              );
              colorIdx += entry.value.length;
              return section;
            }).toList(),
            // Free delivery banner
            Container(
              height: 56,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.softSurface,
                borderRadius: BorderRadius.circular(AppRadius.banner)),
              child: Row(children: [
                Expanded(
                  child: Text.rich(TextSpan(children: [
                    TextSpan(text: 'FREE DELIVERY ',
                      style: TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.textPrimary)),
                    TextSpan(text: 'on orders above ${AppConstants.currency}${AppConstants.freeDeliveryAbove.toInt()}',
                      style: TextStyle(fontSize: 12,
                        color: colorScheme.textMuted))]))),
                Icon(Icons.local_shipping_rounded,
                  color: colorScheme.primary, size: 24),
              ])),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _CategoryGridTile extends StatelessWidget {
  final CategoryModel category;
  final Color bgColor;
  final VoidCallback onTap;

  const _CategoryGridTile({
    required this.category,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppRadius.categoryTile),
            ),
            child: category.image != null && category.image!.startsWith('http')
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.categoryTile),
                    child: Image.network(
                      category.image!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(category.icon, style: const TextStyle(fontSize: 32))),
                    ),
                  )
                : Center(
                    child: Text(category.icon, style: const TextStyle(fontSize: 32))),
          ),
          const SizedBox(height: 6),
          Text(category.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: colorScheme.textPrimary, height: 1.2)),
        ],
      ),
    );
  }
}
