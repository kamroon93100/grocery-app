import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';

class KohliCategoriesPage extends StatelessWidget {
  const KohliCategoriesPage({super.key});

  static const fallback = [
    ['Fruits', '??', 'Fresh picks'],
    ['Vegetables', '??', 'Daily fresh'],
    ['Dairy', '??', 'Milk & paneer'],
    ['Bakery', '??', 'Bread & buns'],
    ['Eggs', '??', 'Protein'],
    ['Rice', '??', 'Staples'],
    ['Snacks', '??', 'Quick bites'],
    ['Drinks', '??', 'Cold drinks'],
    ['Offers', '??', 'Best deals'],
    ['Top Picks', '?', 'Popular items'],
  ];

  String emoji(String name) {
    final n = name.toLowerCase();
    if (n.contains('fruit')) return '??';
    if (n.contains('vegetable')) return '??';
    if (n.contains('milk') || n.contains('dairy')) return '??';
    if (n.contains('bread') || n.contains('bakery')) return '??';
    if (n.contains('egg')) return '??';
    if (n.contains('rice')) return '??';
    if (n.contains('snack')) return '??';
    if (n.contains('drink')) return '??';
    return '??';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final items = provider.categories.isEmpty ? fallback : provider.categories;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 31,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      color: Color(0xff111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Everything fresh, fast and sorted',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xffeeeeee)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0d000000),
                          blurRadius: 18,
                          spreadRadius: -5,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search_rounded, color: Colors.grey),
                        SizedBox(width: 10),
                        Text(
                          'Search groceries',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 210,
                mainAxisExtent: 132,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  String name;
                  String icon;
                  String subtitle;

                  final item = items[i];
                  if (item is List) {
                    name = item[0].toString();
                    icon = item[1].toString();
                    subtitle = item[2].toString();
                  } else {
                    try {
                      name = (item as dynamic).name.toString();
                    } catch (_) {
                      name = 'Category';
                    }
                    icon = emoji(name);
                    subtitle = 'Explore items';
                  }

                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(26),
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: const Color(0xffeeeeee)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0d000000),
                              blurRadius: 24,
                              spreadRadius: -5,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(icon, style: const TextStyle(fontSize: 36)),
                            const Spacer(),
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Color(0xff111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: items.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


