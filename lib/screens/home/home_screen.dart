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
import '../cart/cart_screen.dart';
import '../categories/categories_screen.dart';
import '../reorder/reorder_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_screen.dart';
import '../../widgets/product_quick_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isBottomNavVisible = true;
  bool _isFreeDeliveryBannerVisible = true;
  double _lastScrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final currentOffset = _scrollController.offset;
    if (currentOffset > _lastScrollOffset && currentOffset > 50) {
      if (_isBottomNavVisible) setState(() => _isBottomNavVisible = false);
      if (_isFreeDeliveryBannerVisible) setState(() => _isFreeDeliveryBannerVisible = false);
    } else if (currentOffset < _lastScrollOffset) {
      if (!_isBottomNavVisible) setState(() => _isBottomNavVisible = true);
      if (!_isFreeDeliveryBannerVisible) setState(() => _isFreeDeliveryBannerVisible = true);
    }
    _lastScrollOffset = currentOffset;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
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
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSlide(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            offset: Offset(0, _isFreeDeliveryBannerVisible ? 0 : 1),
            child: _FreeDeliveryBanner(),
          ),
          if (cart.itemCount > 0)
            AnimatedSlide(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              offset: Offset(0, _isBottomNavVisible ? 0 : 1),
              child: GestureDetector(
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CartScreen())),
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12B76A),
                    borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.shopping_bag, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('${cart.itemCount} items',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text(AppConstants.currency + cart.totalAmount.toStringAsFixed(0),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ]),
                ),
              ),
            ),
          AnimatedSlide(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            offset: Offset(0, _isBottomNavVisible ? 0 : 1),
            child: BottomNavigationBar(
              currentIndex: _tab,
              onTap: (i) => setState(() => _tab = i),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF111111),
              unselectedItemColor: const Color(0xFF999999),
              selectedFontSize: 12, unselectedFontSize: 12,
              iconSize: 26, elevation: 0,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined),
                  activeIcon: Icon(Icons.grid_view), label: 'Categories'),
                BottomNavigationBarItem(icon: Icon(Icons.replay_outlined),
                  activeIcon: Icon(Icons.replay), label: 'Reorder'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person), label: 'Account'),
              ],
            ),
          ),
        ],
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductProvider>();
    final address = context.watch<AddressProvider>();
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();

    return SafeArea(
      child: CustomScrollView(
        controller: widget.scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 270,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            title: GestureDetector(
              onTap: () => _showSearch(context, product),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, size: 20, color: Color(0xFF999999)),
                    SizedBox(width: 8),
                    Text('Search for products...', style: TextStyle(
                      fontSize: 14, color: Color(0xFF999999), fontWeight: FontWeight.w400)),
                  ],
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Color(0xFFCDE8FF), Color(0xFFDFF1FF), Color(0xFFF5FAFF)])),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('6 mins', style: TextStyle(
                            fontSize: 42, fontWeight: FontWeight.w700, color: Color(0xFF1857A4))),
                          Row(children: [
                            Flexible(child: Text(
                              address.defaultAddress != null
                                ? 'To ${address.defaultAddress!.line1}'
                                : 'Set delivery address',
                              style: const TextStyle(fontSize: 16,
                                fontWeight: FontWeight.w500, color: Color(0xFF5B5B5B)),
                              maxLines: 1, overflow: TextOverflow.ellipsis)),
                            const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF5B5B5B)),
                          ]),
                        ],
                      )),
                      Row(children: [
                        Stack(children: [
                          IconButton(
                            icon: const Icon(Icons.shopping_cart_outlined, size: 26),
                            onPressed: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const CartScreen()))),
                          if (cart.itemCount > 0)
                            Positioned(right: 4, top: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF12B76A), shape: BoxShape.circle),
                                child: Text(cart.itemCount.toString(),
                                  style: const TextStyle(color: Colors.white,
                                    fontSize: 10, fontWeight: FontWeight.w700)))),
                        ]),
                        GestureDetector(
                          onTap: () {
                            if (auth.isAdmin) {
                              Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const AdminScreen()));
                            }
                          },
                          child: Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3D3D3D), shape: BoxShape.circle,
                              boxShadow: [BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1), blurRadius: 12)]),
                            child: const Icon(Icons.person, color: Colors.white, size: 24))),
                      ]),
                    ]),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _showSearch(context, product),
                      child: const _SearchBarDisplay(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              categories: product.categories,
              selectedCategory: product.selectedCategory,
              onCategorySelected: (catName) {
                context.read<ProductProvider>().selectCategory(catName);
              },
              onSearchTap: () => _showSearch(context, product),
            ),
          ),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: _HeroRow(products: product.products))),
          const SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Text('Trending Near You', style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111111))))),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 0.62,
                crossAxisSpacing: 16, mainAxisSpacing: 16),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  if (i >= product.products.length) return null;
                  return _ProductCard(p: product.products[i]);
                },
                childCount: product.products.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context, ProductProvider product) {
    final searchCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16, left: 24, right: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(
                  color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                TextField(
                  controller: searchCtrl,
                  autofocus: true,
                  onChanged: (v) {
                    setS(() {});
                    product.searchProducts(v);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search for products...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF12B76A)),
                    suffixIcon: searchCtrl.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear),
                          onPressed: () { searchCtrl.clear(); setS(() {}); product.clearSearch(); })
                      : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF12B76A), width: 2)),
                  ),
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
                            icon: const Icon(Icons.add_circle, color: Color(0xFF12B76A)),
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
                    child: Text('No products found', style: TextStyle(color: Colors.grey))),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<CategoryModel> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onSearchTap;

  _StickyHeaderDelegate({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onSearchTap,
  });

  @override double get minExtent => 56;
  @override double get maxExtent => 56;
  @override bool shouldRebuild(covariant _StickyHeaderDelegate old) =>
    old.selectedCategory != selectedCategory || old.categories != categories;

  @override
  Widget build(BuildContext context, double shrink, bool overlap) {
    final list = ['All', ...categories.map((c) => c.name)];
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final catName = list[index];
                final isSelected = catName == selectedCategory;
                
                String? emoji;
                IconData? icon;
                
                if (catName == 'All') {
                  icon = Icons.shopping_basket;
                } else {
                  final cat = categories.firstWhere(
                    (c) => c.name == catName,
                    orElse: () => CategoryModel(
                      id: '', name: '', description: '', icon: '🛒',
                      isActive: true, sortOrder: 0,
                    ),
                  );
                  emoji = cat.icon;
                }
                
                return _TabChip(
                  label: catName,
                  icon: icon,
                  emoji: emoji,
                  sel: isSelected,
                  onTap: () => onCategorySelected(catName),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? emoji;
  final bool sel;
  final VoidCallback onTap;
  const _TabChip({required this.label, this.icon, this.emoji, required this.sel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (emoji != null)
            Text(emoji!, style: TextStyle(fontSize: 20, color: sel ? const Color(0xFF111111) : const Color(0xFF999999)))
          else if (icon != null)
            Icon(icon, size: 24, color: sel ? const Color(0xFF111111) : const Color(0xFF999999)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: sel ? const Color(0xFF111111) : const Color(0xFF999999))),
          if (sel) Container(margin: const EdgeInsets.only(top: 4),
            width: 20, height: 2, decoration: BoxDecoration(
              color: const Color(0xFF1857A4), borderRadius: BorderRadius.circular(1))),
        ]),
      ),
    );
  }
}

class _SearchBarDisplay extends StatefulWidget {
  const _SearchBarDisplay();
  @override
  State<_SearchBarDisplay> createState() => _SearchBarDisplayState();
}

class _SearchBarDisplayState extends State<_SearchBarDisplay> {
  int _i = 0; Timer? _t;
  final _h = ['Perfume','Milk','Chocolate','Rice','Protein','Apple','Curd','Eggs','Bread'];
  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 3), (_) => setState(() => _i = (_i + 1) % _h.length));
  }
  @override
  void dispose() { _t?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08),
          offset: const Offset(0, 4), blurRadius: 14)]),
      child: Row(children: [
        const SizedBox(width: 16),
        const Icon(Icons.search, size: 24, color: Color(0xFF5B5B5B)),
        const SizedBox(width: 12),
        Expanded(child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => FadeTransition(opacity: anim,
            child: SlideTransition(position: Tween<Offset>(
              begin: const Offset(0, 0.3), end: Offset.zero).animate(anim), child: child)),
          child: Row(key: ValueKey(_i), children: [
            const Text("Search for ", style: TextStyle(fontSize: 18, color: Color(0xFF999999))),
            Text(_h[_i], style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111111))),
          ]),
        )),
        Container(width: 1, height: 26, color: const Color(0xFFDDDDDD)),
        const SizedBox(width: 8),
        const Icon(Icons.format_list_bulleted, size: 22, color: Color(0xFF5B5B5B)),
        const SizedBox(width: 12),
      ]));
  }
}

class _HeroRow extends StatefulWidget {
  final List<ProductModel> products;
  const _HeroRow({required this.products});
  @override
  State<_HeroRow> createState() => _HeroRowState();
}

class _HeroRowState extends State<_HeroRow> with SingleTickerProviderStateMixin {
  late AnimationController _f;
  @override
  void initState() {
    super.initState();
    _f = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }
  @override
  void dispose() { _f.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(children: [
          const Expanded(child: Text('Most shopped\nnear you',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
              color: Color(0xFF2E5BA7), height: 1.3))),
          AnimatedBuilder(animation: _f,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, math.sin(_f.value * math.pi) * 6),
              child: Transform.rotate(
                angle: math.sin(_f.value * math.pi) * 0.035,
                child: const Text('\u{1F6D2}\u{1F95B}\u{1F34C}',
                  style: TextStyle(fontSize: 36))))),
        ])),
      const SizedBox(height: 12),
      SizedBox(height: 250,
        child: ListView.builder(
          scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: math.min(widget.products.length, 10),
          itemBuilder: (ctx, i) {
            final p = widget.products[i];
            final cart = ctx.watch<CartProvider>();
            return Padding(padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => ProductQuickView.show(ctx, p),
                child: SizedBox(width: 150, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(width: 150, height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(16)),
                      child: Center(child: p.isNetworkImage
                        ? Image.network(p.displayImage, width: 80, height: 80, fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Text(p.displayImage, style: const TextStyle(fontSize: 44)))
                        : Text(p.displayImage.isNotEmpty ? p.displayImage : '\u{1F6D2}',
                            style: const TextStyle(fontSize: 44)))),
                    const SizedBox(height: 8),
                    Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                        color: Color(0xFF111111), height: 1.2)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(color: const Color(0xFFDDDDDD), width: 1)),
                        child: Text(p.unit, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                      if (p.hasDiscount)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: const Color(0xFFDDDDDD), width: 1)),
                            child: const Text('+2 more', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)))),
                    ]),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(AppConstants.currency + p.finalPrice.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                            fontFeatures: [FontFeature.tabularFigures()])),
                        if (p.hasDiscount)
                          Text(AppConstants.currency + p.price.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 13, color: Color(0xFF999999),
                              decoration: TextDecoration.lineThrough)),
                      ]),
                      _AddButton(p: p),
                    ]),
                  ]))));
          })),
    ]);
  }
}

class _AddButton extends StatefulWidget {
  final ProductModel p;
  const _AddButton({required this.p});
  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() => _scale = 0.94);
    context.read<CartProvider>().addItem(widget.p);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${widget.p.name} added to cart'),
      backgroundColor: const Color(0xFF12B76A),
      duration: const Duration(seconds: 1)));
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _scale = 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Transform.scale(
        scale: _scale,
        child: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF00796B),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))]),
          child: const Icon(Icons.add, color: Colors.white, size: 24))));
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel p;
  const _ProductCard({required this.p});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ProductQuickView.show(context, p),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(16)),
          child: Stack(children: [
            Center(child: p.isNetworkImage
              ? Image.network(p.displayImage, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Text(p.displayImage, style: const TextStyle(fontSize: 48)))
              : Text(p.displayImage.isNotEmpty ? p.displayImage : '\u{1F6D2}',
                  style: const TextStyle(fontSize: 48))),
            if (p.hasDiscount) Positioned(top: 8, left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF12B76A), borderRadius: BorderRadius.circular(6)),
                child: Text('${p.discount.toInt()}% OFF',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)))),
          ]))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFFDDDDDD), width: 1)),
          child: Text(p.unit, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
        const SizedBox(height: 6),
        Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
            color: Color(0xFF111111), height: 1.2)),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(AppConstants.currency + p.finalPrice.toStringAsFixed(2),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()])),
            if (p.hasDiscount)
              Text(AppConstants.currency + p.price.toStringAsFixed(0),
                style: const TextStyle(fontSize: 12, color: Color(0xFF999999),
                  decoration: TextDecoration.lineThrough)),
          ]),
          _AddButton(p: p),
        ]),
      ]));
  }
}

class _FreeDeliveryBanner extends StatefulWidget {
  @override
  State<_FreeDeliveryBanner> createState() => _FreeDeliveryBannerState();
}

class _FreeDeliveryBannerState extends State<_FreeDeliveryBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, height: 58,
      color: const Color(0xFFF2FEFC),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(children: [
        Expanded(child: Text.rich(TextSpan(children: [
          const TextSpan(text: 'FREE DELIVERY ', style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111111))),
          TextSpan(text: 'on orders above ${AppConstants.currency}${AppConstants.freeDeliveryAbove.toInt()}', style: const TextStyle(
            fontSize: 15, color: Color(0xFF5B5B5B))),
        ]))),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animation.value,
              child: child,
            );
          },
          child: CustomPaint(
            painter: _FlagPainter(),
            size: const Size(40, 40),
          ),
        ),
      ]),
    );
  }
}

class _FlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00796B)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.15, 0);
    path.lineTo(size.width * 0.65, 0);
    path.quadraticBezierTo(
      size.width * 0.85, size.height * 0.25,
      size.width * 0.75, size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.85, size.height * 0.75,
      size.width * 0.65, size.height,
    );
    path.lineTo(size.width * 0.15, size.height);
    path.close();

    canvas.drawPath(path, paint);

    final polePaint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.05, 0,
        4, size.height,
      ),
      polePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
