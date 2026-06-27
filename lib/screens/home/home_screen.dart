import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/address_provider.dart';
import '../../models/product_model.dart';
import '../../constants/app_constants.dart';
import '../../main.dart';
import '../cart/cart_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_screen.dart';
import '../product/product_detail_screen.dart';
import '../../widgets/product_quick_view.dart';
import '../../widgets/sticky_brand_cards.dart';
import '../address/address_screen.dart';
import '../../widgets/smooth_search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().loadAddresses();
    });
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildShopPage(),
              const OrdersScreen(),
              const ProfileScreen(),
            ],
          ),
          // FLOATING CART BAR
          if (cart.itemCount > 0)
            Positioned(
              left: 12, right: 12, bottom: 75,
              child: _FloatingCartBar(),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long), label: 'Orders'),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person), label: 'Account'),
          ],
        ),
      ),
    );
  }

  Widget _buildShopPage() {
    final auth    = context.watch<AuthProvider>();
    final cart    = context.watch<CartProvider>();
    final product = context.watch<ProductProvider>();
    final address = context.watch<AddressProvider>();

    return CustomScrollView(
      slivers: [
        // STICKY HEADER
        SliverAppBar(
          backgroundColor: AppColors.primaryLight,
          elevation: 0,
          pinned: true,
          floating: true,
          expandedHeight: 130,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Delivery time + Address
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const AddressScreen())),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('Delivery in',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: AppColors.textDark)),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(4)),
                                      child: const Text('30 MIN',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        address.defaultAddress != null
                                            ? 'To: ${address.defaultAddress!.line1}'
                                            : 'Tap to set address',
                                        style: const TextStyle(
                                          color: AppColors.textGrey,
                                          fontSize: 12),
                                        overflow: TextOverflow.ellipsis),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down,
                                      size: 16, color: AppColors.textGrey),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (auth.isAdmin)
                          IconButton(
                            icon: const Icon(Icons.admin_panel_settings,
                              color: AppColors.primary),
                            onPressed: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const AdminScreen())),
                          ),
                        // CART BADGE
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.shopping_cart_outlined,
                                color: AppColors.textDark, size: 26),
                              onPressed: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const CartScreen())),
                            ),
                            if (cart.itemCount > 0)
                              Positioned(
                                right: 4, top: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle),
                                  constraints: const BoxConstraints(
                                    minWidth: 18, minHeight: 18),
                                  child: Text('${cart.itemCount}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // SEARCH BAR
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.shade200, blurRadius: 4),
                        ],
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (val) =>
                          context.read<ProductProvider>().searchProducts(val),
                        decoration: InputDecoration(
                          hintText: 'Search for "Milk", "Bread"...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500, fontSize: 13),
                          prefixIcon: const Icon(Icons.search,
                            color: AppColors.primary),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    context.read<ProductProvider>().clearSearch();
                                  })
                              : const Icon(Icons.mic_outlined,
                                  color: AppColors.primary),
                          border: InputBorder.none,
                          contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        if (_searchCtrl.text.isEmpty) ...[
          // HERO PROMO CARD (Animated)
          SliverToBoxAdapter(
            child: _HeroPromoCard(),
          ),

          // CATEGORY RAIL (Horizontal chips)
          if (product.categories.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Shop by Category',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark)),
                          Text('${product.categories.length} categories',
                            style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 11)),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: product.categories.length,
                        itemBuilder: (context, index) {
                          final cat = product.categories[index];
                          final isSelected =
                            product.selectedCategory == cat.name;
                          return GestureDetector(
                            onTap: () => context.read<ProductProvider>()
                                .selectCategory(cat.name),
                            child: Container(
                              width: 80,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 60, height: 60,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(12),
                                      border: isSelected
                                          ? Border.all(
                                              color: AppColors.primaryDark,
                                              width: 2)
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(cat.icon,
                                        style: const TextStyle(fontSize: 32)),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(cat.name,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected
                                          ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textDark),
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // SPONSORED BRAND ADS - Horizontal scroll
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('💎 Featured Brands',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(6)),
                    child: const Text('SPONSORED',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: StickyBrandCards(
              ads: DemoBrandAds.getAds(),
            ),
          ),

          // SINGLE BIG BRAND AD
          SliverToBoxAdapter(
            child: VerticalStickyBrandCard(
              ad: BrandAdData(
                id:        'special-offer',
                brandName: 'Kohli Store Special',
                tagline:   'Save BIG\nThis Weekend!',
                ctaText:   'Get Offers',
                emoji:     '🎉',
                gradientColors: const [
                  Color(0xFF1BA672), Color(0xFF0F8559)
                ],
              ),
              height: 160,
            ),
          ),

          // URGENCY CARD - Low Stock / Limited Time
          SliverToBoxAdapter(
            child: _UrgencyCard(),
          ),

          // BUNDLE / OFFERS CARDS
          SliverToBoxAdapter(
            child: _OffersRow(),
          ),

          // SECTION TITLE
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.selectedCategory == 'All'
                        ? '🔥 Trending Near You'
                        : product.selectedCategory,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark)),
                  if (product.selectedCategory != 'All')
                    TextButton(
                      onPressed: () => context.read<ProductProvider>()
                          .selectCategory('All'),
                      child: const Text('Show All',
                        style: TextStyle(color: AppColors.primary)),
                    ),
                ],
              ),
            ),
          ),
        ],

        // PRODUCTS GRID
        _searchCtrl.text.isNotEmpty
            ? _buildSearchResults(product)
            : _buildProductGrid(product),

        // Bottom padding for cart bar
        SliverToBoxAdapter(
          child: SizedBox(height: cart.itemCount > 0 ? 100 : 20)),
      ],
    );
  }

  Widget _buildSearchResults(ProductProvider product) {
    if (product.isSearching) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary)));
    }
    if (product.searchResults.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text('No results found',
                style: TextStyle(color: Colors.grey.shade500)),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _ProductCard(product.searchResults[index]),
          childCount: product.searchResults.length,
        ),
      ),
    );
  }

  Widget _buildProductGrid(ProductProvider product) {
    if (product.products.isEmpty && !product.isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag_outlined,
                size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              const Text('No products yet'),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == product.products.length) {
              context.read<ProductProvider>().loadProducts();
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
            }
            return _ProductCard(product.products[index]);
          },
          childCount: product.products.length + (product.hasMore ? 1 : 0),
        ),
      ),
    );
  }
}

// HERO PROMO CARD with auto-scroll
class _HeroPromoCard extends StatefulWidget {
  @override
  State<_HeroPromoCard> createState() => _HeroPromoCardState();
}

class _HeroPromoCardState extends State<_HeroPromoCard> {
  final PageController _ctrl = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _promos = [
    {'title':'FREE Delivery', 'subtitle':'On orders above ${AppConstants.currency}50',
     'color1': const Color(0xFF1BA672), 'color2': const Color(0xFF0F8559), 'emoji':'🚚'},
    {'title':'WELCOME10', 'subtitle':'10% off your first order',
     'color1': const Color(0xFFFF6B6B), 'color2': const Color(0xFFEE5A6F), 'emoji':'🎫'},
    {'title':'Fresh Daily', 'subtitle':'Direct from farms to your door',
     'color1': const Color(0xFFFF9800), 'color2': const Color(0xFFFFA726), 'emoji':'🌿'},
    {'title':'Cash on Delivery', 'subtitle':'Pay when you receive',
     'color1': const Color(0xFF2196F3), 'color2': const Color(0xFF42A5F5), 'emoji':'💵'},
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_ctrl.hasClients) {
        _currentPage = (_currentPage + 1) % _promos.length;
        _ctrl.animateToPage(_currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() { _timer?.cancel(); _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 130,
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: PageView.builder(
            controller: _ctrl,
            itemCount: _promos.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final p = _promos[index];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [p['color1'], p['color2']],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -10, top: -10,
                      child: Opacity(
                        opacity: 0.3,
                        child: Text(p['emoji'],
                          style: const TextStyle(fontSize: 130)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(p['subtitle'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                            child: Text('SHOP NOW',
                              style: TextStyle(
                                color: p['color1'],
                                fontWeight: FontWeight.bold,
                                fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_promos.length, (i) =>
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == i ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? AppColors.primary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3)),
            ),
          ),
        ),
      ],
    );
  }
}

// URGENCY CARD - Delivery countdown
class _UrgencyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle),
            child: const Icon(Icons.local_fire_department,
              color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ending Soon!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    fontSize: 14)),
                Text('Get groceries delivered in 30 mins',
                  style: TextStyle(
                    color: Colors.grey.shade700, fontSize: 12)),
              ],
            ),
          ),
          const Text('🔥', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}

// OFFERS HORIZONTAL ROW
class _OffersRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      margin: const EdgeInsets.only(top: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _offerCard('🥦', 'Fresh Veggies', '20% OFF', Colors.green),
          _offerCard('🍎', 'Fresh Fruits', '15% OFF', Colors.red),
          _offerCard('🥛', 'Daily Essentials', 'Up to 25%', Colors.blue),
          _offerCard('🍪', 'Snacks', 'Buy 2 Get 1', Colors.purple),
          _offerCard('🧃', 'Beverages', '10% OFF', Colors.orange),
        ],
      ),
    );
  }

  Widget _offerCard(String emoji, String title, String offer, Color color) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          Text(title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 13)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4)),
            child: Text(offer,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10)),
          ),
        ],
      ),
    );
  }
}

// PRODUCT CARD (Quick Add)
class _ProductCard extends StatelessWidget {
  final ProductModel product;
  const _ProductCard(this.product);

  @override
  Widget build(BuildContext context) {
    final cart   = context.watch<CartProvider>();
    final inCart = cart.isInCart(product.id);
    final qty    = cart.getQuantity(product.id);

    return GestureDetector(
      onTap: () => ProductQuickView.show(context, product, relatedProducts: context.read<ProductProvider>().products.where((p) => p.id != product.id).take(5).toList()),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 130,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12))),
              child: Stack(
                children: [
                  Center(
                    child: product.isNetworkImage
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.displayImage,
                              height: 100, width: 100, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                Text(product.displayImage.length <= 3
                                    ? product.displayImage : '🛒',
                                  style: const TextStyle(fontSize: 60))))
                        : Text(product.displayImage.isNotEmpty
                            ? product.displayImage : '🛒',
                            style: const TextStyle(fontSize: 60)),
                  ),
                  if (product.hasDiscount)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4)),
                        child: Text('${product.discount.toInt()}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 9)),
                      ),
                    ),
                  if (product.stock < 10 && product.stock > 0)
                    Positioned(
                      bottom: 6, right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4)),
                        child: Text('Only ${product.stock} left',
                          style: const TextStyle(
                            color: Colors.white, fontSize: 9,
                            fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time,
                          size: 10, color: AppColors.textGrey),
                        const SizedBox(width: 3),
                        Text('30 mins',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textDark),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(product.unit,
                    style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 11)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${AppConstants.currency}${product.finalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textDark)),
                            if (product.hasDiscount)
                              Text('${AppConstants.currency}${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 10,
                                  decoration: TextDecoration.lineThrough)),
                          ],
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: inCart
                            ? Container(
                                key: const ValueKey('incart'),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(6)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () => context.read<CartProvider>()
                                          .decreaseQuantity(product.id),
                                      child: const Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Icon(Icons.remove,
                                          color: Colors.white, size: 14)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6),
                                      child: Text('$qty',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12)),
                                    ),
                                    InkWell(
                                      onTap: () => context.read<CartProvider>()
                                          .increaseQuantity(product.id),
                                      child: const Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Icon(Icons.add,
                                          color: Colors.white, size: 14)),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                key: const ValueKey('add'),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.primary),
                                  borderRadius: BorderRadius.circular(6)),
                                child: TextButton(
                                  onPressed: () => context.read<CartProvider>()
                                      .addItem(product),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 4),
                                    minimumSize: Size.zero),
                                  child: const Text('ADD',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// FLOATING CART BAR
class _FloatingCartBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(14),
      color: AppColors.primary,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const CartScreen())),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8)),
                child: Stack(
                  children: [
                    const Icon(Icons.shopping_basket,
                      color: Colors.white, size: 22),
                    Positioned(
                      right: -4, top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                        constraints: const BoxConstraints(
                          minWidth: 16, minHeight: 16),
                        child: Text('${cart.itemCount}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 9)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${cart.itemCount} ${cart.itemCount > 1 ? "items" : "item"} in cart',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                    Text('${AppConstants.currency}${cart.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),
              const Text('VIEW CART',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}



