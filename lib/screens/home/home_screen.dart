import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import '../address/address_screen.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildShopPage(),
          const OrdersScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex:        _currentIndex,
          selectedItemColor:   AppColors.primary,
          unselectedItemColor: Colors.grey,
          backgroundColor:     Colors.white,
          elevation:           0,
          type: BottomNavigationBarType.fixed,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Orders'),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Account'),
          ],
        ),
      ),
    );
  }

  Widget _buildShopPage() {
    final auth     = context.watch<AuthProvider>();
    final cart     = context.watch<CartProvider>();
    final product  = context.watch<ProductProvider>();
    final address  = context.watch<AddressProvider>();

    return CustomScrollView(
      slivers: [
        // Top Header with delivery time + address
        SliverToBoxAdapter(
          child: Container(
            color: AppColors.primaryLight,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 12),
            child: Column(
              children: [
                Row(
                  children: [
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
                                    fontSize: 18,
                                    color: AppColors.textDark)),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(4)),
                                  child: const Text('30 MINS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  address.defaultAddress != null
                                      ? 'To: ${address.defaultAddress!.line1}'
                                      : 'Tap to set address',
                                  style: const TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 13),
                                  overflow: TextOverflow.ellipsis),
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
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.person_outline,
                            color: AppColors.textDark, size: 28),
                          onPressed: () => setState(() => _currentIndex = 2),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color:        Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border:       Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged:  (val) =>
                      context.read<ProductProvider>().searchProducts(val),
                    decoration: InputDecoration(
                      hintText: "Search for products...",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchCtrl.clear();
                                context.read<ProductProvider>().clearSearch();
                              })
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_searchCtrl.text.isEmpty) ...[
          // Promo Banner
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🎉 FREE Delivery',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                        const SizedBox(height: 4),
                        Text('Use code WELCOME10 for 10% off',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                    child: const Text('SHOP NOW',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),

          // Categories Grid (Instamart style)
          if (product.categories.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Shop by Category',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark)),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: product.categories.length,
                      itemBuilder: (context, index) {
                        final cat = product.categories[index];
                        return GestureDetector(
                          onTap: () => context.read<ProductProvider>()
                              .selectCategory(cat.name),
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(cat.icon,
                                    style: const TextStyle(fontSize: 32)),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(cat.name,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                                maxLines: 2,
                                textAlign: TextAlign.center),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

          // Selected Category Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.selectedCategory == 'All'
                        ? 'All Products'
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

        // Products Grid
        _searchCtrl.text.isNotEmpty
            ? _buildSearchResults(product, cart)
            : _buildProductGrid(product, cart),

        // Bottom padding for cart bar
        if (cart.itemCount > 0)
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildSearchResults(ProductProvider product, CartProvider cart) {
    if (product.isSearching) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)));
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
          childAspectRatio: 0.62,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _productCard(product.searchResults[index], cart),
          childCount: product.searchResults.length,
        ),
      ),
    );
  }

  Widget _buildProductGrid(ProductProvider product, CartProvider cart) {
    if (product.products.isEmpty && !product.isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              const Text('No products found'),
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
          childAspectRatio: 0.62,
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
            return _productCard(product.products[index], cart);
          },
          childCount: product.products.length + (product.hasMore ? 1 : 0),
        ),
      ),
    );
  }

  Widget _productCard(ProductModel p, CartProvider cart) {
    final inCart = cart.isInCart(p.id);
    final qty    = cart.getQuantity(p.id);

    return GestureDetector(
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p))),
      child: Container(
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: Colors.grey.shade200),
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
                  top: Radius.circular(12)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: p.isNetworkImage
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              p.displayImage,
                              height: 100, width: 100, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                Text(p.displayImage.length <= 3 ? p.displayImage : '🛒',
                                  style: const TextStyle(fontSize: 60)),
                            ),
                          )
                        : Text(p.displayImage.isNotEmpty ? p.displayImage : '🛒',
                            style: const TextStyle(fontSize: 60)),
                  ),
                  if (p.hasDiscount)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4)),
                        child: Text('${p.discount.toInt()}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 9)),
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
                  // Delivery time chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time, size: 10, color: AppColors.textGrey),
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
                  Text(p.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textDark),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${p.unit} • ${p.stock} in stock',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${AppConstants.currency}${p.finalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textDark)),
                            if (p.hasDiscount)
                              Text('${AppConstants.currency}${p.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 10,
                                  decoration: TextDecoration.lineThrough)),
                          ],
                        ),
                      ),
                      inCart
                          ? Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () => context.read<CartProvider>()
                                        .decreaseQuantity(p.id),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.remove,
                                        color: Colors.white, size: 14)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: Text('$qty',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                  ),
                                  InkWell(
                                    onTap: () => context.read<CartProvider>()
                                        .increaseQuantity(p.id),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.add,
                                        color: Colors.white, size: 14)),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.primary),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: TextButton(
                                onPressed: () =>
                                  context.read<CartProvider>().addItem(p),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                  minimumSize: Size.zero,
                                ),
                                child: const Text('ADD',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
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
