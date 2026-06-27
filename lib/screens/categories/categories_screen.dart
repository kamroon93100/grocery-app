import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/category_model.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});
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
    final fresh   = <CategoryModel>[];
    final grocery = <CategoryModel>[];
    final snacks  = <CategoryModel>[];

    for (final c in cats) {
      final n = c.name.toLowerCase();
      if (n.contains('veg') || n.contains('fruit') ||
          n.contains('dairy') || n.contains('meat')) {
        fresh.add(c);
      } else if (n.contains('grain') || n.contains('bakery')) {
        grocery.add(c);
      } else {
        snacks.add(c);
      }
    }
    return {
      if (fresh.isNotEmpty)   'Fresh Items':      fresh,
      if (grocery.isNotEmpty) 'Grocery & Kitchen': grocery,
      if (snacks.isNotEmpty)  'Snacks & Drinks':   snacks,
    };
  }

  static const List<Color> _colors = [
    Color(0xFFE6F5F2), Color(0xFFFFF2B8),
    Color(0xFFE7F8EF), Color(0xFFF3EBFF),
    Color(0xFFEAF4FF), Color(0xFFFCE4EC),
    Color(0xFFFFF9C4), Color(0xFFE0F7FA),
  ];

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductProvider>();
    final sections = _group(product.categories);
    int colorIdx = 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Categories',
                    style: TextStyle(
                      fontSize: 34, fontWeight: FontWeight.w700,
                      color: Color(0xFF111111), letterSpacing: -0.5)),
                  SizedBox(
                    width: 40, height: 40,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.search, size: 24,
                        color: Color(0xFF111111)),
                      onPressed: () {})),
                ],
              ),
            ),

            // Sections
            ...sections.entries.map((entry) {
              final section = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
                    child: Text(entry.key,
                      style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700,
                        color: Color(0xFF111111)))),
                  SizedBox(
                    height: 126,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: entry.value.length,
                      itemBuilder: (context, i) {
                        final cat = entry.value[i];
                        final bg = _colors[(colorIdx + i) % _colors.length];
                        return Padding(
                          padding: EdgeInsets.only(
                            right: i < entry.value.length - 1 ? 16 : 0),
                          child: GestureDetector(
                            onTap: () => context.read<ProductProvider>()
                                .selectCategory(cat.name),
                            child: SizedBox(
                              width: 96,
                              child: Column(
                                children: [
                                  Container(
                                    width: 90, height: 90,
                                    decoration: BoxDecoration(
                                      color: bg,
                                      borderRadius: BorderRadius.circular(26)),
                                    child: Center(
                                      child: Text(cat.icon,
                                        style: const TextStyle(fontSize: 36)))),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: 90,
                                    child: Text(cat.name,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111111),
                                        height: 1.2))),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              );
              colorIdx += entry.value.length;
              return section;
            }).toList(),

            // Free delivery banner
            Container(
              height: 56,
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8FAFF),
                borderRadius: BorderRadius.circular(16)),
              child: const Row(children: [
                Expanded(
                  child: Text.rich(TextSpan(children: [
                    TextSpan(text: 'FREE DELIVERY ',
                      style: TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111))),
                    TextSpan(text: 'on orders above Rs99',
                      style: TextStyle(fontSize: 12,
                        color: Color(0xFF5B5B5B)))]))),
                Text('🏳️', style: TextStyle(fontSize: 22)),
              ])),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
