import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/address_provider.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_colors.dart';
import '../../widgets/home_banners.dart';
import '../../widgets/product_quick_view.dart';
import '../../widgets/kohli_search_bar.dart';
import '../../widgets/kohli_product_card.dart';
import '../../widgets/kohli_category_tile.dart';
import '../../widgets/kohli_section_header.dart';
import '../../widgets/kohli_floating_cart.dart';
import '../../app/theme/color_scheme_ext.dart';
import '../cart/cart_screen.dart';
import '../categories/categories_screen.dart';
import '../reorder/reorder_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _tab = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isBottomNavVisible = true;
  double _lastScrollOffset = 0.0;
  late AnimationController _tabAnimCtrl;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _tabAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabAnimCtrl.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final currentOffset = _scrollController.offset;
    if (currentOffset > _lastScrollOffset && currentOffset > 50) {
      if (_isBottomNavVisible) setState(() => _isBottomNavVisible = false);
    } else if (currentOffset < _lastScrollOffset) {
      if (!_isBottomNavVisible) setState(() => _isBottomNavVisible = true);
    }
    _lastScrollOffset = currentOffset;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: IndexedStack(
              key: ValueKey(_tab),
              index: _tab,
              children: [
                _HomeFeed(scrollController: _scrollController),
                CategoriesScreen(onCategorySelected: () {
                  setState(() => _tab = 0);
                }),
                const ReorderScreen(),
                const ProfileScreen(),
              ],
            ),
          ),
          // Floating Cart
          KohliFloatingCart(),
        ],
      ),
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        offset: Offset(0, _isBottomNavVisible ? 0 : 1),
        child: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) {
            _tabAnimCtrl.forward(from: 0);
            setState(() => _tab = i);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: colorScheme.surface,
          selectedItemColor: colorScheme.textPrimary,
          unselectedItemColor: colorScheme.textMuted,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 26,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Categories'),
            BottomNavigationBarItem(
              icon: Icon(Icons.replay_outlined),
              activeIcon: Icon(Icons.replay_rounded),
              label: 'Reorder'),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Account'),
          ],
        ),
      ),
    );
  }
}

class _HomeFeed extends StatefulWidget {
  final ScrollController scrollController;
  const _HomeFeed({required this.scrollController});
  @override
  State<_HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<_HomeFeed> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProductProvider>();
      if (p.categories.isEmpty) p.loadCategories();
      if (p.products.isEmpty) p.loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductProvider>();
    final address = context.watch<AddressProvider>();
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        children: [
          if (product.error != null)
            MaterialBanner(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              content: Text(product.error!,
                style: const TextStyle(fontSize: 13, color: Colors.white)),
              backgroundColor: AppColors.error,
              actions: [
                TextButton(
                  onPressed: () => context.read<ProductProvider>().loadProducts(refresh: true),
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('Retry'),
                ),
              ],
            ),
          Expanded(
            child: CustomScrollView(
              controller: widget.scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header SliverAppBar
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            elevation: 0,
      backgroundColor: colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      // Address / Location
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: Row(children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: colorScheme.categoryBg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.location_on_rounded,
                                size: 18, color: colorScheme.primary),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    address.defaultAddress != null
                                        ? address.defaultAddress!.line1
                                        : 'Set delivery address',
                                    style: TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w600,
                                      color: colorScheme.textPrimary),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text('6 mins',
                                    style: TextStyle(
                                      fontSize: 11, color: colorScheme.textMuted)),
                                ],
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down_rounded,
                              size: 20, color: colorScheme.textMuted),
                          ]),
                        ),
                      ),
                      // Cart icon
                      Stack(children: [
                        IconButton(
                          icon: Icon(Icons.shopping_cart_outlined,
                            size: 26, color: colorScheme.textPrimary),
                          onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const CartScreen()))),
                        if (cart.itemCount > 0)
                          Positioned(right: 4, top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle),
                              child: Text(cart.itemCount.toString(),
                                style: const TextStyle(color: Colors.white,
                                  fontSize: 10, fontWeight: FontWeight.w700)))),
                      ]),
                      // Profile avatar
                      GestureDetector(
                        onTap: () {
                          if (auth.isAdmin) {
                            Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const AdminScreen()));
                          }
                        },
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.textPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person_rounded,
                            color: Colors.white, size: 22)),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
          // Search Bar
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: KohliSearchBar(
              hintText: 'Search for milk, atta, eggs...',
              onTap: () => _showSearch(context, product),
              onChanged: (v) {
                if (v.length > 2) product.searchProducts(v);
              },
            ),
          )),
          // Promo Banners
          const SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.only(top: 4),
            child: SizedBox(height: 170, child: HomeBanners()),
          )),
          // Category Rail
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: ['All', ...product.categories.map((c) => c.name)].length,
                itemBuilder: (context, index) {
                  final list = ['All', ...product.categories.map((c) => c.name)];
                  final catName = list[index];
                  String? icon;
                  if (catName != 'All') {
                    final cat = product.categories.firstWhere(
                      (c) => c.name == catName,
                      orElse: () => CategoryModel(
                        id: '', name: '', description: '', icon: '',
                        isActive: true, sortOrder: 0),
                    );
                    icon = cat.icon;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: KohliCategoryTile(
                      label: catName,
                      icon: icon,
                      selected: catName == product.selectedCategory,
                      onTap: () => context.read<ProductProvider>().selectCategory(catName),
                    ),
                  );
                },
              ),
            ),
          )),
          // Most Shopped Section
          SliverToBoxAdapter(child: _HeroRow(products: product.products)),
          // Trending Section
          KohliSectionHeader(
            title: 'Trending Near You',
            subtitle: 'Popular picks in your area',
          ),
          // Product Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  if (i >= product.products.length) return null;
                  return KohliProductCard(
                    product: product.products[i],
                    onTap: () => ProductQuickView.show(ctx, product.products[i]),
                  );
                },
                childCount: product.products.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    ),
  ],
));
  }

  void _showSearch(BuildContext context, ProductProvider product) {
    final searchCtrl = TextEditingController();
    Timer? _debounce;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16, left: 24, right: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 48, height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.divider,
                    borderRadius: BorderRadius.circular(3))),
                const SizedBox(height: 16),
                KohliSearchBar(
                  controller: searchCtrl,
                  hintText: 'Search for products...',
                  onChanged: (v) {
                    setS(() {});
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 300), () {
                      product.searchProducts(v);
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (product.searchResults.isNotEmpty)
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: product.searchResults.length,
                      itemBuilder: (ctx, i) {
                        final p = product.searchResults[i];
                        return ListTile(
                          leading: Text(p.displayImage.isNotEmpty ? p.displayImage : '\u{1F6D2}',
                            style: const TextStyle(fontSize: 28)),
                          title: Text(p.name),
                          subtitle: Text(AppConstants.currency + p.finalPrice.toStringAsFixed(2)),
                          trailing: IconButton(
                            icon: Icon(Icons.add_circle_rounded,
                              color: Theme.of(context).colorScheme.primary),
                            onPressed: () => context.read<CartProvider>().addItem(p)),
                          onTap: () {
                            Navigator.pop(ctx);
                            ProductQuickView.show(context, p);
                          },
                        );
                      }),
                  ),
                if (searchCtrl.text.isNotEmpty && product.searchResults.isEmpty)
                  const Padding(padding: EdgeInsets.all(40),
                    child: Text('No products found',
                      style: TextStyle(color: Colors.grey))),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroRow extends StatefulWidget {
  final List<ProductModel> products;
  const _HeroRow({required this.products});
  @override
  State<_HeroRow> createState() => _HeroRowState();
}

class _HeroRowState extends State<_HeroRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _f;
  @override
  void initState() {
    super.initState();
    _f = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
  }
  @override
  void dispose() { _f.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          Expanded(
            child: Text('Most shopped near you',
              style: TextStyle(
                fontSize: 19, fontWeight: FontWeight.w800,
                color: colorScheme.textPrimary, height: 1.3)),
          ),
          AnimatedBuilder(animation: _f,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, math.sin(_f.value * math.pi) * 6),
              child: Transform.rotate(
                angle: math.sin(_f.value * math.pi) * 0.035,
                child: const Text('\u{1F6D2}\u{1F95B}\u{1F34C}',
                  style: TextStyle(fontSize: 36))))),
        ]),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 230,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: math.min(widget.products.length, 10),
          itemBuilder: (ctx, i) {
            final p = widget.products[i];
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: KohliProductCard(
                product: p,
                width: 150,
                onTap: () => ProductQuickView.show(ctx, p),
              ),
            );
          }),
      ),
    ]);
  }
}
