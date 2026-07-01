import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common/kohli_quantity_stepper.dart';
import '../../constants/app_constants.dart';
import '../../models/product_model.dart';
import '../../widgets/home/product_card_v6.dart';
import '../../widgets/home/category_chip_v2.dart';
import 'package:grocery_local/screens/cart/cart_screen.dart';
import '../search/kohli_search_screen.dart';
import '../profile/profile_screen.dart';
import '../offers/offers_screen.dart';
import '../orders/orders_screen.dart';
import '../../widgets/home/kohli_banner_carousel.dart';
import '../../widgets/categories/category_strip.dart';
import '../../widgets/premium_search_overlay.dart';
import '../../widgets/premium_hero_banner.dart';
import '../categories/kohli_categories_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductProvider>().loadCategories();
      context.read<ProductProvider>().loadProducts(refresh: true);
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    final pages = [
      const _HomePage(),
      const KohliCategoriesPage(),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xfff6f7f9),
      body: Stack(
        children: [
          pages[_tab],
          if (_tab == 0 && cart.itemCount > 0)
            Positioned(
              left: 16,
              right: 16,
              bottom: 86,
              child: _FloatingCartBar(cart: cart),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        backgroundColor: Colors.white,
        elevation: 2,
        height: 72,
        indicatorColor: const Color(0xffe6f7ee),
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'Categories'),
            NavigationDestination(icon: Icon(Icons.local_offer_outlined), selectedIcon: Icon(Icons.local_offer), label: 'Offers'),
            NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => context.read<ProductProvider>().loadProducts(refresh: true),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _Header(
                userName: auth.userName.isEmpty ? 'Customer' : auth.userName,
                cartCount: cart.itemCount,
              ),
            ),
            SliverToBoxAdapter(child: GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KohliSearchScreen())), child: const _SearchBar())),
            const SliverToBoxAdapter(child: KohliBannerCarousel()),
            SliverToBoxAdapter(child: CategoryStrip(categories: productProvider.categories)),
            SliverToBoxAdapter(child: _SectionHeader(title: 'Fresh picks', action: 'See all')),
            if (productProvider.isLoading && productProvider.products.isEmpty)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (productProvider.products.isEmpty)
              const SliverFillRemaining(child: Center(child: Text('No products found')))
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 110),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    final count = width >= 1200 ? 6 : width >= 900 ? 5 : width >= 650 ? 4 : 2;
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: count,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => ProductCardV6(product: productProvider.products[index]),
                        childCount: productProvider.products.length,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}


class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;

  const _SectionHeader({
    required this.title,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            action,
            style: const TextStyle(
              color: Color(0xff0c8f43),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String userName;
  final int cartCount;

  const _Header({required this.userName, required this.cartCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: const Color(0xffe6f7ee),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.storefront, color: Color(0xff0c8f43)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Deliver in 10 mins', style: TextStyle(fontSize: 13, color: Color(0xff0c8f43), fontWeight: FontWeight.w700)),
                Text('Kohli Store • Hi $userName ??', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.red,
                    child: Text('$cartCount', style: const TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: const Color(0xfff1f3f5), borderRadius: BorderRadius.circular(16)),
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 10),
            Expanded(child: Text('Search for fruits, milk, bread...', style: TextStyle(color: Colors.grey))),
            Icon(Icons.mic_none_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _OfferBanner extends StatelessWidget {
  const _OfferBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xff0c8f43), Color(0xff18b56b)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'Fresh groceries\nat your doorstep',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.1),
            ),
          ),
          Text('??', style: TextStyle(fontSize: 54)),
        ],
      ),
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  final List categories;

  const _CategoryStrip({required this.categories});

  @override
  Widget build(BuildContext context) {
    final items = categories.take(12).toList();

    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 104,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final c = items[i];

          return CategoryChipV2(
            title: c.name,
            image: c.image ?? '',
            onTap: () => context.read<ProductProvider>().selectCategory(c.name),
          );
        },
      ),
    );
  }
}
class _FloatingCartBar extends StatelessWidget {
  final CartProvider cart;

  const _FloatingCartBar({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(18),
      color: const Color(0xff0c8f43),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
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
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoriesPage extends StatelessWidget {
  const _CategoriesPage({super.key});

  static const fallback = [
    {'name': 'Fruits', 'icon': '??', 'subtitle': 'Fresh picks'},
    {'name': 'Vegetables', 'icon': '??', 'subtitle': 'Daily fresh'},
    {'name': 'Dairy', 'icon': '??', 'subtitle': 'Milk & more'},
    {'name': 'Bakery', 'icon': '??', 'subtitle': 'Bread & buns'},
    {'name': 'Eggs', 'icon': '??', 'subtitle': 'Protein'},
    {'name': 'Rice', 'icon': '??', 'subtitle': 'Staples'},
    {'name': 'Snacks', 'icon': '??', 'subtitle': 'Quick bites'},
    {'name': 'Drinks', 'icon': '??', 'subtitle': 'Cold drinks'},
  ];

  String _emoji(String name) {
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
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 30,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      color: Color(0xff111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Shop daily essentials by section',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xffeeeeee)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search_rounded, color: Colors.grey),
                        SizedBox(width: 10),
                        Text(
                          'Search categories',
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 210,
                mainAxisExtent: 132,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final c = items[i];
                  String name;
                  String subtitle = 'Explore items';
                  String icon;

                  if (c is Map) {
                    name = (c['name'] ?? '').toString();
                    subtitle = (c['subtitle'] ?? subtitle).toString();
                    icon = (c['icon'] ?? _emoji(name)).toString();
                  } else {
                    try {
                      name = (c as dynamic).name.toString();
                    } catch (_) {
                      name = 'Category';
                    }
                    icon = _emoji(name);
                  }

                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xffeeeeee)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0d000000),
                              blurRadius: 22,
                              spreadRadius: -5,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(icon, style: const TextStyle(fontSize: 34)),
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
                            const SizedBox(height: 3),
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

class _ProductRowSection extends StatelessWidget {
  final String title;
  final List<ProductModel> products;

  const _ProductRowSection({
    required this.title,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const Text(
                    'See all',
                    style: TextStyle(color: Color(0xff0c8f43), fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 285,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, i) {
                  return SizedBox(
                    width: 165,
                    child: ProductCardV6(product: products[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}




















