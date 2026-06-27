import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  int _currentTab = 0;
  final ScrollController _scrollCtrl = ScrollController();
  bool _showNav = true;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      final dir = _scrollCtrl.position.userScrollDirection;
      if (dir == ScrollDirection.reverse && _showNav) {
        setState(() => _showNav = false);
      } else if (dir == ScrollDirection.forward && !_showNav) {
        setState(() => _showNav = true);
      }
    });
  }

  @override
  void dispose() { _scrollCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentTab,
        children: [
          _HomePage(scrollCtrl: _scrollCtrl, showNav: _showNav, bottomPad: bottomPad),
          const CategoriesScreen(),
          const ReorderScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        height: _showNav ? (56 + bottomPad) : 0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _showNav ? 1 : 0,
          child: BottomNavigationBar(
            currentIndex: _currentTab,
            onTap: (i) => setState(() => _currentTab = i),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF111111),
            unselectedItemColor: const Color(0xFF999999),
            selectedFontSize: 12,
            unselectedFontSize: 12,
            iconSize: 24,
            elevation: 8,
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
        ),
      ),
    );
  }
}

class _HomePage extends StatefulWidget {
  final ScrollController scrollCtrl;
  final bool showNav;
  final double bottomPad;
  const _HomePage({required this.scrollCtrl, required this.showNav, required this.bottomPad});

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  int _selectedTab = 0;

  final List<Map<String, dynamic>> _tabs = [
    {'icon': Icons.shopping_basket, 'label': 'All'},
    {'icon': Icons.eco,             'label': 'Fresh'},
    {'icon': Icons.devices,         'label': 'Electronics'},
    {'icon': Icons.local_offer,     'label': '50% Off'},
    {'icon': Icons.flight,          'label': 'Vacations'},
  ];

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductProvider>();
    final cart    = context.watch<CartProvider>();
    final auth    = context.watch<AuthProvider>();
    final address = context.watch<AddressProvider>();

    return Stack(
      children: [
        NestedScrollView(
          controller: widget.scrollCtrl,
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, innerScrolled) => [
            // BLUE HERO + HEADER
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFCDE8FF), Color(0xFFDFF1FF), Color(0xFFF5FAFF)],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // DELIVERY HEADER
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('6 mins',
                                    style: TextStyle(
                                      fontSize: 42, fontWeight: FontWeight.w700,
                                      color: Color(0xFF1857A4))),
                                  Row(children: [
                                    Flexible(
                                      child: Text(
                                        address.defaultAddress != null
                                            ? 'To ${address.defaultAddress!.line1}'
                                            : 'Set delivery address',
                                        style: const TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.w500,
                                          color: Color(0xFF5B5B5B)),
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
                                color: const Color(0xFF3D3D3D),
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 12)]),
                              child: const Icon(Icons.person,
                                color: Colors.white, size: 24)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // SEARCH BAR
                        _SearchBar(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // STICKY TABS
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabDelegate(
                tabs: _tabs,
                selected: _selectedTab,
                onTap: (i) {
                  setState(() => _selectedTab = i);
                  // Filter products based on tab
                  final provider = context.read<ProductProvider>();
                  switch (i) {
                    case 0: // All
                      provider.selectCategory('All');
                      break;
                    case 1: // Fresh
                      provider.selectCategory('Vegetables');
                      break;
                    case 2: // Electronics (show all for now)
                      provider.selectCategory('All');
                      break;
                    case 3: // 50% Off (show discounted)
                      provider.selectCategory('All');
                      break;
                    case 4: // Vacations (show all for now)
                      provider.selectCategory('All');
                      break;
                  }
                },
              ),
            ),
          ],

          body: ListView(
            padding: const EdgeInsets.only(top: 0),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 24),

              // HERO SECTION
              _HeroRow(products: product.products),

              const SizedBox(height: 36),

              // TRENDING TITLE
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text('Trending Near You',
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: Color(0xFF111111)))),

              const SizedBox(height: 16),

              // PRODUCT GRID
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16),
                  itemCount: product.products.length,
                  itemBuilder: (context, i) =>
                    _GridCard(product: product.products[i]),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),

        // DELIVERY BANNER
        if (widget.showNav)
          Positioned(
            bottom: 56 + widget.bottomPad,
            left: 0, right: 0,
            child: _DeliveryBanner(),
          ),
      ],
    );
  }
}

// SEARCH BAR
class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  int _idx = 0;
  Timer? _timer;
  final _hints = ['Perfume','Milk','Chocolate','Rice','Eggs','Bread','Apple'];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() => _idx = (_idx + 1) % _hints.length);
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.08),
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
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3), end: Offset.zero)
                  .animate(anim),
                child: child)),
            child: Row(
              key: ValueKey(_idx),
              children: [
                const Text("Search for ", style: TextStyle(
                  fontSize: 18, color: Color(0xFF999999))),
                Text("'${_hints[_idx]}'", style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: Color(0xFF111111))),
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

// STICKY TABS DELEGATE
class _TabDelegate extends SliverPersistentHeaderDelegate {
  final List<Map<String, dynamic>> tabs;
  final int selected;
  final ValueChanged<int> onTap;

  _TabDelegate({required this.tabs, required this.selected, required this.onTap});

  @override double get minExtent => 60;
  @override double get maxExtent => 60;
  @override bool shouldRebuild(covariant _TabDelegate old) =>
    old.selected != selected;

  @override
  Widget build(BuildContext context, double shrink, bool overlap) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final sel = i == selected;
            return GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tabs[i]['icon'] as IconData,
                      size: 20,
                      color: sel ? const Color(0xFF111111) : const Color(0xFF999999)),
                    const SizedBox(height: 4),
                    Text(tabs[i]['label'] as String,
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w500,
                        color: sel ? const Color(0xFF111111) : const Color(0xFF999999))),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: sel ? 20 : 0,
                      height: 2,
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(1))),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
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
  late AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(vsync: this,
      duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() { _float.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(children: [
            const Expanded(
              child: Text('Most shopped\nnear you',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                  color: Color(0xFF2E5BA7), height: 1.3))),
            AnimatedBuilder(
              animation: _float,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, math.sin(_float.value * math.pi) * 6),
                child: Transform.rotate(
                  angle: math.sin(_float.value * math.pi) * 0.035,
                  child: const Text('🛒🥛🍌', style: TextStyle(fontSize: 36))))),
          ]),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: math.min(widget.products.length, 10),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _HeroCard(product: widget.products[i])),
          ),
        ),
      ],
    );
  }
}

// HERO CARD
class _HeroCard extends StatelessWidget {
  final ProductModel product;
  const _HeroCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final p = product;

    return GestureDetector(
      onTap: () => ProductQuickView.show(context, p),
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150, height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(14)),
              child: Center(
                child: p.isNetworkImage
                    ? Image.network(p.displayImage, width: 80, height: 80,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Text(p.displayImage,
                          style: const TextStyle(fontSize: 44)))
                    : Text(p.displayImage.isNotEmpty ? p.displayImage : '🛒',
                        style: const TextStyle(fontSize: 44)))),
            const SizedBox(height: 6),
            Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                color: Color(0xFF111111), height: 1.2)),
            const SizedBox(height: 4),
            Container(
              height: 24, padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDDDDDD))),
              child: Center(child: Text(p.unit,
                style: const TextStyle(fontSize: 11, color: Color(0xFF5B5B5B))))),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${AppConstants.currency}${p.finalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                        fontFeatures: [FontFeature.tabularFigures()])),
                    if (p.hasDiscount)
                      Text('${AppConstants.currency}${p.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF999999),
                          decoration: TextDecoration.lineThrough)),
                  ]),
                _PlusBtn(
                  onTap: () => context.read<CartProvider>().addItem(p),
                  inCart: cart.isInCart(p.id), qty: cart.getQuantity(p.id),
                  onAdd: () => context.read<CartProvider>().increaseQuantity(p.id),
                  onMinus: () => context.read<CartProvider>().decreaseQuantity(p.id)),
              ]),
          ]),
      ),
    );
  }
}

// GRID CARD
class _GridCard extends StatelessWidget {
  final ProductModel product;
  const _GridCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final p = product;

    return GestureDetector(
      onTap: () => ProductQuickView.show(context, p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                children: [
                  Center(
                    child: p.isNetworkImage
                        ? Image.network(
                            p.displayImage,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Text(
                              p.displayImage,
                              style: const TextStyle(fontSize: 44),
                            ),
                          )
                        : Text(
                            p.displayImage.isNotEmpty ? p.displayImage : '🛒',
                            style: const TextStyle(fontSize: 44),
                          ),
                  ),
                  if (p.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${p.discount.toInt()}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Timer pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule, size: 10, color: Color(0xFF667085)),
                SizedBox(width: 2),
                Text('30 mins',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Name
          Text(
            p.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111111),
              height: 1.2,
            ),
          ),
          // Unit
          Text(
            p.unit,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF5B5B5B),
            ),
          ),
          const SizedBox(height: 6),
          // Price + Add
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppConstants.currency}${p.finalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              _PlusBtn(
                onTap: () => context.read<CartProvider>().addItem(p),
                inCart: cart.isInCart(p.id),
                qty: cart.getQuantity(p.id),
                onAdd: () => context.read<CartProvider>().increaseQuantity(p.id),
                onMinus: () => context.read<CartProvider>().decreaseQuantity(p.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// PLUS BUTTON
class _PlusBtn extends StatelessWidget {
  final VoidCallback onTap, onAdd, onMinus;
  final bool inCart;
  final int qty;
  const _PlusBtn({required this.onTap, required this.inCart,
    required this.qty, required this.onAdd, required this.onMinus});

  @override
  Widget build(BuildContext context) {
    if (inCart) {
      return Container(
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF00796B),
          borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          InkWell(onTap: onMinus, child: const SizedBox(width: 28,
            child: Center(child: Icon(Icons.remove, color: Colors.white, size: 14)))),
          SizedBox(width: 20, child: Center(child: Text('$qty',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700,
              fontSize: 13, fontFeatures: [FontFeature.tabularFigures()])))),
          InkWell(onTap: onAdd, child: const SizedBox(width: 28,
            child: Center(child: Icon(Icons.add, color: Colors.white, size: 14)))),
        ]));
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF00796B),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: const Color(0xFF00796B).withOpacity(0.3),
            blurRadius: 6, offset: const Offset(0, 2))]),
        child: const Icon(Icons.add, color: Colors.white, size: 22)));
  }
}

// DELIVERY BANNER
class _DeliveryBanner extends StatefulWidget {
  @override
  State<_DeliveryBanner> createState() => _DeliveryBannerState();
}

class _DeliveryBannerState extends State<_DeliveryBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _flag;

  @override
  void initState() {
    super.initState();
    _flag = AnimationController(vsync: this,
      duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() { _flag.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50, color: const Color(0xFFF2FEFC),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(children: [
        const Expanded(child: Text.rich(TextSpan(children: [
          TextSpan(text: 'FREE DELIVERY ', style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111111))),
          TextSpan(text: 'on orders above Rs99', style: TextStyle(
            fontSize: 13, color: Color(0xFF5B5B5B)))]))),
        AnimatedBuilder(
          animation: _flag,
          builder: (_, __) => Transform.rotate(
            angle: math.sin(_flag.value * math.pi) * 0.035,
            child: const Text('🚩', style: TextStyle(fontSize: 22)))),
      ]));
  }
}


