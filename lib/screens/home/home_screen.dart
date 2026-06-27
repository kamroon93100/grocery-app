import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/address_provider.dart';
import '../../models/product_model.dart';
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

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _tab,
        children: const [
          _HomeFeed(),
          CategoriesScreen(),
          ReorderScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // FLOATING CART BAR (when items in cart)
          if (cart.itemCount > 0)
            GestureDetector(
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
                  Text(cart.itemCount.toString() + ' items',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(AppConstants.currency + cart.totalAmount.toStringAsFixed(0),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                ]),
              ),
            ),
          // FREE DELIVERY BANNER
          Container(
            width: double.infinity, height: 40,
            color: const Color(0xFFE7F8EF),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Row(children: [
              Expanded(child: Text.rich(TextSpan(children: [
                TextSpan(text: 'FREE DELIVERY ', style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF111111))),
                TextSpan(text: 'on orders above Rs99', style: TextStyle(
                  fontSize: 11, color: Color(0xFF5B5B5B))),
              ]))),
              Text('\u{1F6A9}', style: TextStyle(fontSize: 18)),
            ])),
          // BOTTOM NAV
          BottomNavigationBar(
            currentIndex: _tab,
            onTap: (i) => setState(() => _tab = i),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF12B76A),
            unselectedItemColor: const Color(0xFF999999),
            selectedFontSize: 12, unselectedFontSize: 12,
            iconSize: 24, elevation: 0,
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
        ],
      ),
    );
  }
}

// HOME FEED with all working buttons
class _HomeFeed extends StatefulWidget {
  const _HomeFeed();
  @override
  State<_HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<_HomeFeed> {
  int _selectedCatTab = 0;

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductProvider>();
    final address = context.watch<AddressProvider>();
    final auth    = context.watch<AuthProvider>();
    final cart    = context.watch<CartProvider>();

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // GREEN HEADER (not sticky)
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Color(0xFFD4F5E4), Color(0xFFE2F9EC), Color(0xFFF0FFF6)])),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('6 mins', style: TextStyle(
                          fontSize: 42, fontWeight: FontWeight.w700, color: Color(0xFF0E8A52))),
                        Row(children: [
                          Flexible(child: Text(
                            address.defaultAddress != null
                              ? 'To ' + address.defaultAddress!.line1
                              : 'Set delivery address',
                            style: const TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w500, color: Color(0xFF5B5B5B)),
                            maxLines: 1, overflow: TextOverflow.ellipsis)),
                          const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF5B5B5B)),
                        ]),
                      ],
                    )),
                    // PROFILE BUTTON - WORKING
                    Row(children: [
                      // Cart icon
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
                      // Profile button - WORKING
                      GestureDetector(
                        onTap: () {
                          if (auth.isAdmin) {
                            Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const AdminScreen()));
                          }
                        },
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3D3D3D), shape: BoxShape.circle,
                            boxShadow: [BoxShadow(
                              color: Colors.black.withOpacity(0.1), blurRadius: 12)]),
                          child: const Icon(Icons.person, color: Colors.white, size: 22))),
                    ]),
                  ]),
                  const SizedBox(height: 16),
                  // SEARCH BAR - WORKING (opens search)
                  GestureDetector(
                    onTap: () => _showSearch(context, product),
                    child: const _SearchBarDisplay(),
                  ),
                ],
              ),
            ),
          ),

          // STICKY SEARCH + TABS (stays on top when scrolling)
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              selectedTab: _selectedCatTab,
              onTabTap: (i) {
                setState(() => _selectedCatTab = i);
                final provider = context.read<ProductProvider>();
                switch (i) {
                  case 0: provider.selectCategory('All'); break;
                  case 1: provider.selectCategory('Vegetables'); break;
                  case 2: provider.selectCategory('All'); break;
                  case 3: provider.selectCategory('All'); break;
                  case 4: provider.selectCategory('All'); break;
                }
              },
              onSearchTap: () => _showSearch(context, product),
            ),
          ),

          // HERO SECTION
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: _HeroRow(products: product.products))),

          // TRENDING TITLE
          const SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Text('Trending Near You', style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111111))))),

          // PRODUCT GRID
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

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  // SEARCH BOTTOM SHEET
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

// STICKY HEADER (search + tabs)
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final int selectedTab;
  final ValueChanged<int> onTabTap;
  final VoidCallback onSearchTap;

  _StickyHeaderDelegate({
    required this.selectedTab,
    required this.onTabTap,
    required this.onSearchTap,
  });

  @override double get minExtent => 106;
  @override double get maxExtent => 106;
  @override bool shouldRebuild(covariant _StickyHeaderDelegate old) =>
    old.selectedTab != selectedTab;

  @override
  Widget build(BuildContext context, double shrink, bool overlap) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Mini search bar (sticky)
          GestureDetector(
            onTap: onSearchTap,
            child: Container(
              height: 42,
              margin: const EdgeInsets.fromLTRB(16, 6, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12)),
              child: const Row(children: [
                Icon(Icons.search, size: 20, color: Color(0xFF999999)),
                SizedBox(width: 8),
                Text('Search for products...', style: TextStyle(
                  fontSize: 14, color: Color(0xFF999999))),
              ]),
            ),
          ),
          // Tabs
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: [
                _TabChip(label: 'All', icon: Icons.shopping_basket,
                  sel: selectedTab == 0, onTap: () => onTabTap(0)),
                _TabChip(label: 'Fresh', icon: Icons.eco,
                  sel: selectedTab == 1, onTap: () => onTabTap(1)),
                _TabChip(label: 'Electronics', icon: Icons.devices,
                  sel: selectedTab == 2, onTap: () => onTabTap(2)),
                _TabChip(label: '50% Off', icon: Icons.local_offer,
                  sel: selectedTab == 3, onTap: () => onTabTap(3)),
                _TabChip(label: 'Vacations', icon: Icons.flight,
                  sel: selectedTab == 4, onTap: () => onTabTap(4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label; final IconData icon; final bool sel; final VoidCallback onTap;
  const _TabChip({required this.label, required this.icon, required this.sel, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 16, color: sel ? const Color(0xFF111111) : const Color(0xFF999999)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: sel ? const Color(0xFF111111) : const Color(0xFF999999))),
          if (sel) Container(margin: const EdgeInsets.only(top: 2),
            width: 16, height: 2, decoration: BoxDecoration(
              color: const Color(0xFF111111), borderRadius: BorderRadius.circular(1))),
        ]),
      ),
    );
  }
}

// SEARCH BAR DISPLAY (animated placeholder)
class _SearchBarDisplay extends StatefulWidget {
  const _SearchBarDisplay();
  @override
  State<_SearchBarDisplay> createState() => _SearchBarDisplayState();
}

class _SearchBarDisplayState extends State<_SearchBarDisplay> {
  int _i = 0; Timer? _t;
  final _h = ['Milk','Rice','Eggs','Bread','Apple','Curd'];
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08),
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
            Text("'" + _h[_i] + "'", style: const TextStyle(
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

// HERO ROW
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
              color: Color(0xFF0E8A52), height: 1.3))),
          AnimatedBuilder(animation: _f,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, math.sin(_f.value * math.pi) * 6),
              child: Transform.rotate(
                angle: math.sin(_f.value * math.pi) * 0.035,
                child: const Text('\u{1F6D2}\u{1F95B}\u{1F34C}',
                  style: TextStyle(fontSize: 36))))),
        ])),
      const SizedBox(height: 12),
      SizedBox(height: 200,
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
                child: SizedBox(width: 140, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(width: 140, height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(14)),
                      child: Center(child: p.isNetworkImage
                        ? Image.network(p.displayImage, width: 70, height: 70, fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Text(p.displayImage, style: const TextStyle(fontSize: 40)))
                        : Text(p.displayImage.isNotEmpty ? p.displayImage : '\u{1F6D2}',
                            style: const TextStyle(fontSize: 40)))),
                    const SizedBox(height: 6),
                    Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                        color: Color(0xFF111111), height: 1.2)),
                    const Spacer(),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(AppConstants.currency + p.finalPrice.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                          fontFeatures: [FontFeature.tabularFigures()])),
                      // + BUTTON - WORKING
                      GestureDetector(
                        onTap: () {
                          ctx.read<CartProvider>().addItem(p);
                          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                            content: Text(p.name + ' added to cart'),
                            backgroundColor: const Color(0xFF12B76A),
                            duration: const Duration(seconds: 1)));
                        },
                        child: Container(width: 34, height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFF12B76A), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.add, color: Colors.white, size: 18))),
                    ]),
                  ]))));
          })),
    ]);
  }
}

// PRODUCT CARD
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
            color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(14)),
          child: Stack(children: [
            Center(child: p.isNetworkImage
              ? Image.network(p.displayImage, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Text(p.displayImage, style: const TextStyle(fontSize: 44)))
              : Text(p.displayImage.isNotEmpty ? p.displayImage : '\u{1F6D2}',
                  style: const TextStyle(fontSize: 44))),
            if (p.hasDiscount) Positioned(top: 8, left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF12B76A), borderRadius: BorderRadius.circular(4)),
                child: Text(p.discount.toInt().toString() + '% OFF',
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)))),
          ]))),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(100)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.schedule, size: 10, color: Color(0xFF667085)),
            SizedBox(width: 2),
            Text('30 mins', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF667085)))])),
        const SizedBox(height: 4),
        Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
            color: Color(0xFF111111), height: 1.2)),
        Text(p.unit, style: const TextStyle(fontSize: 11, color: Color(0xFF5B5B5B))),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(AppConstants.currency + p.finalPrice.toStringAsFixed(2),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()])),
          // + BUTTON - WORKING
          GestureDetector(
            onTap: () {
              context.read<CartProvider>().addItem(p);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(p.name + ' added to cart'),
                backgroundColor: const Color(0xFF12B76A),
                duration: const Duration(seconds: 1)));
            },
            child: Container(width: 36, height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF12B76A), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.add, color: Colors.white, size: 20))),
        ]),
      ]));
  }
}
