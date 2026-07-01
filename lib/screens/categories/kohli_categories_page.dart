import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/home/product_card_v6.dart';
import '../cart/cart_screen.dart';

class KohliCategoriesPage extends StatefulWidget {
  const KohliCategoriesPage({super.key});

  @override
  State<KohliCategoriesPage> createState() => _KohliCategoriesPageState();
}

class _KohliCategoriesPageState extends State<KohliCategoriesPage> {
  String query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ProductProvider>();
      if (provider.categories.isEmpty) {
        await provider.loadCategories();
      }
      if (provider.products.isEmpty) {
        await provider.loadProducts();
      }
    });
  }

  String emoji(String name) {
    final n = name.toLowerCase();
    if (n.contains('fruit') || n.contains('vegetable')) return '🥦';
    if (n.contains('dairy') || n.contains('bread') || n.contains('egg')) return '🥛';
    if (n.contains('atta') || n.contains('rice') || n.contains('dal')) return '🌾';
    if (n.contains('oil') || n.contains('ghee')) return '🛢️';
    if (n.contains('masala') || n.contains('spice')) return '🌶️';
    if (n.contains('snack') || n.contains('munch')) return '🍿';
    if (n.contains('tea') || n.contains('coffee')) return '☕';
    if (n.contains('drink') || n.contains('juice')) return '🥤';
    if (n.contains('clean') || n.contains('laundry')) return '🧽';
    return '🛒';
  }

  int productCount(BuildContext context, dynamic category) {
    final products = context.read<ProductProvider>().products;
    final name = category.name.toString().toLowerCase();
    final id = category.id.toString();

    return products.where((p) {
      return p.categoryId == id || (p.categoryName ?? '').toLowerCase() == name;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final all = provider.categories;
    final filtered = query.trim().isEmpty
        ? all
        : all.where((c) => c.name.toLowerCase().contains(query.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xfff6f7f9),
      body: SafeArea(
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
                      height: 112,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xff0c8f43), Color(0xff19b46b)]),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [BoxShadow(color: Color(0x220c8f43), blurRadius: 24, offset: Offset(0, 12))],
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Shop by category', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                                SizedBox(height: 6),
                                Text('Fresh groceries, snacks, drinks & essentials', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          Text('🛒', style: TextStyle(fontSize: 48)),
                        ],
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
                                hintText: 'Search categories',
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
                    maxCrossAxisExtent: 220,
                    mainAxisExtent: 150,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final c = filtered[i];
                      final count = productCount(context, c);
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(26),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryProductsPage(
                                categoryId: c.id.toString(),
                                categoryName: c.name.toString(),
                                icon: emoji(c.name.toString()),
                              ),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(color: const Color(0xffeeeeee)),
                              boxShadow: const [BoxShadow(color: Color(0x0d000000), blurRadius: 24, spreadRadius: -6, offset: Offset(0, 10))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(emoji(c.name), style: const TextStyle(fontSize: 38)),
                                const Spacer(),
                                Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                                const SizedBox(height: 4),
                                Text('$count products', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey.shade500)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CategoryProductsPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String icon;

  const CategoryProductsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.icon,
  });

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  String query = '';
  String sort = 'Popular';

  List<ProductModel> filterProducts(List<ProductModel> products) {
    var list = products.where((p) {
      final sameCategory = p.categoryId == widget.categoryId || (p.categoryName ?? '').toLowerCase() == widget.categoryName.toLowerCase();
      final matchesSearch = query.trim().isEmpty ||
          p.name.toLowerCase().contains(query.toLowerCase()) ||
          p.description.toLowerCase().contains(query.toLowerCase());
      return sameCategory && matchesSearch;
    }).toList();

    if (sort == 'Price Low') list.sort((a, b) => a.price.compareTo(b.price));
    if (sort == 'Price High') list.sort((a, b) => b.price.compareTo(a.price));
    if (sort == 'Discount') list.sort((a, b) => b.discount.compareTo(a.discount));

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final products = filterProducts(context.watch<ProductProvider>().products);
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xfff6f7f9),
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: const Color(0xfff6f7f9),
                  foregroundColor: const Color(0xff111827),
                  title: Text(widget.categoryName, style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: const Color(0xffeeeeee)),
                          ),
                          child: Row(
                            children: [
                              Text(widget.icon, style: const TextStyle(fontSize: 44)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.categoryName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                                    const SizedBox(height: 4),
                                    Text('${products.length} products available', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xffeeeeee))),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, color: Colors.grey),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  onChanged: (v) => setState(() => query = v),
                                  decoration: const InputDecoration(border: InputBorder.none, hintText: 'Search inside category'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['Popular', 'Price Low', 'Price High', 'Discount'].map((s) {
                              final active = sort == s;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  selected: active,
                                  label: Text(s, style: TextStyle(fontWeight: FontWeight.w900, color: active ? Colors.white : const Color(0xff111827))),
                                  selectedColor: const Color(0xff0c8f43),
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: Color(0xffeeeeee)),
                                  onSelected: (_) => setState(() => sort = s),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (products.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: Text('No products found', style: TextStyle(fontWeight: FontWeight.w900))),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 120),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 190,
                        mainAxisExtent: 262,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => ProductCardV6(product: products[i]),
                        childCount: products.length,
                      ),
                    ),
                  ),
              ],
            ),
            if (cart.itemCount > 0)
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Material(
                  color: const Color(0xff0c8f43),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                    child: Container(
                      height: 58,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.shopping_bag_rounded, color: Colors.white),
                          const SizedBox(width: 10),
                          Text('${cart.itemCount} items', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                          const SizedBox(width: 8),
                          Text('${AppConstants.currency}${cart.totalAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                          const Spacer(),
                          const Text('View Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                          const Icon(Icons.chevron_right_rounded, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

