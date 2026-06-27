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
          Container(
            width: double.infinity,
            height: 44,
            color: const Color(0xFFE7F8EF),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Expanded(
                  child: Text.rich(TextSpan(children: [
                    TextSpan(text: 'FREE DELIVERY ',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                        color: Color(0xFF111111))),
                    TextSpan(text: 'on orders above Rs99',
                      style: TextStyle(fontSize: 12, color: Color(0xFF5B5B5B))),
                  ])),
                ),
                const _WavingFlag(),
              ],
            ),
          ),
          BottomNavigationBar(
            currentIndex: _tab,
            onTap: (i) => setState(() => _tab = i),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF12B76A),
            unselectedItemColor: const Color(0xFF999999),
            selectedFontSize: 12,
            unselectedFontSize: 12,
            iconSize: 24,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_outlined),
                activeIcon: Icon(Icons.grid_view),
                label: 'Categories'),
              BottomNavigationBarItem(
                icon: Icon(Icons.replay_outlined),
                activeIcon: Icon(Icons.replay),
                label: 'Reorder'),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Account'),
            ],
          ),
        ],
      ),
    );
  }
}

class _WavingFlag extends StatefulWidget {
  const _WavingFlag();
  @override
  State<_WavingFlag> createState() => _WavingFlagState();
}

class _WavingFlagState extends State<_WavingFlag>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
      duration: const Duration(seconds: 3))..repeat(reverse: true);
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Transform.rotate(
        angle: math.sin(_c.value * math.pi) * 0.05,
        child: const Text('\u{1F6A9}', style: TextStyle(fontSize: 22))));
  }
}

class _HomeFeed extends StatefulWidget {
  const _HomeFeed();
  @override
  State<_HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<_HomeFeed> {
  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductProvider>();
    final address = context.watch<AddressProvider>();

    return SafeArea(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // GREEN GRADIENT HEADER
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFD4F5E4), Color(0xFFE2F9EC), Color(0xFFF0FFF6)],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('6 mins',
                            style: TextStyle(fontSize: 42, fontWeight: FontWeight.w700,
                              color: Color(0xFF0E8A52))),
                          Row(children: [
                            Flexible(
                              child: Text(
                                address.defaultAddress != null
                                    ? 'To ' + address.defaultAddress!.line1
                                    : 'Set delivery address',
                                style: const TextStyle(fontSize: 16,
                                  fontWeight: FontWeight.w500, color: Color(0xFF5B5B5B)),
                                maxLines: 1, overflow: TextOverflow.ellipsis)),
                            const Icon(Icons.keyboard_arrow_down,
                              size: 20, color: Color(0xFF5B5B5B)),
                          ]),
                        ],
                      ),
                    ),
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D3D3D), shape: BoxShape.circle,
                        boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.1), blurRadius: 12)]),
                      child: const Icon(Icons.person, color: Colors.white, size: 24)),
                  ],
                ),
                const SizedBox(height: 16),
                const _SearchBar(),
              ],
            ),
          ),

          // TABS
          Container(
            height: 54,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              children: const [
                _Tab(icon: Icons.shopping_basket, label: 'All', sel: true),
                _Tab(icon: Icons.eco, label: 'Fresh', sel: false),
                _Tab(icon: Icons.devices, label: 'Electronics', sel: false),
                _Tab(icon: Icons.local_offer, label: '50% Off', sel: false),
                _Tab(icon: Icons.flight, label: 'Vacations', sel: false),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // HERO
          _Hero(products: product.products),

          const SizedBox(height: 32),

          // TRENDING
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text('Trending Near You',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                color: Color(0xFF111111)))),

          const SizedBox(height: 16),

          // GRID
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 0.62,
                crossAxisSpacing: 16, mainAxisSpacing: 16),
              itemCount: product.products.length,
              itemBuilder: (ctx, i) => _Card(p: product.products[i]),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar();
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  int _i = 0;
  Timer? _t;
  final _h = ['Milk','Rice','Eggs','Bread','Apple','Curd'];
  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() => _i = (_i + 1) % _h.length);
    });
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
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
                  .animate(anim), child: child)),
            child: Row(key: ValueKey(_i), children: [
              const Text("Search for ", style: TextStyle(fontSize: 18, color: Color(0xFF999999))),
              Text("'" + _h[_i] + "'", style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111111))),
            ]),
          ),
        ),
        Container(width: 1, height: 26, color: const Color(0xFFDDDDDD)),
        const SizedBox(width: 8),
        const Icon(Icons.format_list_bulleted, size: 22, color: Color(0xFF5B5B5B)),
        const SizedBox(width: 12),
      ]),
    );
  }
}

class _Tab extends StatelessWidget {
  final IconData icon; final String label; final bool sel;
  const _Tab({required this.icon, required this.label, required this.sel});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20,
            color: sel ? const Color(0xFF111111) : const Color(0xFF999999)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
            color: sel ? const Color(0xFF111111) : const Color(0xFF999999))),
          if (sel) Container(
            margin: const EdgeInsets.only(top: 2),
            width: 16, height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(1))),
        ],
      ),
    );
  }
}

class _Hero extends StatefulWidget {
  final List<ProductModel> products;
  const _Hero({required this.products});
  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> with SingleTickerProviderStateMixin {
  late AnimationController _f;
  @override
  void initState() {
    super.initState();
    _f = AnimationController(vsync: this,
      duration: const Duration(seconds: 3))..repeat(reverse: true);
  }
  @override
  void dispose() { _f.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
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
      SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: math.min(widget.products.length, 10),
          itemBuilder: (ctx, i) {
            final p = widget.products[i];
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => ProductQuickView.show(ctx, p),
                child: SizedBox(width: 140, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140, height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(14)),
                      child: Center(child: p.isNetworkImage
                        ? Image.network(p.displayImage, width: 70, height: 70,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Text(p.displayImage,
                              style: const TextStyle(fontSize: 40)))
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
                      GestureDetector(
                        onTap: () => ctx.read<CartProvider>().addItem(p),
                        child: Container(width: 34, height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFF12B76A),
                            borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.add, color: Colors.white, size: 18))),
                    ]),
                  ]))),
            );
          }),
      ),
    ]);
  }
}

class _Card extends StatelessWidget {
  final ProductModel p;
  const _Card({required this.p});
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return GestureDetector(
      onTap: () => ProductQuickView.show(context, p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14)),
            child: Stack(children: [
              Center(child: p.isNetworkImage
                ? Image.network(p.displayImage, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Text(p.displayImage,
                      style: const TextStyle(fontSize: 44)))
                : Text(p.displayImage.isNotEmpty ? p.displayImage : '\u{1F6D2}',
                    style: const TextStyle(fontSize: 44))),
              if (p.hasDiscount) Positioned(top: 8, left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12B76A),
                    borderRadius: BorderRadius.circular(4)),
                  child: Text(p.discount.toInt().toString() + '% OFF',
                    style: const TextStyle(color: Colors.white,
                      fontSize: 9, fontWeight: FontWeight.w700)))),
            ]))),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(100)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.schedule, size: 10, color: Color(0xFF667085)),
              SizedBox(width: 2),
              Text('30 mins', style: TextStyle(fontSize: 10,
                fontWeight: FontWeight.w600, color: Color(0xFF667085)))])),
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
            GestureDetector(
              onTap: () => context.read<CartProvider>().addItem(p),
              child: Container(width: 36, height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF12B76A),
                  borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.add, color: Colors.white, size: 20))),
          ]),
        ]),
    );
  }
}
