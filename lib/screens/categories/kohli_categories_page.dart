import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';

class KohliCategoriesPage extends StatefulWidget {
  const KohliCategoriesPage({super.key});

  @override
  State<KohliCategoriesPage> createState() => _KohliCategoriesPageState();
}

class _KohliCategoriesPageState extends State<KohliCategoriesPage> {
  String query = '';

  String emoji(String name) {
    final n = name.toLowerCase();
    if (n.contains('fruit') || n.contains('vegetable')) return '🥦';
    if (n.contains('dairy') || n.contains('bread') || n.contains('egg')) return '🥛';
    if (n.contains('atta') || n.contains('rice') || n.contains('dal')) return '🌾';
    if (n.contains('oil') || n.contains('ghee')) return '🛢️';
    if (n.contains('masala') || n.contains('spice')) return '🌶️';
    if (n.contains('dry fruit')) return '🥜';
    if (n.contains('snack') || n.contains('munch')) return '🍿';
    if (n.contains('biscuit') || n.contains('chocol')) return '🍪';
    if (n.contains('tea') || n.contains('coffee')) return '☕';
    if (n.contains('cold') || n.contains('juice') || n.contains('drink')) return '🥤';
    if (n.contains('instant')) return '🍜';
    if (n.contains('frozen')) return '🧊';
    if (n.contains('breakfast')) return '🥣';
    if (n.contains('clean')) return '🧽';
    if (n.contains('laundry')) return '🧺';
    return '🛒';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final all = provider.categories;
    final filtered = query.trim().isEmpty
        ? all
        : all.where((c) => c.name.toLowerCase().contains(query.toLowerCase())).toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Categories', style: TextStyle(fontSize: 31, height: 1, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text('Everything fresh, fast and sorted', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey.shade600)),
                  const SizedBox(height: 16),
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xffeeeeee)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: Colors.grey),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            onChanged: (v) => setState(() => query = v),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search groceries',
                              hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (filtered.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('No categories found', style: TextStyle(fontWeight: FontWeight.w900))),
            )
          else
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
                    final c = filtered[i];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: const Color(0xffeeeeee)),
                        boxShadow: const [BoxShadow(color: Color(0x0d000000), blurRadius: 24, spreadRadius: -6, offset: Offset(0, 10))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(emoji(c.name), style: const TextStyle(fontSize: 36)),
                          const Spacer(),
                          Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text('Explore items', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.shade500)),
                        ],
                      ),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

