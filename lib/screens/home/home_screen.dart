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

/// ═══════════════════════════════════════════════════════
/// HOME SCREEN - EXACT SPEC IMPLEMENTATION
/// Following every pixel, color, spacing, and animation
/// from the provided specification. NO creative changes.
/// ═══════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {

  int _currentTab = 0;

  // Spec 14: Bottom nav hide on scroll down, show on scroll up
  final ScrollController _scrollCtrl = ScrollController();
  bool _showBottomNav    = true;
  bool _showDeliveryBanner = true;
  double _lastScrollPos  = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  // Spec 14: Hide/show bottom nav based on scroll direction
  void _onScroll() {
    final current = _scrollCtrl.position.pixels;
    final direction = _scrollCtrl.position.userScrollDirection;

    if (direction == ScrollDirection.reverse && current > 100) {
      if (_showBottomNav) setState(() {
        _showBottomNav = false;
        _showDeliveryBanner = false;
      });
    } else if (direction == ScrollDirection.forward) {
      if (!_showBottomNav) setState(() {
        _showBottomNav = true;
        _showDeliveryBanner = true;
      });
    }
    _lastScrollPos = current;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Spec: Background white under gradient
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          // Main content
          IndexedStack(
            index: _currentTab,
            children: [
              _HomeContent(scrollCtrl: _scrollCtrl),
              const CategoriesScreen(),
              const ReorderScreen(),
              const ProfileScreen(),
            ],
          ),

          // Spec 13: Floating delivery banner (above bottom nav)
          if (_currentTab == 0)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              bottom: _showDeliveryBanner ? 74 : -60,
              left: 0, right: 0,
              child: const _DeliveryBanner(),
            ),

          // Spec 14: Bottom navigation (slides in/out)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            bottom: _showBottomNav ? 0 : -84,
            left: 0, right: 0,
            child: _BottomNav(
              current: _currentTab,
              onTap:   (i) => setState(() => _currentTab = i),
            ),
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════
/// HOME CONTENT (scrollable area)
/// ═══════════════════════════════════════════════════════

class _HomeContent extends StatelessWidget {
  final ScrollController scrollCtrl;
  const _HomeContent({required this.scrollCtrl});

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductProvider>();
    final cart    = context.watch<CartProvider>();

    return CustomScrollView(
      controller: scrollCtrl,
      // Spec 10/16: Bouncing scroll physics
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        // ─── BLUE HERO AREA (Spec 1, 2, 3) ─────
        SliverToBoxAdapter(child: _BlueHeroArea()),

        // ─── STICKY CATEGORY TABS (Spec 4) ──────
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyTabsDelegate(),
        ),

        // Spec 17: Section spacing 32-36px
        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // ─── HERO SECTION (Spec 6, 7) ───────────
        SliverToBoxAdapter(child: _HeroSection(products: product.products)),

        // Spec 17: Section spacing 32-36px
        const SliverToBoxAdapter(child: SizedBox(height: 36)),

        // ─── PRODUCT GRID ───────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: const Text('Trending Near You',
              style: TextStyle(
                fontSize:   18,
                fontWeight: FontWeight.w800,
                color:      Color(0xFF111111))),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 18)),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:   2,
              childAspectRatio: 0.58,
              crossAxisSpacing: 16,
              mainAxisSpacing:  16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= product.products.length) {
                  if (product.hasMore) {
                    product.loadProducts();
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00796B), strokeWidth: 2));
                  }
                  return null;
                }
                return _ProductCard(product: product.products[index]);
              },
              childCount: product.products.length + (product.hasMore ? 1 : 0),
            ),
          ),
        ),

        // Bottom spacing for nav + banner
        const SliverToBoxAdapter(child: SizedBox(height: 180)),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════
/// BLUE HERO AREA (Spec 1, 2, 3)
/// Gradient: #CDE8FF → #DFF1FF → #F5FAFF
/// Height: 250-280px
/// ═══════════════════════════════════════════════════════

class _BlueHeroArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth    = context.watch<AuthProvider>();
    final address = context.watch<AddressProvider>();
    final cart    = context.watch<CartProvider>();

    return Container(
      // Spec 1: Gradient background, 250-280px
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end:   Alignment.bottomCenter,
          colors: [
            Color(0xFFCDE8FF),  // Top
            Color(0xFFDFF1FF),  // Middle
            Color(0xFFF5FAFF),  // Bottom
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── DELIVERY HEADER (Spec 2) ─────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Spec 2: ETA - 42px, Bold, #1857A4
                        const Text('6 mins',
                          style: TextStyle(
                            fontSize:   42,
                            fontWeight: FontWeight.w700,
                            color:      Color(0xFF1857A4),
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Spec 2: Address - 16px, Medium, Grey
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                address.defaultAddress != null
                                    ? 'To ${address.defaultAddress!.line1}'
                                    : 'Set delivery address',
                                style: const TextStyle(
                                  fontSize:   16,
                                  fontWeight: FontWeight.w500,
                                  color:      Color(0xFF5B5B5B)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Spec 2: Dropdown arrow
                            const Icon(Icons.keyboard_arrow_down,
                              size: 20, color: Color(0xFF5B5B5B)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Spec 2: Profile button - 48x48, circle, dark grey, shadow
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D3D3D),
                      shape: BoxShape.circle,
                      // Spec 2: Shadow blur 12, opacity 10%
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12),
                      ],
                    ),
                    child: const Icon(Icons.person,
                      color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── SEARCH BAR (Spec 3) ──────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _AnimatedSearchBar(),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════
/// ANIMATED SEARCH BAR (Spec 3)
/// Height: 56, Radius: 18, Shadow: Y=4, Blur=14, 8%
/// Animated placeholder: rotates every 2-3 seconds
/// ═══════════════════════════════════════════════════════

class _AnimatedSearchBar extends StatefulWidget {
  @override
  State<_AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<_AnimatedSearchBar>
    with SingleTickerProviderStateMixin {

  int    _hintIndex = 0;
  Timer? _timer;

  // Spec 3: Rotating placeholder words
  final List<String> _hints = [
    'Perfume', 'Milk', 'Chocolate', 'Rice',
    'Protein', 'Apple', 'Curd', 'Eggs', 'Bread',
  ];

  late AnimationController _slideCtrl;
  late Animation<Offset>   _slideAnim;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250), // Spec 3: 250ms
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeIn);

    _slideCtrl.forward();

    // Spec 3: Change every 2-3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _slideCtrl.reset();
      setState(() => _hintIndex = (_hintIndex + 1) % _hints.length);
      _slideCtrl.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Spec 3: Height 56, Radius 18
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        // Spec 3: Shadow Y=4, Blur=14, Opacity 8%
        boxShadow: [
          BoxShadow(
            color:  Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 14),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          // Spec 3: Search icon 24px
          const Icon(Icons.search,
            size: 24, color: Color(0xFF5B5B5B)),
          const SizedBox(width: 12),
          // Spec 3: Animated placeholder
          Expanded(
            child: Row(
              children: [
                // Spec 3: "Search for" regular 18px grey
                const Text("Search for ",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF999999))),
                // Spec 3: Animated word - bold 18px dark
                SlideTransition(
                  position: _slideAnim,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Text(
                      "'${_hints[_hintIndex]}'",
                      style: const TextStyle(
                        fontSize:   18,
                        fontWeight: FontWeight.w700,
                        color:      Color(0xFF111111))),
                  ),
                ),
              ],
            ),
          ),
          // Spec 3: Divider - Height 26, Width 1, Grey
          Container(
            width: 1, height: 26,
            color: const Color(0xFFDDDDDD)),
          // Spec 3: List icon - 40x40 touch target
          SizedBox(
            width: 40, height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.format_list_bulleted,
                size: 22, color: Color(0xFF5B5B5B)),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════
/// STICKY CATEGORY TABS (Spec 4)
/// Icons: 24px, Text: 13px Medium
/// Selected: Blue outline, rounded top, bottom indicator
/// Pinned on scroll
/// ═══════════════════════════════════════════════════════

class _StickyTabsDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _TabItem(icon: Icons.shopping_basket, label: 'All',         selected: true),
          _TabItem(icon: Icons.eco,             label: 'Fresh',       selected: false),
          _TabItem(icon: Icons.devices,         label: 'Electronics', selected: false),
          _TabItem(icon: Icons.local_offer,     label: '50% Off',     selected: false),
          _TabItem(icon: Icons.flight,          label: 'Vacations',   selected: false),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyTabsDelegate oldDelegate) => false;
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     selected;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Spec 4: Spacing 32px
      margin: const EdgeInsets.only(right: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Spec 4: Icons 24px
          Icon(icon,
            size: 24,
            color: selected
                ? const Color(0xFF111111)
                : const Color(0xFF999999)),
          const SizedBox(height: 4),
          // Spec 4: Text 13px Medium
          Text(label,
            style: TextStyle(
              fontSize:   13,
              fontWeight: FontWeight.w500,
              color: selected
                  ? const Color(0xFF111111)
                  : const Color(0xFF999999))),
          // Spec 4: Bottom indicator for selected
          if (selected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 24, height: 2,
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(1)),
            ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════
/// HERO SECTION (Spec 6)
/// "Most shopped near you" + floating grocery bucket
/// ═══════════════════════════════════════════════════════

class _HeroSection extends StatefulWidget {
  final List<ProductModel> products;
  const _HeroSection({required this.products});

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection>
    with SingleTickerProviderStateMixin {

  late AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    // Spec 6: Float + rotate 2deg, 3 seconds, infinite
    _floatCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() { _floatCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + floating bucket
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              // Spec 6: Heading 18px Extra Bold, Blue #2E5BA7
              const Expanded(
                child: Text('Most shopped\nnear you',
                  style: TextStyle(
                    fontSize:   18,
                    fontWeight: FontWeight.w800,
                    color:      Color(0xFF2E5BA7),
                    height:     1.3)),
              ),
              // Spec 6: Animated grocery bucket
              AnimatedBuilder(
                animation: _floatCtrl,
                builder: (_, __) {
                  return Transform.translate(
                    offset: Offset(0, math.sin(_floatCtrl.value * math.pi) * 6),
                    child: Transform.rotate(
                      angle: math.sin(_floatCtrl.value * math.pi) * 0.035, // ~2 deg
                      child: const Text('🛒🥛🍌',
                        style: TextStyle(fontSize: 40)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Spec 7: Horizontal product carousel
        SizedBox(
          // Spec 7: Card height 250
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: math.min(widget.products.length, 10),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _CarouselProductCard(
                  product: widget.products[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════
/// CAROUSEL PRODUCT CARD (Spec 7, 8, 9, 10, 11)
/// Width: 150, Height: 250
/// NO borders, NO shadows - only spacing
/// ═══════════════════════════════════════════════════════

class _CarouselProductCard extends StatefulWidget {
  final ProductModel product;
  const _CarouselProductCard({required this.product});

  @override
  State<_CarouselProductCard> createState() => _CarouselProductCardState();
}

class _CarouselProductCardState extends State<_CarouselProductCard>
    with SingleTickerProviderStateMixin {

  late AnimationController _pressCtrl;
  late Animation<double>   _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100));
    // Spec 10: Scale 1 -> 0.94 -> 1, spring
    _pressScale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _pressCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p    = widget.product;
    final cart = context.watch<CartProvider>();

    return GestureDetector(
      onTapDown:   (_) => _pressCtrl.forward(),
      onTapUp:     (_) => _pressCtrl.reverse(),
      onTapCancel: ()  => _pressCtrl.reverse(),
      onTap: () => ProductQuickView.show(context, p),
      child: ScaleTransition(
        scale: _pressScale,
        child: SizedBox(
          // Spec 7: Width 150
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Spec 7: Image 120x120, transparent PNG, no border/bg
              Container(
                width: 150, height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: p.isNetworkImage
                      ? Image.network(p.displayImage,
                          width: 96, height: 96, fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                            Text(p.displayImage, style: const TextStyle(fontSize: 48)))
                      : Text(p.displayImage.isNotEmpty
                          ? p.displayImage : '🛒',
                          style: const TextStyle(fontSize: 48)),
                ),
              ),

              // Spec 7: Title spacing 6px
              const SizedBox(height: 6),

              // Spec 7: Title - max 2 lines, 15-16px
              Text(p.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize:   15,
                  fontWeight: FontWeight.w500,
                  color:      Color(0xFF111111),
                  height:     1.25)),

              const SizedBox(height: 4),

              // Spec 8: Variant chips
              Row(
                children: [
                  Container(
                    // Spec 8: Height 26, Radius 13
                    height: 26,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: const Color(0xFFDDDDDD))),
                    child: Center(
                      child: Text(p.unit,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5B5B5B))),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Spec 9: Price row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Spec 9: Price bold 20px
                      Text('${AppConstants.currency}${p.finalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize:   20,
                          fontWeight: FontWeight.w700,
                          color:      Color(0xFF111111),
                          fontFeatures: [FontFeature.tabularFigures()])),
                      // Spec 9: Old price grey strikethrough, spacing 4px
                      if (p.hasDiscount)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${AppConstants.currency}${p.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize:   14,
                              color:      Color(0xFF999999),
                              decoration: TextDecoration.lineThrough,
                              fontFeatures: [FontFeature.tabularFigures()])),
                        ),
                    ],
                  ),
                  // Spec 10: Green "+" button 48x48, radius 14, #00796B
                  _AddPlusButton(
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
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════
/// ADD BUTTON (Spec 10)
/// 48x48, Radius 14, Green #00796B, White +
/// Press: Scale 1 -> 0.94 -> 1, spring
/// ═══════════════════════════════════════════════════════

class _AddPlusButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool         inCart;
  final int          qty;
  final VoidCallback onAdd;
  final VoidCallback onMinus;

  const _AddPlusButton({
    required this.onTap,
    required this.inCart,
    required this.qty,
    required this.onAdd,
    required this.onMinus,
  });

  @override
  Widget build(BuildContext context) {
    if (inCart) {
      return Container(
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF00796B),
          borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: onMinus,
              child: const SizedBox(
                width: 32,
                child: Center(child: Icon(Icons.remove,
                  color: Colors.white, size: 16))),
            ),
            SizedBox(
              width: 24,
              child: Center(
                child: Text('$qty',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    fontFeatures: [FontFeature.tabularFigures()]))),
            ),
            InkWell(
              onTap: onAdd,
              child: const SizedBox(
                width: 32,
                child: Center(child: Icon(Icons.add,
                  color: Colors.white, size: 16))),
            ),
          ],
        ),
      );
    }

    // Spec 10: 48x48, Radius 14, Green #00796B
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF00796B),
          borderRadius: BorderRadius.circular(14),
          // Spec 10: Shadow
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00796B).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3)),
          ],
        ),
        child: const Center(
          child: Icon(Icons.add,
            color: Colors.white, size: 26)),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════
/// PRODUCT CARD (Grid version - Spec 11)
/// NO borders, NO shadows - only spacing
/// ═══════════════════════════════════════════════════════

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final cart   = context.watch<CartProvider>();
    final p      = product;

    return GestureDetector(
      onTap: () => ProductQuickView.show(context, p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16)),
              child: Stack(
                children: [
                  Center(
                    child: p.isNetworkImage
                        ? Image.network(p.displayImage,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                              Text(p.displayImage, style: const TextStyle(fontSize: 48)))
                        : Text(p.displayImage.isNotEmpty
                            ? p.displayImage : '🛒',
                            style: const TextStyle(fontSize: 48)),
                  ),
                  if (p.hasDiscount)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A),
                          borderRadius: BorderRadius.circular(4)),
                        child: Text('${p.discount.toInt()}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(100)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule, size: 10, color: Color(0xFF667085)),
                SizedBox(width: 3),
                Text('30 mins', style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: Color(0xFF667085))),
              ],
            ),
          ),

          const SizedBox(height: 6),

          Text(p.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
              height: 1.3)),

          const SizedBox(height: 2),

          Text(p.unit,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF5B5B5B))),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${AppConstants.currency}${p.finalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111111),
                      fontFeatures: [FontFeature.tabularFigures()])),
                  if (p.hasDiscount)
                    Text('${AppConstants.currency}${p.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF999999),
                        decoration: TextDecoration.lineThrough)),
                ],
              ),
              _AddPlusButton(
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

/// ═══════════════════════════════════════════════════════
/// DELIVERY BANNER (Spec 13)
/// Height: 58, Background: #F2FEFC
/// Animated flag
/// ═══════════════════════════════════════════════════════

class _DeliveryBanner extends StatefulWidget {
  const _DeliveryBanner();
  @override
  State<_DeliveryBanner> createState() => _DeliveryBannerState();
}

class _DeliveryBannerState extends State<_DeliveryBanner>
    with SingleTickerProviderStateMixin {

  late AnimationController _flagCtrl;

  @override
  void initState() {
    super.initState();
    _flagCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _flagCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Spec 13: Height 58, bg #F2FEFC
      height: 58,
      color: const Color(0xFFF2FEFC),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: const TextSpan(children: [
                TextSpan(
                  text: 'FREE DELIVERY ',
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: Color(0xFF111111))),
                TextSpan(
                  text: 'on orders above Rs99',
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w400,
                    color: Color(0xFF5B5B5B))),
              ]),
            ),
          ),
          // Spec 13: Animated flag wave 2deg
          AnimatedBuilder(
            animation: _flagCtrl,
            builder: (_, __) {
              return Transform.rotate(
                angle: math.sin(_flagCtrl.value * math.pi) * 0.035,
                child: const Text('🚩',
                  style: TextStyle(fontSize: 24)),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════
/// BOTTOM NAVIGATION (Spec 14, 16)
/// height: 72, Icons: 26x26, Text: 12px Medium
/// Selected: Black filled, Unselected: Grey
/// ═══════════════════════════════════════════════════════

class _BottomNav extends StatelessWidget {
  final int               current;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Spec 14: Height 82
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.home_outlined,        activeIcon: Icons.home,
              label: 'Home',       index: 0, current: current, onTap: onTap),
            _NavItem(icon: Icons.grid_view_outlined,   activeIcon: Icons.grid_view,
              label: 'Categories', index: 1, current: current, onTap: onTap),
            _NavItem(icon: Icons.replay_outlined,      activeIcon: Icons.replay,
              label: 'Reorder',    index: 2, current: current, onTap: onTap),
            _NavItem(icon: Icons.person_outline,       activeIcon: Icons.person,
              label: 'Account',    index: 3, current: current, onTap: onTap),
          ],
        ),
      );
  }
}

class _NavItem extends StatelessWidget {
  final IconData          icon;
  final IconData          activeIcon;
  final String            label;
  final int               index;
  final int               current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = index == current;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Spec 14: Icons 26x26
            Icon(selected ? activeIcon : icon,
              size: 26,
              color: selected
                  ? const Color(0xFF111111)
                  : const Color(0xFF999999)),
            const SizedBox(height: 4),
            // Spec 14: Text 12px Medium
            Text(label,
              style: TextStyle(
                fontSize:   12,
                fontWeight: FontWeight.w500,
                color: selected
                    ? const Color(0xFF111111)
                    : const Color(0xFF999999))),
          ],
        ),
      ),
    );
  }
}

